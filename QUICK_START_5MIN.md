# ⚡ INÍCIO RÁPIDO EM 5 MINUTOS

## 🚀 30 Segundos

```
1. Leia isto
2. Execute: node check_prerequisites.js
3. Pronto!
```

---

## 1️⃣ Terminal 1: Validar Ambiente

```bash
cd c:\Users\MAC\Documents\GitHub\clone_uber_app
node check_prerequisites.js
```

Esperado: ✅ Verde em tudo

---

## 2️⃣ Terminal 2: Logs do Firebase

```bash
firebase functions:log
```

Deixe rodando enquanto executa os testes

---

## 3️⃣ Terminal 3: Users App

```bash
cd apps/users_app
flutter run
```

Escolha a opção do seu dispositivo/emulador

---

## 4️⃣ Terminal 4: Drivers App

```bash
cd apps/drivers_app
flutter run
```

Escolha a opção do seu dispositivo/emulador

---

## 5️⃣ Teste (no App)

### Users App:
```
1. Login / Create Account
2. Toque "Create Ride"
3. Escolha localização
4. Confirmar
5. Espere motorista aceitar
6. Ride começar
7. Rate driver
```

### Drivers App (outro dispositivo/emulador):
```
1. Login com outra conta
2. Toque "Go Online"
3. Espere notificação
4. Toque "Accept"
5. Navigate para pickup
6. Start Ride
7. Navigate para dropoff
8. Complete Ride
```

---

## ✅ Sucesso

Se você conseguiu:
- ✓ Criar corrida
- ✓ Motorista recebeu notificação
- ✓ Motorista aceitou
- ✓ Ride começou
- ✓ Ride completou
- ✓ Avaliação salva

**PARABÉNS! Fluxo completo funciona! 🎉**

---

## 🆘 Algo Quebrou?

### Problema: "Token not found"
```bash
# Solução:
1. Abre Firebase Console
2. Go to Settings (gear icon)
3. Delete project and recreate
4. Run: flutter clean && flutter pub get
```

### Problema: "Cloud Function error"
```bash
# Solução:
firebase functions:log  # Veja o erro
# Normalmente é permissão de Firestore
# Abre Firebase Console → Firestore → Security
```

### Problema: "Notification not received"
```bash
# Solução:
1. Verify FCM token saved:
   - Firebase Console → Firestore → drivers collection
   - Check if fcmToken exists
2. Check function logs:
   - firebase functions:log
```

---

## 📊 Verificar Dados

### Firebase Console
```
1. Go to: https://console.firebase.google.com
2. Select: Your Project
3. Firestore Database:
   - Check "rides" collection
   - Check "notifications" collection
   - Check "drivers" online status
4. Cloud Functions:
   - Check execution logs
   - Check performance
```

---

## 📱 Verificar Apps

### Users App - Home Screen
```
Should show:
- User name
- "Create Ride" button
- Ride history
```

### Drivers App - Home Screen
```
Should show:
- Driver name
- Online/Offline toggle
- Available rides count
- Current ride status
```

### Admin Panel
```
Open: http://localhost:8888
Should show:
- Dashboard with metrics
- Recent rides
- Active drivers
```

---

## ⏱️ Tempos Esperados

```
Create Ride:        2-3 seconds
Notification Sent:  1-2 seconds
Driver Accepts:     Instant
Start Ride:         Instant
Complete Ride:      Instant
Rate Driver:        Instant
Data in Firestore:  <1 second
Admin Update:       <5 seconds
```

---

## 🔄 Teste Novamente?

```bash
# Volte ao passo 5️⃣ Teste (no App)
# Você pode criar múltiplas corridas
# Cada uma será um novo teste
```

---

## 📚 Quer Mais Detalhes?

```
Quick Reference:    TESTING_COMMANDS.md
Passo-a-passo:      INTEGRATION_TEST_MANUAL.md
Plano completo:     INTEGRATION_TEST_PLAN.md
Índice:             INDEX_TESTING_FRAMEWORK.md
Mapa Mental:        MAP_MENTAL_TESTES.md
Status Final:       FINAL_STATUS.md
```

---

## ✨ Dicas Pro

```
💡 Dica 1: Use 2 emuladores, não dispositivos físicos (mais rápido)
💡 Dica 2: Abra Firebase Console em outra aba (veja dados em tempo real)
💡 Dica 3: Veja logs do Firebase durante teste (firebase functions:log)
💡 Dica 4: Se erro, procure em troubleshooting docs
💡 Dica 5: Cada ride é um novo teste completo
```

---

## 🎯 Meta

**Seu objetivo: Completar 1 ride do início ao fim**

Quando conseguir:
1. ✅ Ride criada
2. ✅ Motorista notificado
3. ✅ Motorista aceitou
4. ✅ Ride em andamento
5. ✅ Ride completada
6. ✅ Avaliação salva

---

**Tempo Total: ~20 minutos**

**Status: Você pode começar AGORA! 🚀**

```bash
node check_prerequisites.js
```
