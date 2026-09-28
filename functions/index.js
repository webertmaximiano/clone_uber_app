require("dotenv").config();

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const cors = require("cors")({origin: true});

// Inicializar Firebase Admin
admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// Acessa a variável de ambiente de forma segura a partir do process.env
const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY;

exports.placesAutocomplete = functions.https.onRequest((request, response) => {
  // Habilita o CORS para permitir chamadas do app web.
  cors(request, response, async () => {
    // Pega o texto de busca dos parâmetros da query (ex: ?input=hospital)
    const input = request.query.input;
    const lat = request.query.lat;
    const lng = request.query.lng;

    if (!input) {
      functions.logger.warn("O parâmetro 'input' não foi fornecido.");
      response.status(400).send("O parâmetro 'input' é obrigatório.");
      return;
    }

    const url = `https://maps.googleapis.com/maps/api/place/autocomplete/json`;

    const params = {
      input: input,
      key: GOOGLE_API_KEY,
      language: "pt_BR",
      components: "country:br",
    };

    // Adiciona o location bias se as coordenadas forem fornecidas
    if (lat && lng) {
      params.location = `${lat},${lng}`;
      params.radius = 10000; // 10km de raio
    }

    try {
      const res = await axios.get(url, {params: params});
      functions.logger.info("Resposta da API do Google recebida com sucesso.");
      response.status(200).send(res.data);
    } catch (error) {
      functions.logger.error("Erro ao chamar a API do Google Places:", error);
      if (error.response) {
        // A requisição foi feita e o servidor respondeu com um erro
        response.status(error.response.status).send(error.response.data);
      } else if (error.request) {
        // A requisição foi feita mas nenhuma resposta foi recebida
        response.status(500).send("Nenhuma resposta da API do Google.");
      } else {
        // Erro na configuração da requisição
        response.status(500).send("Erro ao configurar a requisição.");
      }
    }
  });
});

// =====================================================
// CLOUD FUNCTIONS PARA NOTIFICAÇÕES PUSH
// =====================================================

/**
 * Enviar notificação de status da corrida para o usuário
 * Trigger: Quando um documento é criado em notifications/{notificationId}
 * Funcionalidade:
 *  - Buscar FCM token do usuário
 *  - Enviar notificação via Firebase Cloud Messaging
 *  - Marcar notificação como enviada
 *  - Tratamento de erros (token inválido, usuário sem token, etc.)
 */
exports.sendRideStatusNotification = functions
  .firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    try {
      const notification = snap.data();
      const { userId, rideId, type, title, body, status } = notification;

      functions.logger.info(`Processando notificação: ${type} para usuário ${userId}`);

      // Validar dados
      if (!userId || !rideId || !type || !title || !body) {
        functions.logger.error("Dados de notificação incompletos", notification);
        return;
      }

      // Buscar FCM token do usuário
      const userDoc = await db.collection("users").doc(userId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        functions.logger.warn(
          `Usuário ${userId} não possui FCM token. Notificação não será enviada via FCM.`
        );
        // Marcar como enviada mesmo sem FCM token
        await snap.ref.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp() });
        return;
      }

      // Preparar dados da mensagem
      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          rideId: rideId,
          type: type,
          status: status || "",
          sentAt: new Date().toISOString(),
        },
        token: fcmToken,
      };

      // Enviar via FCM
      const response = await messaging.send(message);
      functions.logger.info(`Notificação enviada com sucesso: ${response}`);

      // Marcar como enviada no Firestore
      await snap.ref.update({
        sent: true,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: response,
      });
    } catch (error) {
      functions.logger.error("Erro ao enviar notificação:", error);

      // Se for erro de token inválido, deletar o token
      if (error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered") {
        const userId = snap.data().userId;
        await db.collection("users").doc(userId).update({
          fcmToken: admin.firestore.FieldValue.delete(),
        });
        functions.logger.info(`Token inválido deletado para usuário: ${userId}`);
      }

      // Marcar como erro
      await snap.ref.update({
        sent: false,
        error: error.message,
      });
    }
  });

/**
 * Enviar notificação de nova corrida disponível para motoristas próximos
 * Trigger: Quando um documento é criado em ride_notifications/{notificationId}
 * Funcionalidade:
 *  - Buscar drivers online próximos (dentro de 5km)
 *  - Enviar notificação para cada driver
 *  - Usar geohashing para otimizar queries
 *  - Marcar como processada
 */
exports.notifyNearbyDrivers = functions
  .firestore
  .document("ride_notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    try {
      const rideNotif = snap.data();
      const { rideId, originLat, originLng, origin, rideType, title, body } = rideNotif;

      functions.logger.info(`Nova corrida disponível: ${rideId} em ${origin}`);

      // Validar dados
      if (!originLat || !originLng || !rideId) {
        functions.logger.error("Dados incompletos para calcular proximidade", rideNotif);
        return;
      }

      // Buscar drivers online
      const driversSnap = await db
        .collection("drivers")
        .where("isOnline", "==", true)
        .limit(100) // Limitar para evitar overload
        .get();

      if (driversSnap.empty) {
        functions.logger.info("Nenhum driver online encontrado");
        return;
      }

      const RADIUS_KM = 5.0;
      const driversToNotify = [];
      let notificationsSent = 0;

      // Iterar drivers e calcular distância
      for (const driverDoc of driversSnap.docs) {
        const driver = driverDoc.data();
        const { latitude, longitude, fcmToken, uid } = driver;

        if (!latitude || !longitude || !fcmToken) {
          continue; // Pular drivers sem localização ou token
        }

        // Calcular distância (Haversine)
        const distance = calculateDistance(originLat, originLng, latitude, longitude);

        if (distance <= RADIUS_KM) {
          driversToNotify.push({
            uid,
            fcmToken,
            distance: distance.toFixed(1),
          });
        }
      }

      functions.logger.info(
        `${driversToNotify.length} drivers encontrados dentro de ${RADIUS_KM}km`
      );

      // Enviar notificações em paralelo (com limite)
      const batchSize = 10;
      for (let i = 0; i < driversToNotify.length; i += batchSize) {
        const batch = driversToNotify.slice(i, i + batchSize);

        await Promise.all(
          batch.map((driver) =>
            sendNewRideNotificationToDriver(driver, rideId, origin, rideType, title, body)
              .then(() => {
                notificationsSent++;
              })
              .catch((error) => {
                functions.logger.error(
                  `Erro ao notificar driver ${driver.uid}:`,
                  error
                );
              })
          )
        );
      }

      // Marcar como processada
      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        driversNotified: notificationsSent,
      });

      functions.logger.info(
        `Notificações enviadas para ${notificationsSent} drivers`
      );
    } catch (error) {
      functions.logger.error("Erro ao notificar drivers próximos:", error);
      await snap.ref.update({
        processed: false,
        error: error.message,
      });
    }
  });

/**
 * Função auxiliar: Enviar notificação de nova corrida para um driver específico
 */
async function sendNewRideNotificationToDriver(
  driver,
  rideId,
  origin,
  rideType,
  title,
  body
) {
  const message = {
    notification: {
      title: title,
      body: `${rideType} a ${driver.distance}km - Saindo de ${origin}`,
    },
    data: {
      rideId: rideId,
      type: "new_ride_available",
      origin: origin,
      rideType: rideType,
      distance: driver.distance,
    },
    token: driver.fcmToken,
  };

  const response = await messaging.send(message);
  functions.logger.info(`Notificação enviada para driver ${driver.uid}: ${response}`);
}

/**
 * Função auxiliar: Calcular distância usando Haversine formula
 */
function calculateDistance(lat1, lng1, lat2, lng2) {
  const R = 6371; // Raio da Terra em km
  const dLat = toRadians(lat2 - lat1);
  const dLng = toRadians(lng2 - lng1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * Função auxiliar: Converter graus para radianos
 */
function toRadians(degrees) {
  return (degrees * Math.PI) / 180;
}

/**
 * Função de limpeza: Deletar notificações antigas (>30 dias)
 * Trigger: Executar diariamente via Cloud Scheduler
 */
exports.cleanupOldNotifications = functions.pubsub
  .schedule("0 2 * * *") // 2 AM todo dia
  .timeZone("America/Sao_Paulo")
  .onRun(async (context) => {
    try {
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

      functions.logger.info("Iniciando limpeza de notificações antigas...");

      // Deletar notificações antigas
      const notificationsSnap = await db
        .collection("notifications")
        .where("createdAt", "<", thirtyDaysAgo)
        .limit(500)
        .get();

      if (notificationsSnap.empty) {
        functions.logger.info("Nenhuma notificação antiga para deletar");
        return;
      }

      const batch = db.batch();
      notificationsSnap.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      functions.logger.info(
        `${notificationsSnap.docs.length} notificações antigas deletadas`
      );
    } catch (error) {
      functions.logger.error("Erro ao limpar notificações antigas:", error);
    }
  });

/**
 * Função de limpeza: Deletar ride_notifications antigas (>24 horas)
 * Trigger: Executar a cada hora
 */
exports.cleanupOldRideNotifications = functions.pubsub
  .schedule("0 * * * *") // A cada hora
  .timeZone("America/Sao_Paulo")
  .onRun(async (context) => {
    try {
      const twentyFourHoursAgo = new Date(
        Date.now() - 24 * 60 * 60 * 1000
      );

      functions.logger.info("Iniciando limpeza de ride_notifications antigas...");

      const rideNotificationsSnap = await db
        .collection("ride_notifications")
        .where("createdAt", "<", twentyFourHoursAgo)
        .limit(500)
        .get();

      if (rideNotificationsSnap.empty) {
        functions.logger.info("Nenhuma ride_notification antiga para deletar");
        return;
      }

      const batch = db.batch();
      rideNotificationsSnap.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      functions.logger.info(
        `${rideNotificationsSnap.docs.length} ride_notifications antigas deletadas`
      );
    } catch (error) {
      functions.logger.error(
        "Erro ao limpar ride_notifications antigas:",
        error
      );
    }
  });

/**
 * Função de retentativa: Reenviar notificações não entregues
 * Trigger: Executar a cada 30 minutos
 */
exports.retryFailedNotifications = functions.pubsub
  .schedule("*/30 * * * *") // A cada 30 minutos
  .timeZone("America/Sao_Paulo")
  .onRun(async (context) => {
    try {
      functions.logger.info("Iniciando retentativa de notificações não entregues...");

      const failedSnap = await db
        .collection("notifications")
        .where("sent", "==", false)
        .where("createdAt", ">", new Date(Date.now() - 24 * 60 * 60 * 1000)) // Últimas 24h
        .limit(100)
        .get();

      if (failedSnap.empty) {
        functions.logger.info("Nenhuma notificação falhada para reenviar");
        return;
      }

      let retriedCount = 0;

      for (const doc of failedSnap.docs) {
        const notification = doc.data();
        const { userId, type, title, body } = notification;

        try {
          const userDoc = await db.collection("users").doc(userId).get();
          const fcmToken = userDoc.data()?.fcmToken;

          if (!fcmToken) {
            continue;
          }

          const message = {
            notification: { title, body },
            data: {
              type: type,
              rideId: notification.rideId || "",
            },
            token: fcmToken,
          };

          const response = await messaging.send(message);
          await doc.ref.update({
            sent: true,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            messageId: response,
            retriedCount: admin.firestore.FieldValue.increment(1),
          });

          retriedCount++;
        } catch (error) {
          functions.logger.warn(`Falha ao reenviar notificação ${doc.id}: ${error.message}`);
        }
      }

      functions.logger.info(`${retriedCount} notificações reenviadas com sucesso`);
    } catch (error) {
      functions.logger.error(
        "Erro ao reenviar notificações não entregues:",
        error
      );
    }
  });

