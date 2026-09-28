# ☁️ Cloud Functions - Guia de Deployment

## 📋 Visão Geral

Este projeto implementa 5 Cloud Functions que gerenciam notificações em tempo real:

1. **sendRideStatusNotification** - Enviar notificações de status para usuários
2. **notifyNearbyDrivers** - Notificar drivers próximos sobre novas corridas
3. **cleanupOldNotifications** - Deletar notificações >30 dias
4. **cleanupOldRideNotifications** - Deletar ride_notifications >24h
5. **retryFailedNotifications** - Reenviar notificações não entregues

---

## 🔧 Pré-requisitos

### 1. Firebase Project Setup
```bash
# Verificar se já tem firebase-tools instalado
firebase --version

# Se não tiver, instalar globalmente
npm install -g firebase-tools

# Fazer login
firebase login
```

### 2. Inicializar Firebase Functions
```bash
cd functions
npm install
```

### 3. Verificar Plano Firebase
- ⚠️ **Blaze Plan** é necessário para Cloud Functions e Pub/Sub
- Acesse: https://console.firebase.google.com → Upgrade para Blaze
- Será cobrado apenas por uso (pode definir limites)

### 4. Variáveis de Ambiente
```bash
# .env.local (já existe no projeto)
GOOGLE_API_KEY=sua_chave_aqui

# As variáveis de ambiente no Cloud Functions serão definidas via:
firebase functions:config:set
```

---

## 📦 Dependências

### functions/package.json
```json
{
  "dependencies": {
    "firebase-admin": "^12.6.0",
    "firebase-functions": "^7.0.0",
    "axios": "^1.11.0",
    "cors": "^2.8.5",
    "dotenv": "^17.2.1"
  }
}
```

Já estão todas instaladas. Se não:
```bash
cd functions
npm install
```

---

## 🚀 Deployment

### Opção 1: Deploy Completo
```bash
# Da raiz do projeto
firebase deploy --only functions

# Ou específico
firebase deploy --only functions:sendRideStatusNotification
```

### Opção 2: Deploy com Preview
```bash
firebase deploy --only functions --debug
```

### Opção 3: Deploy via GitHub Actions (Recomendado)
Crie `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Firebase Functions

on:
  push:
    branches: [main]
    paths:
      - 'functions/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '22'
      - name: Install dependencies
        run: |
          cd functions
          npm install
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
          projectId: clone-uber-app-XXXXX
```

---

## 🔐 Segurança: Regras Firestore

### Configurar Regras de Segurança
Acesse Firebase Console → Firestore → Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários podem ler/escrever seus próprios dados
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    // Motoristas podem ler/escrever seus próprios dados
    match /drivers/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    // Corridas - usuário pode ler sua corrida
    match /rides/{rideId} {
      allow read: if request.auth.uid == resource.data.userId ||
                     request.auth.uid == resource.data.driverId;
      allow write: if request.auth.uid == resource.data.userId;
    }

    // Notificações - apenas leitura da própria notificação
    match /notifications/{notificationId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null; // Cloud Functions cria
    }

    // Ride notifications - acesso apenas para Cloud Functions
    match /ride_notifications/{rideNotifId} {
      allow read, write: if request.auth == null; // Apenas Cloud Functions
    }

    // Ratings - usuário pode criar/ler suas avaliações
    match /ratings/{ratingId} {
      allow read: if request.auth.uid == resource.data.userId ||
                     request.auth.uid == resource.data.driverId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }

    // Payments - usuário pode ler/criar seus pagamentos
    match /payments/{paymentId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

## 📊 Estrutura das Funções

### 1. sendRideStatusNotification
```
Trigger: notifications/{notificationId} → onCreate
├─ Buscar FCM token do usuário
├─ Validar dados da notificação
├─ Enviar via Firebase Messaging
├─ Atualizar sent = true
└─ Tratamento de erros (token inválido)
```

**Exemplo de Documento:**
```javascript
notifications/notif123 {
  userId: "usuario123"
  rideId: "ride123"
  type: "ride_assigned"
  title: "🚗 Motorista Encontrado!"
  body: "Um motorista foi atribuído..."
  status: "assigned"
  sent: false → true (após função)
  sentAt: Timestamp
  messageId: "abc123" (retorno FCM)
}
```

### 2. notifyNearbyDrivers
```
Trigger: ride_notifications/{notificationId} → onCreate
├─ Buscar drivers online
├─ Filtrar por distância (Haversine)
├─ Enviar notificação para cada driver (batch)
├─ Contar drivers notificados
└─ Marcar processed = true
```

**Exemplo de Documento:**
```javascript
ride_notifications/rideNotif123 {
  rideId: "ride123"
  origin: "Av. Paulista, 1000"
  originLat: -23.5505
  originLng: -46.6333
  rideType: "economy"
  title: "🚗 Nova Corrida!"
  body: "Corrida de economy..."
  processed: false → true
  driversNotified: 5 (após função)
}
```

### 3. cleanupOldNotifications
```
Trigger: Cloud Pub/Sub - Diário às 2 AM (São Paulo)
├─ Buscar notificações >30 dias
├─ Deletar em batch (500 max)
├─ Log de limpeza
```

### 4. cleanupOldRideNotifications
```
Trigger: Cloud Pub/Sub - Horária
├─ Buscar ride_notifications >24h
├─ Deletar em batch (500 max)
├─ Log de limpeza
```

### 5. retryFailedNotifications
```
Trigger: Cloud Pub/Sub - A cada 30 minutos
├─ Buscar notificações não entregues (<24h)
├─ Validar FCM token
├─ Reenviar com incremento de tentativas
```

---

## 🌐 Índices Firestore Recomendados

Para otimizar as queries, criar índices compostos:

### notifications
```
Collection: notifications
- userId (Asc) + createdAt (Desc)
- sent (Asc) + createdAt (Asc)
```

### ride_notifications
```
Collection: ride_notifications
- processed (Asc) + createdAt (Desc)
```

### drivers
```
Collection: drivers
- isOnline (Asc)
```

### Cloud Firestore Indices
https://console.firebase.google.com/project/YOUR_PROJECT/firestore/indexes

---

## 📝 Exemplos de Uso

### Criar Notificação de Status (Automático)
```dart
// Drivers App - AvailableRidesService.acceptRide()
await _firestore.collection('notifications').add({
  'userId': userId,
  'rideId': rideId,
  'type': 'ride_assigned',
  'title': '🚗 Motorista Encontrado!',
  'body': 'Um motorista foi atribuído à sua corrida',
  'status': 'assigned',
  'sent': false,
  'createdAt': DateTime.now(),
});
// → Cloud Function sendRideStatusNotification() processa
```

### Criar Notificação de Nova Corrida (Automático)
```dart
// Users App - RideService.createRideRequest()
await _firestore.collection('ride_notifications').add({
  'rideId': rideId,
  'origin': origin,
  'originLat': originLat,
  'originLng': originLng,
  'rideType': rideType,
  'type': 'new_ride_available',
  'title': '🚗 Nova Corrida Disponível!',
  'body': 'Corrida de $rideType saindo de $origin',
  'createdAt': DateTime.now(),
  'processed': false,
});
// → Cloud Function notifyNearbyDrivers() processa
```

---

## 🧪 Testes

### Teste 1: Simulação Local
```bash
cd functions

# Iniciar emulador
firebase emulators:start

# Em outro terminal
firebase functions:shell

# Testar função
getNotifications()
```

### Teste 2: Teste na Produção
```bash
# Criar documento manualmente no Console Firebase
# notifications/{test-notif}
# Verificar se Cloud Function processa

# Logs
firebase functions:log

# Logs em tempo real
firebase functions:log --follow
```

### Teste 3: Monitorar Execução
```bash
# Firebase Console → Cloud Functions → Logs
# https://console.cloud.google.com/functions/details/YOUR_REGION/sendRideStatusNotification
```

---

## 📊 Monitoramento

### Cloud Functions Monitoring
1. Acesse: https://console.cloud.google.com/functions
2. Selecione a função
3. Abas disponíveis:
   - **Logs** - Ver execuções
   - **Metrics** - Tempo, erros, invocações
   - **Triggers** - Ver triggers ativos

### Logs via CLI
```bash
# Todos os logs
firebase functions:log

# Logs de uma função específica
firebase functions:log --follow

# Com filtro
firebase functions:log | grep "sendRideStatusNotification"
```

### Alertas recomendados
Configure em Cloud Console → Cloud Monitoring:
- Error Rate > 5%
- Execution Time > 30s
- Memory Usage > 80%

---

## 🐛 Troubleshooting

### Erro: "Permission denied on resource"
**Solução:** Verificar Firestore Rules - Cloud Functions precisa de acesso irrestrito

```javascript
// Adicione após autenticação do usuário
match /{document=**} {
  allow read, write: if request.auth == null; // Cloud Functions
  allow read, write: if request.auth != null; // Usuários autenticados
}
```

### Erro: "FCM token is invalid"
**Solução:** Token expirou - Cloud Function deleta automaticamente

```javascript
if (error.code === "messaging/invalid-registration-token") {
  // Deletar token inválido
  await db.collection("users").doc(userId).update({
    fcmToken: admin.firestore.FieldValue.delete(),
  });
}
```

### Erro: "Quota exceeded"
**Solução:** Aumentar limite ou usar batch processing

```javascript
// Já implementado - processa 10 drivers por vez
const batchSize = 10;
for (let i = 0; i < driversToNotify.length; i += batchSize) {
  // ...
}
```

### Função não está sendo acionada
**Verificar:**
1. Documento foi criado corretamente?
2. Caminho está correto? (`notifications/{id}`)
3. Função foi deployada? (`firebase deploy --only functions`)
4. Logs mostram erro? (`firebase functions:log`)

---

## 📈 Performance

### Otimizações Implementadas

1. **Batch Processing** - Processa drivers em lotes de 10
2. **Índices Compostos** - Queries mais rápidas
3. **Cleanup Automático** - Evita crescimento ilimitado de dados
4. **Retry Logic** - Tenta reenviar notificações falhadas
5. **Error Handling** - Não para em erro, continua com próxima

### Custos Estimados (Blaze Plan)

| Item | Custo |
|------|-------|
| 1.000 invocações/dia | $0.00 (grátis) |
| 10.000 invocações/dia | ~$0.10 |
| 100.000 invocações/dia | ~$1.00 |
| Firestore: 1M operações/dia | ~$0.50 |

---

## 🚀 Próximas Fases

1. **Analytics** - Rastrear taxa de entrega de notificações
2. **Templates** - Notificações dinâmicas por tipo de evento
3. **Segmentação** - Enviar apenas para drivers específicos (certificação, vehicle type)
4. **A/B Testing** - Testar diferentes mensagens
5. **Webhook** - Integração com sistemas externos (CRM, analytics)

---

## 📚 Referências

- Firebase Cloud Functions: https://firebase.google.com/docs/functions
- Firebase Cloud Messaging: https://firebase.google.com/docs/cloud-messaging
- Firestore Triggers: https://firebase.google.com/docs/firestore/extend-with-functions
- Pub/Sub Scheduling: https://cloud.google.com/scheduler/docs

---

## ✅ Checklist de Deployment

- [ ] Upgrade para Blaze Plan
- [ ] `npm install` em `functions/`
- [ ] Verificar `.env.local` com GOOGLE_API_KEY
- [ ] Configurar Firestore Rules
- [ ] Criar índices recomendados
- [ ] `firebase deploy --only functions`
- [ ] Verificar `firebase functions:log`
- [ ] Teste: Criar notificação no Console Firebase
- [ ] Verificar se app recebeu notificação
- [ ] Monitorar Cloud Functions Metrics

---

## 📞 Suporte

Se encontrar erros:
1. Verificar `firebase functions:log`
2. Verificar Firestore Rules
3. Verificar índices estão criados
4. Verificar FCM tokens estão salvos em Firestore
5. Verificar documentos estão no caminho correto

Commits relacionados:
- `da7106a` - Notificação: Nova Corrida Disponível
- `9f9c1b2` - Notificação: Status da Corrida
- `[novo]` - Cloud Functions: Sistema de notificações automático
