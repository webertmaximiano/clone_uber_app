# Sistema de Notificações Push - Instruções

## Configuração de Notificações Push para Firebase Messaging

Este documento descreve como configurar e usar o sistema de notificações push para o Clone Uber.

---

## 📋 Pré-requisitos

### Android
1. **Firebase Console:**
   - Ir para Project Settings → Cloud Messaging
   - Copiar o Server API Key (será usado nas Cloud Functions)

2. **android/app/build.gradle:**
   ```gradle
   dependencies {
     implementation 'com.google.firebase:firebase-messaging:23.2.1'
   }
   ```

3. **AndroidManifest.xml:**
   ```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
   
   <service android:name="com.google.firebase.messaging.FirebaseMessagingService"
     android:exported="false">
     <intent-filter>
       <action android:name="com.google.firebase.MESSAGING_EVENT" />
     </intent-filter>
   </service>
   ```

### iOS
1. **Capacidades:**
   - Abrir Xcode → Runner project
   - Ir para Signing & Capabilities
   - Adicionar "Push Notifications"

2. **APNs Certificate:**
   - Gerar certificate em Apple Developer
   - Upload em Firebase Console

3. **ios/Podfile:**
   ```ruby
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       flutter_additional_ios_build_settings(target)
       target.build_configurations.each do |config|
         config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
           '$(inherited)',
           'PERMISSION_NOTIFICATIONS=1',
         ]
       end
     end
   end
   ```

---

## 🔧 Instalação de Pacotes

### pubspec.yaml (users_app e drivers_app)

```yaml
dependencies:
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^14.1.0
  cloud_firestore: ^4.9.0
  firebase_auth: ^4.9.0
  firebase_core: ^2.16.0
```

### Instalar pacotes

```bash
flutter pub get
```

---

## 🚀 Como Funciona

### 1. **Inicialização**
- Na inicialização do app, `NotificationService` solicita permissão de notificação
- Obtém o FCM Token do dispositivo
- Salva o token no Firestore sob `users/{userId}/fcmToken`

### 2. **Recebimento de Notificações**

#### Foreground (App aberto)
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Mostrar notificação local
  _showLocalNotification(message);
  // Processar dados
  _handleNotificationData(message.data);
});
```

#### Background/Closed
- Notificação é exibida automaticamente
- Ao clicar, abre o app

#### App Aberto via Notificação
```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Processar dados e navegar
  _handleNotificationData(message.data);
});
```

### 3. **Envio de Notificações**

**Opção 1: Via Cloud Functions (Recomendado)**

Quando motorista aceita corrida:
1. `AvailableRidesService.acceptRide()` cria documento em `notifications/{id}`
2. Cloud Function `onNotificationCreate` é acionada
3. Cloud Function busca FCM token do usuário
4. Cloud Function envia via Firebase Messaging API
5. Usuário recebe notificação

**Opção 2: Via Firebase Console (Teste)**

1. Firebase Console → Cloud Messaging
2. New Campaign → FCM Notification
3. Target específico user com query personalizada
4. Schedule e enviar

---

## 📱 Tipos de Notificações

### Users App
| Tipo | Quando | Título | Corpo |
|------|--------|--------|-------|
| `ride_assigned` | Motorista aceita corrida | "Motorista Encontrado! 🚗" | "Um motorista foi atribuído..." |
| `ride_started` | Motorista inicia corrida | "Motorista a Caminho" | "Seu motorista saiu para buscá-lo" |
| `ride_completed` | Corrida finalizada | "Corrida Concluída ✅" | "Avalie seu motorista" |
| `driver_arrived` | Motorista chegou | "Motorista Chegou 📍" | "Seu motorista está aqui" |

### Drivers App
| Tipo | Quando | Título | Corpo |
|------|--------|--------|-------|
| `new_ride_available` | Nova corrida próxima | "Nova Corrida Disponível 🚗" | "Uma corrida a apenas 2km" |
| `ride_accepted` | Outro motorista aceita | "Corrida Aceita" | "Outro motorista aceitou esta corrida" |
| `user_cancelled` | Usuário cancela corrida | "Corrida Cancelada ❌" | "O usuário cancelou a corrida" |

---

## 🔐 Cloud Functions (Implementação Futura)

### Estrutura de `functions/index.js`

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// Quando documento é criado em /notifications
exports.sendNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    const { userId, title, body, type, rideId } = notification;

    try {
      // 1. Obter FCM Token do usuário
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(userId)
        .get();

      const fcmToken = userDoc.get('fcmToken');
      if (!fcmToken) {
        console.log(`No FCM token for user ${userId}`);
        return;
      }

      // 2. Enviar via Firebase Messaging API
      const response = await admin.messaging().send({
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: type,
          rideId: rideId,
        },
        token: fcmToken,
      });

      // 3. Atualizar documento como enviado
      await snap.ref.update({
        sent: true,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: response,
      });

      console.log(`Notification sent to ${userId}`);
    } catch (error) {
      console.error(`Error sending notification: ${error}`);
      
      // Registrar erro
      await snap.ref.update({
        sent: false,
        error: error.message,
      });
    }
  });
```

### Implementar em `functions/`

```bash
cd functions
npm install firebase-functions firebase-admin
firebase deploy --only functions
```

---

## 🧪 Testes Manuais

### 1. **Teste de Token**
```dart
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
```

### 2. **Teste via Firebase Console**
1. Cloud Messaging → New Campaign
2. Selecionar User UID
3. Send test notification

### 3. **Teste via cURL**
```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT/messages:send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "message": {
      "notification": {
        "title": "Test",
        "body": "Test notification"
      },
      "data": {
        "type": "test"
      },
      "token": "YOUR_FCM_TOKEN"
    }
  }'
```

---

## 📊 Estrutura Firestore

### Coleção: `notifications/`
```json
{
  "userId": "user123",
  "rideId": "ride456",
  "type": "ride_assigned",
  "title": "Motorista Encontrado! 🚗",
  "body": "Um motorista foi atribuído...",
  "sent": false,
  "createdAt": "timestamp",
  "sentAt": "timestamp",
  "error": null
}
```

### Campos dos Usuários
```json
{
  "fcmToken": "abc123def456...",
  "fcmTokenUpdatedAt": "timestamp"
}
```

---

## 🐛 Troubleshooting

### Notificações não chegam
1. ✅ Verificar se permissão foi concedida
2. ✅ Verificar FCM Token no Firestore
3. ✅ Verificar se Cloud Function está ativa
4. ✅ Verificar Cloud Messaging API habilitada

### Token vazio
- Garantir que permissão foi aceita
- Aguardar alguns segundos após permissão

### Notificação background não funciona
- Verificar AndroidManifest.xml (Android)
- Verificar Push Notifications capability (iOS)

---

## 📝 Implementação do Seu Lado

### 1. Usuário solicita corrida
```dart
// RideRequestScreen
await _rideService.createRideRequest(rideRequest);
// Notificação será enviada quando motorista aceitar
```

### 2. Motorista aceita
```dart
// AcceptRideDetailsScreen
await _ridesService.acceptRide(rideId, driverLat, driverLng);
// AvailableRidesService enviará notificação para usuário automaticamente
```

### 3. Receber notificação
```dart
// NotificationService
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Aparecer como notificação local
  _showLocalNotification(message);
  // Processar dados
  _handleNotificationData(message.data);
});
```

---

## ✅ Checklist de Implementação

- [x] NotificationService implementado em users_app
- [x] DriverNotificationService implementado em drivers_app
- [x] Solicitar permissões de notificação
- [x] Salvar FCM Token no Firestore
- [x] Mostrar notificações locais
- [x] Processar dados de notificações
- [ ] Cloud Functions para envio automático
- [ ] Testes em dispositivos reais
- [ ] Tratamento de token expirado
- [ ] Analytics de notificações

---

## 🚀 Próximas Melhorias

1. **Analytics:** Rastrear taxa de entrega e cliques
2. **Segmentação:** Enviar notificações baseado em zona geográfica
3. **A/B Testing:** Testar diferentes títulos e corpo
4. **Silent Notifications:** Atualizar UI sem mostrar notificação
5. **Rich Media:** Notificações com imagens e vídeos

---

**Status:** Implementação básica completa. Cloud Functions pendente.
