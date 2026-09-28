# 🚀 Comando Rápido - Teste de Integração

## Copie e Execute

### Terminal 1: Logs em Tempo Real
```bash
firebase functions:log
```

### Terminal 2: Admin Dashboard
```bash
cd apps/admin_web_panel/build/web
python -m http.server 8888
# Abra: http://localhost:8888
```

### Terminal 3: Emulador 1 (Users App)
```bash
cd apps/users_app
flutter run -d emulator-5554  # Ou seu device ID
```

### Terminal 4: Emulador 2 (Drivers App)
```bash
cd apps/drivers_app
flutter run -d emulator-5556  # Ou seu device ID
```

---

## Validar Pré-requisitos
```bash
node check_prerequisites.js
```

---

## Guias de Referência

- **Setup Rápido:** `cat INTEGRATION_TEST_QUICKSTART.md`
- **Passo-a-Passo:** `cat INTEGRATION_TEST_MANUAL.md`
- **Plano Detalhado:** `cat INTEGRATION_TEST_PLAN.md`
- **Este Resumo:** `cat TESTING_SUMMARY.md`

---

## Fluxo Que Vai Acontecer

```
1. User abre app → Login
2. Driver abre app → Login + Online
3. User cria corrida → Avenida Paulista → Ibirapuera
4. System → notifyNearbyDrivers Cloud Function
5. Driver → Recebe notificação 🔔
6. Driver → Vê corrida em "Disponíveis"
7. Driver → Clica "ACEITAR"
8. User → Recebe notificação "Motorista X aceitou" 🔔
9. Driver → Clica "INICIAR"
10. User → Vê "Motorista a caminho"
11. Driver → Clica "COMPLETAR"
12. User → Tela de avaliação ⭐⭐⭐⭐⭐
13. Admin Panel → Mostra corrida concluída ✅

TODO: 15-20 minutos
ERROS ESPERADOS: 0
```

---

## Verifications Rápidas

| O Que | Onde | Esperado |
|------|------|----------|
| Corrida criada | Firestore > rides | 1 doc |
| Motorista notificado | Firestore > ride_notifications | 1 doc |
| User notificado | Firestore > notifications | 3+ docs |
| Sem erros | Terminal 1 (logs) | ✅ Success |
| Dashboard atualizado | http://localhost:8888 | 1 corrida |

---

## Se Quebrar

Procure em: **INTEGRATION_TEST_MANUAL.md** seção "🆘 Troubleshooting"

---

**Pronto?** Execute os 4 terminais acima e siga **INTEGRATION_TEST_QUICKSTART.md**

Boa sorte! 🍀
