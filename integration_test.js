#!/usr/bin/env node

/**
 * 🧪 Script de Teste de Integração - Clone Uber
 * 
 * Uso:
 *   node integration_test.js [ambiente]
 * 
 * Ambientes:
 *   - staging (padrão)
 *   - production
 * 
 * Requisitos:
 *   - Firebase CLI configurado
 *   - Acesso ao projeto Firebase
 *   - Node.js 14+
 */

const admin = require("firebase-admin");
const readline = require("readline");
const colors = require("colors");

// ============================================================================
// CONFIGURAÇÃO
// ============================================================================

const AMBIENTE = process.argv[2] || "staging";
const RAIO_BUSCA_KM = 5;
const TIMEOUT_MS = 30000;

// Coordenadas de teste (São Paulo)
const COORDS = {
  origem: { lat: -23.5505, lng: -46.6333 }, // Centro
  destino: { lat: -23.5965, lng: -46.7115 }, // Zona Sul
};

// ============================================================================
// INICIALIZAÇÃO FIREBASE
// ============================================================================

let db;
let messaging;

function initFirebase() {
  try {
    if (!admin.apps.length) {
      admin.initializeApp();
    }
    db = admin.firestore();
    messaging = admin.messaging();
    console.log(colors.green("✓ Firebase inicializado"));
    return true;
  } catch (error) {
    console.error(colors.red("✗ Erro ao inicializar Firebase:"), error.message);
    return false;
  }
}

// ============================================================================
// UTILITIES
// ============================================================================

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function question(query) {
  return new Promise((resolve) => rl.question(query, resolve));
}

function log(type, message) {
  const icons = {
    info: "ℹ️ ",
    success: "✅",
    warning: "⚠️ ",
    error: "❌",
    debug: "🔧",
    test: "🧪",
  };

  const colors_map = {
    info: colors.blue,
    success: colors.green,
    warning: colors.yellow,
    error: colors.red,
    debug: colors.cyan,
    test: colors.magenta,
  };

  const colorFn = colors_map[type] || colors.gray;
  console.log(colorFn(`${icons[type]} ${message}`));
}

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// ============================================================================
// FASE 1: CRIAR USUÁRIO
// ============================================================================

async function fase1_criarUsuario() {
  console.log(colors.bold.cyan("\n📋 FASE 1: Criar Usuário (Passageiro)"));

  const email = await question("Email do usuário: ");
  if (!validateEmail(email)) {
    log("error", "Email inválido");
    return null;
  }

  const password = await question("Senha: ");

  try {
    // Criar usuário no Firebase Auth
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: "Usuário Teste",
    });

    log("success", `Usuário criado: ${userRecord.uid}`);

    // Criar documento no Firestore
    await db.collection("users").doc(userRecord.uid).set({
      uid: userRecord.uid,
      name: "Usuário Teste",
      email: email,
      phone: "11999999999",
      photoUrl: "",
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
      fcmToken: null, // Será preenchido quando o app se conectar
      location: {
        latitude: COORDS.origem.lat,
        longitude: COORDS.origem.lng,
      },
    });

    log("success", "Documento do usuário criado no Firestore");

    return {
      uid: userRecord.uid,
      email: email,
    };
  } catch (error) {
    log("error", `Erro ao criar usuário: ${error.message}`);
    return null;
  }
}

// ============================================================================
// FASE 2: CRIAR MOTORISTA
// ============================================================================

async function fase2_criarMotorista() {
  console.log(colors.bold.cyan("\n🚗 FASE 2: Criar Motorista"));

  const email = await question("Email do motorista: ");
  if (!validateEmail(email)) {
    log("error", "Email inválido");
    return null;
  }

  const password = await question("Senha: ");

  try {
    const driverRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: "Motorista Teste",
    });

    log("success", `Motorista criado: ${driverRecord.uid}`);

    // Criar documento no Firestore
    await db.collection("drivers").doc(driverRecord.uid).set({
      uid: driverRecord.uid,
      name: "Motorista Teste",
      email: email,
      phone: "11988888888",
      photoUrl: "",
      isActive: true,
      isOnline: true, // Importante: estar online
      createdAt: new Date(),
      updatedAt: new Date(),
      fcmToken: null,
      location: {
        latitude: COORDS.origem.lat + 0.01, // Um pouco mais perto (1km aprox)
        longitude: COORDS.origem.lng + 0.01,
      },
      totalRides: 0,
      totalEarnings: 0,
      averageRating: 5.0,
      licenseNumber: "123456789",
      vehiclePlate: "ABC1234",
      vehicleModel: "Toyota Corolla",
    });

    log("success", "Documento do motorista criado no Firestore");

    return {
      uid: driverRecord.uid,
      email: email,
    };
  } catch (error) {
    log("error", `Erro ao criar motorista: ${error.message}`);
    return null;
  }
}

// ============================================================================
// FASE 3: CRIAR CORRIDA
// ============================================================================

async function fase3_criarCorrida(userId) {
  console.log(colors.bold.cyan("\n🎯 FASE 3: Criar Corrida"));

  try {
    const rideData = {
      userId: userId,
      origin: {
        latitude: COORDS.origem.lat,
        longitude: COORDS.origem.lng,
        address: "Origem - Teste",
      },
      destination: {
        latitude: COORDS.destino.lat,
        longitude: COORDS.destino.lng,
        address: "Destino - Teste",
      },
      status: "pending",
      estimatedPrice: 45.5,
      distance: 15.3, // km
      estimatedDuration: 35, // minutos
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const rideRef = await db.collection("rides").add(rideData);
    log("success", `Corrida criada: ${rideRef.id}`);

    return {
      rideId: rideRef.id,
      ...rideData,
    };
  } catch (error) {
    log("error", `Erro ao criar corrida: ${error.message}`);
    return null;
  }
}

// ============================================================================
// FASE 4: VERIFICAR RIDE_NOTIFICATIONS
// ============================================================================

async function fase4_verificarNotificacoes(rideId) {
  console.log(colors.bold.cyan("\n📢 FASE 4: Verificar Notificações para Motoristas"));

  try {
    log("debug", `Aguardando criação de ride_notifications para corrida ${rideId}...`);

    // Aguardar um pouco para Cloud Function executar
    await sleep(3000);

    const query = db
      .collection("ride_notifications")
      .where("rideId", "==", rideId);

    const snapshot = await query.get();

    if (snapshot.empty) {
      log("warning", "Nenhuma notificação de motorista criada");
      return null;
    }

    const notification = snapshot.docs[0];
    const data = notification.data();

    log("success", `Notificações criadas: ${snapshot.size}`);
    log("info", `Motoristas notificados: ${data.driversNotified}`);
    log("info", `Status: ${data.status}`);
    log("info", `Processado em: ${data.processedAt?.toDate()}`);

    return {
      notificationId: notification.id,
      ...data,
    };
  } catch (error) {
    log("error", `Erro ao verificar notificações: ${error.message}`);
    return null;
  }
}

// ============================================================================
// FASE 5: MOTORISTA ACEITA CORRIDA
// ============================================================================

async function fase5_motoristaaAceitaCorrida(rideId, driverId) {
  console.log(colors.bold.cyan("\n✅ FASE 5: Motorista Aceita Corrida"));

  try {
    await db.collection("rides").doc(rideId).update({
      status: "assigned",
      assignedDriverId: driverId,
      assignedAt: new Date(),
    });

    log("success", "Corrida atribuída ao motorista");

    return true;
  } catch (error) {
    log("error", `Erro ao aceitar corrida: ${error.message}`);
    return false;
  }
}

// ============================================================================
// FASE 6: VERIFICAR NOTIFICAÇÃO PARA USUÁRIO
// ============================================================================

async function fase6_verificarNotificacaoUsuario(userId) {
  console.log(colors.bold.cyan("\n📲 FASE 6: Verificar Notificação para Usuário"));

  try {
    await sleep(2000); // Aguardar Cloud Function

    const query = db
      .collection("notifications")
      .where("userId", "==", userId)
      .where("type", "==", "status_corrida")
      .orderBy("createdAt", "desc")
      .limit(1);

    const snapshot = await query.get();

    if (snapshot.empty) {
      log("warning", "Nenhuma notificação de status criada para o usuário");
      return null;
    }

    const notification = snapshot.docs[0];
    const data = notification.data();

    log("success", "Notificação de status criada");
    log("info", `Tipo: ${data.type}`);
    log("info", `Título: ${data.title}`);
    log("info", `Corpo: ${data.body}`);
    log("info", `Enviada: ${data.sent}`);

    return {
      notificationId: notification.id,
      ...data,
    };
  } catch (error) {
    log("error", `Erro ao verificar notificação: ${error.message}`);
    return null;
  }
}

// ============================================================================
// FASE 7: INICIAR CORRIDA
// ============================================================================

async function fase7_iniciarCorrida(rideId) {
  console.log(colors.bold.cyan("\n🚙 FASE 7: Motorista Inicia Corrida"));

  try {
    await db.collection("rides").doc(rideId).update({
      status: "in_progress",
      startedAt: new Date(),
    });

    log("success", "Corrida iniciada");
    return true;
  } catch (error) {
    log("error", `Erro ao iniciar corrida: ${error.message}`);
    return false;
  }
}

// ============================================================================
// FASE 8: COMPLETAR CORRIDA
// ============================================================================

async function fase8_completarCorrida(rideId) {
  console.log(colors.bold.cyan("\n🏁 FASE 8: Motorista Completa Corrida"));

  try {
    await db.collection("rides").doc(rideId).update({
      status: "completed",
      completedAt: new Date(),
      finalPrice: 48.75,
    });

    log("success", "Corrida completada");
    return true;
  } catch (error) {
    log("error", `Erro ao completar corrida: ${error.message}`);
    return false;
  }
}

// ============================================================================
// VERIFICAR FIRESTORE
// ============================================================================

async function verificarFirestore(rideId, userId, driverId) {
  console.log(colors.bold.cyan("\n📊 Verificação Final - Firestore"));

  try {
    // Ride
    const rideDoc = await db.collection("rides").doc(rideId).get();
    if (rideDoc.exists) {
      const rideData = rideDoc.data();
      log("success", `Corrida status final: ${rideData.status}`);
    }

    // User
    const userDoc = await db.collection("users").doc(userId).get();
    if (userDoc.exists) {
      log("success", `Usuário status: ativo`);
    }

    // Driver
    const driverDoc = await db.collection("drivers").doc(driverId).get();
    if (driverDoc.exists) {
      log("success", `Motorista status: ativo`);
    }

    // Notifications
    const notifSnapshot = await db
      .collection("notifications")
      .where("userId", "in", [userId, driverId])
      .get();

    log("success", `Total de notificações: ${notifSnapshot.size}`);

    return true;
  } catch (error) {
    log("error", `Erro na verificação: ${error.message}`);
    return false;
  }
}

// ============================================================================
// RELATÓRIO FINAL
// ============================================================================

function relatorioFinal(resultado) {
  console.log(colors.bold.cyan("\n" + "=".repeat(60)));
  console.log(colors.bold.cyan("📋 RELATÓRIO FINAL DO TESTE"));
  console.log(colors.bold.cyan("=".repeat(60)));

  const status = resultado.sucesso ? colors.green("✅ PASSOU") : colors.red("❌ FALHOU");
  console.log(`\nStatus Geral: ${status}`);

  console.log(colors.gray("\nDetalhes:"));
  console.log(`  • Ambiente: ${AMBIENTE}`);
  console.log(`  • Data: ${new Date().toLocaleString("pt-BR")}`);
  console.log(`  • Duração: ${resultado.duracao}ms`);
  console.log(`  • Usuário ID: ${resultado.usuarioId || "N/A"}`);
  console.log(`  • Motorista ID: ${resultado.motoristaId || "N/A"}`);
  console.log(`  • Corrida ID: ${resultado.corridaId || "N/A"}`);

  if (resultado.erros.length > 0) {
    console.log(colors.red("\n⚠️  Erros encontrados:"));
    resultado.erros.forEach((erro) => {
      console.log(colors.red(`  • ${erro}`));
    });
  }

  console.log("\n" + "=".repeat(60));
}

// ============================================================================
// MAIN
// ============================================================================

async function main() {
  const inicio = Date.now();
  const resultado = {
    sucesso: false,
    duracao: 0,
    usuarioId: null,
    motoristaId: null,
    corridaId: null,
    erros: [],
  };

  console.log(colors.bold.cyan(`\n🚀 Teste de Integração - Clone Uber (${AMBIENTE})`));
  console.log(colors.gray("Use Ctrl+C para cancelar\n"));

  // Inicializar Firebase
  if (!initFirebase()) {
    processo.exit(1);
  }

  try {
    // Fase 1: Criar Usuário
    const usuario = await fase1_criarUsuario();
    if (!usuario) {
      resultado.erros.push("Falha ao criar usuário");
      return;
    }
    resultado.usuarioId = usuario.uid;

    // Fase 2: Criar Motorista
    const motorista = await fase2_criarMotorista();
    if (!motorista) {
      resultado.erros.push("Falha ao criar motorista");
      return;
    }
    resultado.motoristaId = motorista.uid;

    // Fase 3: Criar Corrida
    const corrida = await fase3_criarCorrida(usuario.uid);
    if (!corrida) {
      resultado.erros.push("Falha ao criar corrida");
      return;
    }
    resultado.corridaId = corrida.rideId;

    // Fase 4: Verificar Notificações
    const rideNotif = await fase4_verificarNotificacoes(corrida.rideId);
    if (!rideNotif) {
      resultado.erros.push("Nenhuma notificação de motorista criada");
    }

    // Fase 5: Motorista Aceita
    const aceito = await fase5_motoristaaAceitaCorrida(corrida.rideId, motorista.uid);
    if (!aceito) {
      resultado.erros.push("Falha ao aceitar corrida");
    }

    // Fase 6: Verificar Notificação Usuário
    const userNotif = await fase6_verificarNotificacaoUsuario(usuario.uid);
    if (!userNotif) {
      resultado.erros.push("Nenhuma notificação de status para usuário");
    }

    // Fase 7: Iniciar Corrida
    const iniciada = await fase7_iniciarCorrida(corrida.rideId);
    if (!iniciada) {
      resultado.erros.push("Falha ao iniciar corrida");
    }

    // Fase 8: Completar Corrida
    const completa = await fase8_completarCorrida(corrida.rideId);
    if (!completa) {
      resultado.erros.push("Falha ao completar corrida");
    }

    // Verificação Final
    await verificarFirestore(corrida.rideId, usuario.uid, motorista.uid);

    resultado.sucesso = resultado.erros.length === 0;
  } catch (error) {
    log("error", `Erro inesperado: ${error.message}`);
    resultado.erros.push(error.message);
  } finally {
    resultado.duracao = Date.now() - inicio;
    relatorioFinal(resultado);
    rl.close();
  }
}

// Executar
main().catch(console.error);
