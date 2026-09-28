# 🎯 Quick Start - Teste de Integração

## ⚡ 5 Minutos de Setup

```bash
# Terminal 1: Deploy Cloud Functions
cd functions
npm install
firebase deploy --only functions

# Terminal 2: Admin Panel
cd apps/admin_web_panel/build/web
python -m http.server 8888

# Terminal 3: Logs
firebase functions:log
```

---

## 📱 Na Prática (15 minutos)

### ✅ Etapa 1: Users App
```
1. Login: usuario@teste.com
2. Autorizar localização
3. Criar corrida:
   - Origem: Avenida Paulista
   - Destino: Parque Ibirapuera
4. Clique em "SOLICITAR"
```

### ✅ Etapa 2: Drivers App
```
1. Login: motorista@teste.com
2. Autorizar localização
3. Ativar "ONLINE" ⚡ IMPORTANTE
4. Aguardar notificação
5. Ver corrida em "Disponíveis"
```

### ✅ Etapa 3: Aceitar & Completar
```
# Drivers App:
1. Clique na corrida
2. Toque "ACEITAR"
3. Toque "INICIAR"
4. Toque "COMPLETAR"

# Users App:
1. Veja "Motorista vem a caminho"
2. Avalie ⭐⭐⭐⭐⭐
```

---

## 🔍 Verificações Rápidas

| Local | O que verificar | Status |
|-------|-----------------|--------|
| **Firestore** | Novo documento em `rides` | ✅ |
| **Firestore** | `ride_notifications` criado | ✅ |
| **Drivers App** | Recebeu notificação push | ✅ |
| **Users App** | Recebeu notificação de aceição | ✅ |
| **Firebase Logs** | Nenhum erro | ✅ |
| **Admin Panel** | Corrida visível | ✅ |

---

## 🆘 Se algo não funcionar

| Sintoma | Verifique |
|---------|-----------|
| Sem notificação no Drivers App | Driver está `isOnline: true`? |
| Motorista não vê corrida | Está a menos de 5km? |
| Erro nos logs | Verificar `firebase functions:log` |
| Firestore vazio | Regras de segurança bloqueando? |

---

## 📊 Resultado Esperado

```
✅ Usuário cria corrida
  → Motorista recebe notificação
    → Motorista aceita
      → Usuário notificado
        → Corrida inicia
          → Corrida completa
            → Avaliação salva
```

**Tempo total: ~15 minutos**  
**Erros esperados: 0**

---

Documento completo: [INTEGRATION_TEST_MANUAL.md](INTEGRATION_TEST_MANUAL.md)
