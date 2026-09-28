# 🧪 Plano de Teste de Integração Completo - Clone Uber

## Objetivo
Validar o fluxo completo de uma corrida: **Usuário → Corrida → Motorista → Notificações → Status Updates**

---

## 📋 Pré-Requisitos

### ✅ Verificações Iniciais
- [ ] Firebase Project está configurado e acessível
- [ ] Cloud Functions estão deployados (`firebase deploy --only functions`)
- [ ] Firestore está em modo produção/teste com segurança configurada
- [ ] Firebase Authentication está habilitado
- [ ] Cloud Messaging (FCM) está habilitado
- [ ] users_app está compilada e pronta
- [ ] drivers_app está compilada e pronta
- [ ] admin_web_panel está rodando em http://localhost:8888

---

## 🎯 Cenário de Teste 1: Fluxo Básico de Corrida

### Fase 1: Setup Inicial

**Passos:**
1. Abrir Admin Web Panel (http://localhost:8888)
2. Verificar estatísticas iniciais no dashboard
3. Abrir Firebase Console em outra aba

### Fase 2: Usuário Cria Corrida

**Ator:** User A (usando users_app)

**Fluxo:**
1. Fazer login na users_app (ou criar conta se for teste novo)
2. Autorizar localização
3. Preencher endereço de origem (ex: "Rua A, 100")
4. Preencher endereço de destino (ex: "Rua B, 200")
5. Confirmar corrida e fazer oferta de preço

**Validações Esperadas:**
- ✅ Corrida criada em Firestore (`rides/{rideId}`)
- ✅ Status: `pending`
- ✅ Localização capturada (lat/lng)
- ✅ Timestamp criado
- ✅ User ID associado

**Logs para Verificar:**
```
Firestore Collection: rides
Document Fields:
- userId: "user_a_id"
- status: "pending"
- origin: {lat: X, lng: Y}
- destination: {lat: X, lng: Y}
- createdAt: timestamp
- estimatedPrice: número
```

### Fase 3: Cloud Function Dispara Notificação de Novos Motoristas

**Ator:** Sistema (Cloud Function `notifyNearbyDrivers`)

**Fluxo:**
1. `notifyNearbyDrivers` é acionado automaticamente por Firestore trigger
2. Função consulta drivers online (`drivers/{driverId}` com `isOnline: true`)
3. Calcula distância usando Haversine (raio: 5km)
4. Cria `ride_notifications` para cada driver próximo
5. Envia mensagem FCM

**Validações Esperadas:**
- ✅ Documento criado em `ride_notifications/{notificationId}`
- ✅ Campo `driversNotified` > 0 (se houver drivers próximos)
- ✅ Timestamp `processedAt` registrado
- ✅ Status: `sent` ou `pending`

**Logs para Verificar:**
```
Firestore Collection: ride_notifications
Document Fields:
- rideId: "ride_id_da_corrida"
- driversNotified: número (ex: 2, 3, etc)
- processedAt: timestamp
- createdAt: timestamp
```

### Fase 4: Motorista Recebe Notificação

**Ator:** Driver B (usando drivers_app)

**Pré-requisitos:**
- Driver B estar online no app
- Device estar próximo (< 5km do usuário)
- FCM token registrado no Firestore

**Fluxo:**
1. App mantém `drivers/{driverId}` com `isOnline: true`
2. Recebe notificação push via FCM
3. Exibe alerta: "Nova corrida disponível perto de você"
4. Driver vê detalhes da corrida

**Validações Esperadas:**
- ✅ Notificação recebida no device (push notification)
- ✅ App abre tela de "Corridas Disponíveis"
- ✅ Corrida listada com dados: origem, destino, preço, distância
- ✅ Botão "Aceitar" disponível

**Logs para Verificar:**
```
Firestore Collection: notifications/{notificationId}
Document Fields:
- userId: "driver_b_id"
- type: "nova_corrida_disponivel"
- rideId: "ride_id"
- sent: true
- deliveredAt: timestamp (se houver)
```

### Fase 5: Motorista Aceita Corrida

**Ator:** Driver B

**Fluxo:**
1. Driver vê corrida na lista
2. Clica em "Aceitar"
3. Sistema atualiza corrida:
   - `status: pending` → `assigned`
   - `assignedDriverId: driver_b_id`
   - `assignedAt: timestamp`
4. Notificações são enviadas (cloud function)

**Validações Esperadas:**
- ✅ Documento `rides/{rideId}` atualizado
- ✅ `status: "assigned"`
- ✅ `assignedDriverId: "driver_b_id"`
- ✅ Notificação criada: `notifications/{notId}` para User A
- ✅ User A recebe notificação push

**Logs para Verificar:**
```
Firestore:
rides/{rideId}:
- status: "assigned"
- assignedDriverId: "driver_b_id"
- assignedAt: timestamp

notifications/{notId}:
- userId: "user_a_id"
- type: "motorista_aceito"
- driverId: "driver_b_id"
- sent: true
```

### Fase 6: User A Recebe Notificação de Aceitação

**Ator:** User A (users_app)

**Fluxo:**
1. Recebe notificação push
2. App atualiza tela: "Motorista X aceitou sua corrida"
3. Mostra informações do motorista (nome, foto, avaliação)
4. Mostra localização do motorista no mapa

**Validações Esperadas:**
- ✅ Notificação recebida
- ✅ Dados do motorista exibidos
- ✅ Tela muda para "Motorista a Caminho"
- ✅ Localização atualiza em tempo real

### Fase 7: Motorista Inicia Corrida

**Ator:** Driver B

**Fluxo:**
1. Driver clica em "Iniciar Corrida"
2. Sistema atualiza:
   - `status: assigned` → `in_progress`
   - `startedAt: timestamp`
3. Cloud function dispara notificação para User A

**Validações Esperadas:**
- ✅ `rides/{rideId}.status: "in_progress"`
- ✅ `startedAt` timestamp registrado
- ✅ Notificação para User A criada

### Fase 8: Motorista Completa Corrida

**Ator:** Driver B

**Fluxo:**
1. Driver chega ao destino
2. Clica em "Finalizar Corrida"
3. Sistema calcula tarifa final
4. Status muda: `in_progress` → `completed`
5. Notificação enviada para User A

**Validações Esperadas:**
- ✅ `status: "completed"`
- ✅ `completedAt: timestamp`
- ✅ `finalPrice: número`
- ✅ Notificação para User A

### Fase 9: User A Avalia Motorista

**Ator:** User A

**Fluxo:**
1. App exibe tela de avaliação
2. User dá 5 estrelas e comenta
3. Submete avaliação

**Validações Esperadas:**
- ✅ Documento de avaliação criado
- ✅ Rating salvo em `rides/{rideId}.userRating`

---

## 📊 Checklist de Validações

### Firestore Collections
- [ ] **rides** - Corridas criadas com status correto
- [ ] **ride_notifications** - Notificações de novos motoristas
- [ ] **notifications** - Notificações para usuários e motoristas
- [ ] **drivers** - Status isOnline atualizado
- [ ] **users** - FCM tokens salvos

### Cloud Functions Execution
- [ ] **notifyNearbyDrivers** - Disparada ao criar corrida
- [ ] **sendRideStatusNotification** - Disparada ao criar notification
- [ ] **retryFailedNotifications** - Tenta novamente falhas (30 min)
- [ ] **cleanupOldNotifications** - Limpa notifications antigas

### Firebase Console Logs
- [ ] Nenhum erro critical
- [ ] Funções completam em < 5 segundos
- [ ] Writes no Firestore dentro do esperado
- [ ] FCM messages enviadas com sucesso

### App Behavior
- [ ] Users_app consegue criar corrida
- [ ] Drivers_app recebe notificação
- [ ] Drivers_app consegue aceitar
- [ ] Users_app recebe update de status
- [ ] Mapa atualiza em tempo real
- [ ] Todas as transições de status funcionam

---

## 🚨 Possíveis Problemas e Soluções

| Problema | Causa Provável | Solução |
|----------|----------------|---------|
| Notificação não chega | FCM token não salvo | Verificar Firestore `users/{userId}.fcmToken` |
| Motorista não vê corrida | Drivers online < 5km | Aumentar raio em notifyNearbyDrivers (linha ~180) |
| Corrida não muda status | Erro no Firestore | Verificar regras de segurança em Firebase Console |
| Cloud Function falha | Erro de privilégio | Verificar permissões de admin do Firebase |
| Notificação duplicada | Retry executado | Verificar retryFailedNotifications, marca como `sent: true` |

---

## 📝 Template de Resultado

**Data do Teste:** `[data]`  
**Duração:** `[tempo total]`  
**Ambiente:** `Firebase Staging/Production`

### Resultado Geral
- [ ] ✅ **PASSOU** - Todos os passos funcionaram
- [ ] ⚠️ **PASSOU COM AVISOS** - Funcionou mas com problemas menores
- [ ] ❌ **FALHOU** - Parou em algum passo

### Detalhes por Fase

| Fase | Status | Tempo | Observações |
|------|--------|-------|-------------|
| 1. Setup | ✅ | 2min | - |
| 2. User cria corrida | ✅ | 30s | - |
| 3. Cloud Function | ✅ | 2s | 2 drivers notificados |
| 4. Driver recebe | ✅ | 1s | Notificação imediata |
| 5. Driver aceita | ✅ | 45s | - |
| 6. User notificado | ✅ | 1s | - |
| 7. Inicia corrida | ✅ | 30s | - |
| 8. Completa corrida | ✅ | 2min | - |
| 9. Avalia | ✅ | 1min | - |

### Issues Encontrados
```
1. [Descrição]
   - Severidade: [Critical/High/Medium/Low]
   - Solução: [Como resolver]

2. ...
```

### Performance Metrics
- Tempo total: `X minutos`
- Mensagens FCM enviadas: `X`
- Documentos Firestore criados: `X`
- Erros observados: `X`

---

## 🔄 Teste de Carga (Fase 2)

**Quando:** Após teste básico passar

**Objetivo:** Validar sistema com múltiplas corridas simultâneas

**Dados:**
- 5 usuários criando corridas
- 10 motoristas online esperando
- Executar por 15 minutos

**Validações:**
- Nenhum timeout
- Nenhuma duplicação de notificação
- Firestore quota não excedida
- Cloud Functions executam sem falha

---

## 📞 Pontos de Contato

- **Firebase Console:** https://console.firebase.google.com
- **Cloud Functions Logs:** Cloud Functions → Function → Logs
- **Firestore:** Cloud Firestore → Data
- **Documentation:** `/docs` pasta do projeto

