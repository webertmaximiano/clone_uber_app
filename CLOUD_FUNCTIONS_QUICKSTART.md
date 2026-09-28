# ⚡ Cloud Functions - Setup Rápido

## 1️⃣ Pré-requisitos (5 min)

```bash
# Instalar Firebase CLI globalmente
npm install -g firebase-tools

# Login
firebase login

# Verificar instalação
firebase --version
firebase projects:list
```

## 2️⃣ Upgrade para Blaze Plan (2 min)

1. Acesse: https://console.firebase.google.com
2. Selecione seu projeto
3. Clique em **"Upgrade"** → Blaze Pay-as-you-go
4. Adicione cartão de crédito
5. Confirme

## 3️⃣ Instalar Dependências (1 min)

```bash
cd functions
npm install
```

## 4️⃣ Configurar Firestore Rules (3 min)

Acesse Firebase Console → Firestore → Rules

Copie e cole:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    // Motoristas
    match /drivers/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    // Corridas
    match /rides/{rideId} {
      allow read: if request.auth.uid == resource.data.userId ||
                     request.auth.uid == resource.data.driverId;
      allow write: if request.auth.uid == resource.data.userId;
    }

    // Notificações (Cloud Functions escreve)
    match /notifications/{id} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }

    // Ride Notifications (Cloud Functions escreve)
    match /ride_notifications/{id} {
      allow read, write: if request.auth == null;
    }

    // Ratings
    match /ratings/{id} {
      allow read: if request.auth.uid == resource.data.userId ||
                     request.auth.uid == resource.data.driverId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }

    // Payments
    match /payments/{id} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## 5️⃣ Criar Índices Firestore (2 min)

Firebase criará automaticamente quando você tentar usar as queries.

Ou criar manualmente em: Cloud Firestore → Indexes

```
notifications: userId + createdAt
notifications: sent + createdAt
ride_notifications: processed + createdAt
drivers: isOnline
```

## 6️⃣ Deploy das Funções (2 min)

```bash
# Da raiz do projeto
firebase deploy --only functions

# Output esperado:
# ✔ Deploy complete!
# Function URL: https://region-project.cloudfunctions.net/functionName
```

## 7️⃣ Verificar Deployment (1 min)

```bash
# Ver logs
firebase functions:log

# Deve aparecer algo como:
# Function execution took X ms
```

## 8️⃣ Testar Manualmente (5 min)

### Opção A: Via Console Firebase

1. Acesse Firebase Console → Firestore
2. Crie novo documento:
   - Collection: `notifications`
   - Documento: Auto-generated
   - Dados:
     ```json
     {
       "userId": "test-user",
       "rideId": "ride123",
       "type": "ride_assigned",
       "title": "🚗 Test",
       "body": "Testing notification",
       "status": "assigned",
       "sent": false,
       "createdAt": <current-timestamp>
     }
     ```
3. Após criar, Cloud Function processa em <5 segundos
4. Se usuário tiver FCM token, verá `sent: true` atualizado

### Opção B: Via Código Dart

```dart
// Em qualquer tela
final firestore = FirebaseFirestore.instance;

await firestore.collection('notifications').add({
  'userId': FirebaseAuth.instance.currentUser!.uid,
  'rideId': 'test-ride-123',
  'type': 'ride_assigned',
  'title': '🚗 Motorista Encontrado!',
  'body': 'Test notification',
  'status': 'assigned',
  'sent': false,
  'createdAt': DateTime.now(),
});

// Verificar logs
// firebase functions:log
```

## ✅ Checklist Final

- [ ] Firebase CLI instalado
- [ ] Blaze Plan ativado
- [ ] `npm install` executado
- [ ] Firestore Rules atualizadas
- [ ] `firebase deploy --only functions` bem-sucedido
- [ ] Índices criados
- [ ] Teste manual passou
- [ ] App recebeu notificação

## 🎉 Pronto!

Cloud Functions está ativo e automático. Agora:

1. **Usuário solicita corrida** → `ride_notifications` criado
2. **Cloud Function processa** → Busca drivers próximos
3. **Drivers recebem notificação** → "🚗 Nova Corrida!"

1. **Motorista aceita** → `notifications` criado
2. **Cloud Function processa** → Envia FCM para usuário
3. **Usuário recebe** → "🚗 Motorista Encontrado!"

## 📊 Monitorar

```bash
# Ver logs em tempo real
firebase functions:log --follow

# Ver estatísticas
# https://console.cloud.google.com/functions
```

## 🐛 Se algo não funcionar

```bash
# 1. Verificar se função foi deployada
firebase functions:list

# 2. Ver logs detalhados
firebase functions:log --follow

# 3. Verificar Firestore Rules
# Firebase Console → Firestore → Rules

# 4. Verificar se usuário tem FCM token em Firestore
# users/{uid}/fcmToken

# 5. Redeploy
firebase deploy --only functions --force
```

---

**Tempo total de setup: ~20 minutos**

Tudo pronto? Veja [CLOUD_FUNCTIONS_GUIDE.md](CLOUD_FUNCTIONS_GUIDE.md) para documentação completa!
