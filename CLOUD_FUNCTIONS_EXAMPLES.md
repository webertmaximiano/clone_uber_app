# 📚 Cloud Functions - Exemplos Práticos

## Exemplo 1: Fluxo Completo de Notificação

### Cenário: Usuário solicita corrida, motorista aceita

```
[Users App]
    ↓
RideService.createRideRequest()
    ↓
rides/{id} com status="pending"
    ↓
_notifyNearbyDrivers() cria documento
    ↓
[Firestore]
ride_notifications/notif1 {
  rideId: "ride123"
  originLat: -23.5505
  originLng: -46.6333
  processed: false ← TRIGGER
}
    ↓
[Cloud Functions]
notifyNearbyDrivers() acionado
    ↓
    ├─ Buscar drivers online
    ├─ Calcular distância (Haversine)
    ├─ Se dist ≤ 5km → Enviar FCM
    └─ Atualizar processed: true
    ↓
[Drivers App]
Recebe notificação: "🚗 Nova Corrida Disponível!"
    ↓
Motorista clica "Aceitar"
    ↓
AvailableRidesService.acceptRide()
    ↓
rides/{id} → status="assigned"
    ↓
_sendRideStatusNotification() cria documento
    ↓
[Firestore]
notifications/notif2 {
  userId: "usuario123"
  rideId: "ride123"
  type: "ride_assigned"
  sent: false ← TRIGGER
}
    ↓
[Cloud Functions]
sendRideStatusNotification() acionado
    ↓
    ├─ Buscar FCM token do usuário
    ├─ Enviar mensagem: "🚗 Motorista Encontrado!"
    └─ Atualizar sent: true
    ↓
[Users App]
Recebe notificação + RideTrackingScreen atualiza
```

## Exemplo 2: Limpeza Automática (Scheduler)

```javascript
// Executado AUTOMATICAMENTE todos os dias às 2 AM
exports.cleanupOldNotifications = functions.pubsub
  .schedule("0 2 * * *")
  .timeZone("America/Sao_Paulo")
  .onRun(async (context) => {
    // Buscar notificações criadas há >30 dias
    const oldDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    
    const snapshot = await db
      .collection("notifications")
      .where("createdAt", "<", oldDate)
      .limit(500)
      .get();
    
    // Deletar em batch
    const batch = db.batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    
    // Log
    console.log(`Deletadas ${snapshot.docs.length} notificações antigas`);
  });

// Resultado: Reduz tamanho do banco de dados, economiza custos
```

## Exemplo 3: Retry de Notificações Falhadas

```javascript
// Executado AUTOMATICAMENTE a cada 30 minutos
exports.retryFailedNotifications = functions.pubsub
  .schedule("*/30 * * * *")
  .timeZone("America/Sao_Paulo")
  .onRun(async (context) => {
    // Buscar notificações não entregues (<24h)
    const snapshot = await db
      .collection("notifications")
      .where("sent", "==", false)
      .where("createdAt", ">", new Date(Date.now() - 24 * 60 * 60 * 1000))
      .limit(100)
      .get();
    
    let retriedCount = 0;
    
    for (const doc of snapshot.docs) {
      const notif = doc.data();
      
      try {
        // Tentar enviar novamente
        const user = await db.collection("users").doc(notif.userId).get();
        const token = user.data()?.fcmToken;
        
        if (token) {
          await messaging.send({
            notification: { title: notif.title, body: notif.body },
            token: token
          });
          
          // Marcar como enviada
          await doc.ref.update({
            sent: true,
            retriedCount: (notif.retriedCount || 0) + 1
          });
          
          retriedCount++;
        }
      } catch (error) {
        console.warn(`Falha ao reenviar: ${error.message}`);
      }
    }
    
    console.log(`${retriedCount} notificações reenviadas`);
  });
```

## Exemplo 4: Testar Localmente

```bash
# Terminal 1: Iniciar emuladores
firebase emulators:start

# Output:
# ✔  Firestore Emulator started at http://localhost:8080
# ✔  Functions Emulator started at http://localhost:5001

# Terminal 2: Shell interativo
firebase functions:shell

# Dentro do shell:
> getNotifications()
> db.collection('notifications').add({...})

# A função será acionada no emulador local
```

## Exemplo 5: Monitorar em Produção

```bash
# Ver logs em tempo real
firebase functions:log --follow

# Output esperado:
# sendRideStatusNotification 9fv8tqr2nqbb Function execution started
# sendRideStatusNotification 9fv8tqr2nqbb Processando notificação: ride_assigned para usuario123
# sendRideStatusNotification 9fv8tqr2nqbb Notificação enviada com sucesso: abc123def456
# sendRideStatusNotification 9fv8tqr2nqbb Function execution took 1234 ms, finished with status: 'ok'
```

## Exemplo 6: Debugging - FCM Token Inválido

```javascript
// Quando token é inválido, Cloud Function trata automaticamente

try {
  await messaging.send(message); // Falha!
} catch (error) {
  if (error.code === "messaging/invalid-registration-token") {
    // Deletar token inválido do Firestore
    await db.collection("users").doc(userId).update({
      fcmToken: admin.firestore.FieldValue.delete(),
    });
    console.log(`Token inválido deletado para ${userId}`);
  }
}

// Próxima vez que o app abrir, novo token será gerado e salvo
```

## Exemplo 7: Enviar Notificação Customizada

```dart
// Na sua tela, quando quiser enviar notificação específica
final firestore = FirebaseFirestore.instance;

await firestore.collection('notifications').add({
  'userId': 'usuario123',
  'rideId': 'ride456',
  'type': 'custom_message',
  'title': '💰 Bonus Disponível!',
  'body': 'Você ganhou R\$ 5 de crédito',
  'status': 'custom',
  'sent': false,
  'createdAt': DateTime.now(),
});

// Cloud Function processa automaticamente
// Usuário recebe: "💰 Bonus Disponível! Você ganhou R\$ 5 de crédito"
```

## Exemplo 8: Notificar Drivers Próximos

```dart
// Em RideService.createRideRequest()
await firestore.collection('ride_notifications').add({
  'rideId': rideId,
  'origin': 'Av. Paulista, 1000',
  'originLat': -23.5505,
  'originLng': -46.6333,
  'rideType': 'economy',
  'type': 'new_ride_available',
  'title': '🚗 Nova Corrida Disponível!',
  'body': 'Corrida de economy saindo de Av. Paulista, 1000',
  'createdAt': DateTime.now(),
  'processed': false,
});

// Resultado:
// Cloud Function busca drivers online
// Motorista A em (-23.5520, -46.6340) → 2.1km → Recebe notificação
// Motorista B em (-23.5400, -46.6200) → 18km → NÃO recebe
// Motorista C em (-23.5505, -46.6333) → 0km → Recebe notificação
```

## Exemplo 9: Configurar Cloud Scheduler (Alternativa)

Se preferir usar Cloud Scheduler em vez de Pub/Sub:

```bash
# Criar job para cleanup diário
gcloud scheduler jobs create app-engine daily-cleanup \
  --schedule="0 2 * * *" \
  --timezone="America/Sao_Paulo" \
  --http-method=POST \
  --uri="https://REGION-PROJECT.cloudfunctions.net/cleanupOldNotifications"
```

## Exemplo 10: Tratamento de Erro - Rate Limiting

```javascript
// Implementar rate limiting se necessário
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minuto
  max: 100, // 100 requisições por minuto
});

exports.sendNotification = functions.https.onRequest(
  limiter,
  async (req, res) => {
    // Protegido contra abuso
  }
);
```

---

## 📊 Tabela de Tipos de Notificação

| Tipo | Enviado por | Exemplo |
|------|-----------|---------|
| `new_ride_available` | App (RideListenerService) | "🚗 Nova Corrida Disponível!" |
| `ride_assigned` | Cloud Function | "🚗 Motorista Encontrado!" |
| `ride_started` | Cloud Function | "✅ Corrida Iniciada!" |
| `ride_completed` | Cloud Function | "🎉 Corrida Finalizada!" |
| `ride_cancelled` | App (Users/Drivers) | "❌ Corrida Cancelada" |

---

## 🚀 Performance Tips

1. **Use Batch Processing**: Já implementado (10 drivers por vez)
2. **Use Índices**: Firestore cria automaticamente
3. **Limpar Dados Antigos**: cleanupOldNotifications executa diariamente
4. **Monitorar Quota**: firebase functions:log
5. **Cache**: Reutilizar conexões do Firebase Admin

---

## 🔒 Segurança

### Evitar Notificações Spam
```javascript
// Limitar 1 notificação por ride por motorista
const existingNotif = await db
  .collection('notifications')
  .where('rideId', '==', rideId)
  .where('driverId', '==', driverId)
  .where('createdAt', '>', new Date(Date.now() - 60000)) // Última 1 min
  .limit(1)
  .get();

if (existingNotif.empty) {
  // Enviar notificação
}
```

### Validar Dados
```javascript
// Sempre validar entrada
if (!notification.userId || !notification.rideId) {
  throw new Error('Dados inválidos');
}
```

---

## 📈 Próximas Melhorias

1. Implementar **segmentação** por tipo de veículo
2. Adicionar **prioridade** (HIGH, NORMAL, LOW)
3. Implementar **analytics** de taxa de entrega
4. Adicionar **templates** dinâmicos
5. Integrar com **webhooks** (Slack, Discord)

---

## 📞 Referências

- [Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Firestore Triggers](https://firebase.google.com/docs/firestore/extend-with-functions)
- [Cloud Pub/Sub Scheduling](https://cloud.google.com/scheduler/docs)
