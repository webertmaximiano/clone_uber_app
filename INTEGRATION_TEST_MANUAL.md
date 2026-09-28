# 🧪 Guia Prático: Teste de Integração Completo

## ⏱️ Tempo Estimado
- **Setup**: 5 minutos
- **Execução**: 15-20 minutos
- **Total**: ~25 minutos

---

## 📋 Checklist Pré-Teste

Antes de começar, verifique:

```bash
# 1. Cloud Functions deployados
firebase deploy --only functions

# 2. Firebase CLI conectado
firebase login

# 3. Admin Panel rodando
# (em outro terminal) cd apps/admin_web_panel/build/web
# python -m http.server 8888

# 4. Users App e Drivers App disponíveis
# Compiladas para Android/iOS ou emulador
```

---

## 🚀 Passo a Passo do Teste Manual

### PASSO 1️⃣ - Preparar Ambiente (2 min)

**Abra estas abas/janelas:**

1. **Firebase Console** (prod)
   ```
   https://console.firebase.google.com/project/[seu-projeto]
   ```
   - Clique em "Cloud Firestore" 
   - Deixe em aberto lado a lado

2. **Admin Dashboard**
   ```
   http://localhost:8888
   ```
   - Monitore as estatísticas em tempo real

3. **Terminal 1** (Cloud Functions Logs)
   ```bash
   firebase functions:log
   ```
   - Veja os logs das Cloud Functions em tempo real

4. **Terminal 2** (para comandos)
   - Para executar firebase commands

5. **Emulador Android 1** (Users App)
   - App do passageiro
   
6. **Emulador Android 2** (Drivers App)
   - App do motorista

**Disposição sugerida:**
```
┌─────────────────┬─────────────────┐
│  Firebase Logs  │  Admin Panel     │
├─────────────────┼─────────────────┤
│  Users App      │  Drivers App    │
├─────────────────┴─────────────────┤
│  Firebase Console (Firestore)     │
└───────────────────────────────────┘
```

---

### PASSO 2️⃣ - Login dos Usuários (3 min)

#### Users App (Passageiro)
```
1. Abrir app
2. Clique em "Sign Up" ou "Login"
3. Email: usuario_teste@exemplo.com
4. Senha: Senha123!
5. Autorizar localização (permitir)
6. Confirmar login
```

**Verificar em Firestore:**
- Coleção: `users`
- Documento: `[seu-uid]`
- Campo: `fcmToken` deve estar preenchido ✅

#### Drivers App (Motorista)
```
1. Abrir app (emulador diferente)
2. Clique em "Sign Up" ou "Login"
3. Email: motorista_teste@exemplo.com
4. Senha: Senha123!
5. Autorizar localização (permitir)
6. Ligar status "Online" ✅ (IMPORTANTE!)
7. Confirmar login
```

**Verificar em Firestore:**
- Coleção: `drivers`
- Documento: `[seu-uid]`
- Campos:
  - `isOnline: true` ✅
  - `fcmToken` preenchido ✅
  - `location.latitude` e `longitude` ✅

---

### PASSO 3️⃣ - Usuário Cria Corrida (4 min)

**No Users App:**

```
1. Clique em "Solicitar Corrida" ou "Nova Corrida"
2. Preencha ORIGEM:
   - Busque: "Avenida Paulista, São Paulo"
   - Confirme
3. Preencha DESTINO:
   - Busque: "Ibirapuera, São Paulo"  
   - Confirme
4. Veja o preço estimado
5. Clique em "SOLICITAR CORRIDA" / "CONFIRM"
```

**Observe:**
- 📍 Mapa atualiza com origem e destino
- 💰 Preço estimado aparece
- ⏱️ Tempo estimado aparece

**Verifique em Firestore:**
- Vá para Console → Firestore → `rides`
- Veja novo documento criado
- Status deve ser: `pending` ✅
- UserId preenchido ✅
- Origin/Destination com lat/lng ✅

**Verifique em Console → Cloud Functions → Logs:**
- Procure por: `notifyNearbyDrivers`
- Deve aparecer algo como:
  ```
  "Processando notificação para motorista: 2 drivers encontrados"
  ```

---

### PASSO 4️⃣ - Motorista Recebe Notificação (2 min)

**No Drivers App:**

**Espere por:**
- 🔔 Notificação push aparecer na tela
- Ou vá para "Corridas Disponíveis" para ver listada

**Verificar notificação:**
```json
{
  "title": "Nova corrida disponível!",
  "body": "Avenida Paulista → Ibirapuera"
}
```

**Se NÃO receber notificação:**
- ❌ Verificar se motorista está com `isOnline: true`
- ❌ Verificar se motorista tem `fcmToken` em Firestore
- ❌ Verificar Cloud Functions logs para erros

**Verifique em Firestore:**
- Coleção: `ride_notifications`
- Procure documento com `status: sent`
- Campo `driversNotified` deve ser > 0 ✅

---

### PASSO 5️⃣ - Motorista Aceita Corrida (3 min)

**No Drivers App:**

```
1. Veja a corrida listada em "Corridas Disponíveis"
2. Toque na corrida para ver detalhes
3. Confirme: origem, destino, preço
4. Clique em "ACEITAR CORRIDA" ou "ACCEPT"
```

**Observe:**
- ✅ Corrida desaparece da lista
- ✅ Transição para "Minhas Corridas"
- 📍 Mapa mostra rota

**Verifique em Firestore:**
- Coleção: `rides` → seu documento
- Status deve mudar: `assigned` ✅
- `assignedDriverId` preenchido ✅
- `assignedAt` timestamp criado ✅

**Verifique nos Logs:**
- Procure por: `sendRideStatusNotification`
- Deve enviar notificação para usuário

---

### PASSO 6️⃣ - Usuário Recebe Notificação de Aceição (2 min)

**No Users App:**

**Espere por:**
- 🔔 Notificação: "Motorista X aceitou sua corrida"
- Tela muda para "Motorista a Caminho"
- 👤 Foto e nome do motorista aparecem

**Verifique:**
- Dados do motorista exibidos: ✅
- Avaliação do motorista: ✅
- Botão "Ligar" disponível: ✅
- Mapa com localização do motorista: ✅

**Verifique em Firestore:**
- Coleção: `notifications`
- Procure `userId: [usuario_id]`
- Último documento deve ter:
  - `type: status_corrida` ✅
  - `title: "Motorista aceitou sua corrida"` ✅
  - `sent: true` ✅

---

### PASSO 7️⃣ - Motorista Inicia Corrida (2 min)

**No Drivers App:**

```
1. Na tela da corrida ativa
2. Veja "Chegando em X minutos"
3. Clique em "INICIAR CORRIDA" / "START RIDE"
```

**Observe:**
- Tela muda para "Em Movimento"
- Cronômetro começa
- Localização atualiza em tempo real

**Verifique em Firestore:**
- `rides` → seu documento
- Status: `in_progress` ✅
- `startedAt` timestamp criado ✅

---

### PASSO 8️⃣ - Motorista Completa Corrida (2 min)

**No Drivers App:**

```
1. Simule chegada ao destino
2. Clique em "CHEGUEI" / "ARRIVED"
3. Clique em "FINALIZAR CORRIDA" / "COMPLETE"
```

**Observe:**
- Tela muda para "Corrida Finalizada"
- Preço final exibido
- Opção para "Recebido" ou "Método de Pagamento"

**Verifique em Firestore:**
- `rides` → seu documento
- Status: `completed` ✅
- `completedAt` timestamp criado ✅
- `finalPrice` calculado ✅

---

### PASSO 9️⃣ - Usuário Avalia Motorista (2 min)

**No Users App:**

**Espere pela tela de avaliação (normalmente automática):**

```
1. Tela: "Como foi sua corrida?"
2. Selecione: ⭐⭐⭐⭐⭐ (5 estrelas)
3. Comente (opcional): "Ótimo serviço!"
4. Clique em "AVALIAR"
```

**Verifique em Firestore:**
- `rides` → seu documento
- Campo `userRating` criado ✅
- `driverRating.rating: 5` ✅
- `driverRating.comment: "..."` (se preenchido) ✅

---

## ✅ Checklist Final - Validações

Marque cada item como ✓ ou ✗:

### 🗄️ Firestore - Collections

- [ ] **rides**
  - [ ] Documento criado com `status: completed`
  - [ ] Todos os campos preenchidos (origin, destination, pricing)
  - [ ] Timestamps corretos (createdAt, assignedAt, startedAt, completedAt)

- [ ] **ride_notifications**
  - [ ] Documento criado ao criar corrida
  - [ ] `driversNotified > 0`
  - [ ] `status: sent` ou `processed`

- [ ] **notifications**
  - [ ] Documentos criados para usuário e motorista
  - [ ] Mínimo 3 notifications (aceição, início, conclusão)
  - [ ] Todos com `sent: true`

- [ ] **users**
  - [ ] Documento com `fcmToken` preenchido
  - [ ] `isActive: true`
  - [ ] Location com lat/lng

- [ ] **drivers**
  - [ ] Documento com `fcmToken` preenchido
  - [ ] `isOnline: true` durante teste
  - [ ] `totalRides` incrementado
  - [ ] Location atualizado

### 🔔 Notificações Push

- [ ] Motorista recebeu: "Nova corrida disponível"
- [ ] Usuário recebeu: "Motorista aceitou sua corrida"
- [ ] Usuário recebeu: "Corrida iniciada"
- [ ] Usuário recebeu: "Corrida finalizada"

### ☁️ Cloud Functions

Verifique em `firebase functions:log`:

- [ ] `notifyNearbyDrivers` executada com sucesso
- [ ] `sendRideStatusNotification` executada 3+ vezes
- [ ] Nenhum erro crítico (ERROR level)
- [ ] Tempo de execução < 5 segundos por função

### 📊 Admin Dashboard

- [ ] Dashboard carrega corretamente (http://localhost:8888)
- [ ] Estatísticas atualizam
- [ ] Nova corrida aparece na tabela de corridas ativas
- [ ] Status muda de "pending" → "assigned" → "in_progress" → "completed"

---

## 🆘 Troubleshooting

### Problema: Motorista não recebe notificação

**Causa provável:** FCM token não salvo

**Solução:**
```bash
# 1. Verificar em Firestore
db.collection('drivers').doc('[driver_id]').get()
# Procure por: fcmToken

# 2. Se vazio, driver app não inicializou corretamente
# Reinstale ou force sincronização
```

### Problema: Corrida criada mas nenhuma notificação de motorista

**Causa provável:** Cloud Function falhou

**Solução:**
```bash
# 1. Verifique logs
firebase functions:log --lines=50

# 2. Procure por erros em notifyNearbyDrivers

# 3. Se erro: "Nenhum driver online"
# Certifique-se de que drivers tem isOnline: true
```

### Problema: Notificação não chega ao usuário

**Causa provável:** FCM token não salvou ou notificação não criada

**Solução:**
```bash
# 1. Verificar em Firestore
db.collection('users').doc('[user_id]').get()
# Procure por: fcmToken

# 2. Verificar se notification foi criada
db.collection('notifications')
  .where('userId', '==', '[user_id]')
  .get()

# 3. Verificar logs da Cloud Function sendRideStatusNotification
```

### Problema: Mapa não atualiza

**Causa provável:** Localização não autorizada

**Solução:**
- Verifique permissões do Android:
  - Configurações → Apps → [App] → Permissões → Localização
  - Mude para "Sempre" ou "Apenas ao usar o app"

---

## 📝 Template de Relatório

Quando o teste terminar, preencha:

```markdown
# Resultado do Teste de Integração

**Data:** [DD/MM/YYYY]  
**Hora:** [HH:MM]  
**Ambiente:** [staging/production]  
**Duração Total:** [XX minutos]

## Status Geral
- [ ] ✅ PASSOU - Tudo funcionou perfeitamente
- [ ] ⚠️ PASSOU COM AVISOS - Funcionou mas com observações
- [ ] ❌ FALHOU - Problemas encontrados

## Detalhes por Fase

| # | Fase | Status | Tempo | Observações |
|---|------|--------|-------|-------------|
| 1 | Setup | ✅ | 2min | - |
| 2 | User Login | ✅ | 1min | - |
| 3 | Driver Login | ✅ | 1min | Motorista online ✓ |
| 4 | Criar Corrida | ✅ | 30s | - |
| 5 | Ride Notifications | ✅ | 1s | 1 driver notificado |
| 6 | Driver Recebe | ✅ | 1s | - |
| 7 | Driver Aceita | ✅ | 45s | - |
| 8 | User Notificado | ✅ | 1s | - |
| 9 | Iniciar Corrida | ✅ | 30s | - |
| 10 | Completar Corrida | ✅ | 2min | - |
| 11 | Avaliar | ✅ | 1min | Avaliação salva |

## Issues Encontrados

### Issue #1: [Descrição]
- **Fase:** [Qual passo falhou]
- **Severidade:** [Critical/High/Medium/Low]
- **Reproduzir:** [Passos para reproduzir]
- **Solução:** [Como resolver]
- **Status:** [Resolvido/Pendente]

## Metrics

- **Tempo Total:** X minutos
- **FCM Messages Enviadas:** X
- **Firestore Documents Criados:** X
- **Cloud Function Executions:** X
- **Erros Observados:** X

## Notas Adicionais

[Qualquer observação importante]
```

---

## 🎓 Próximos Passos

Após este teste funcionar com sucesso:

1. **Teste de Carga** (Phase 2)
   - 5 usuários criando corridas simultaneamente
   - 10 motoristas online

2. **Teste em Produção**
   - Repetir em ambiente de produção
   - Com dados reais (se aprovado)

3. **Teste de Timeout**
   - Simular motorista indo offline
   - Verificar re-atribuição automática

4. **Teste de Cancelamento**
   - Usuário cancela corrida em aberto
   - Motorista cancela corrida aceita
   - Validar reembolsos

---

## 📞 Support

Dúvidas durante o teste?

- Documentação: [/docs](/docs)
- Cloud Functions Guide: [CLOUD_FUNCTIONS_GUIDE.md](CLOUD_FUNCTIONS_GUIDE.md)
- Firebase Docs: https://firebase.google.com/docs

---

**Boa sorte! 🍀**
