# 🔔 Notificação: Status da Corrida

## Descrição
Sistema que notifica usuários e motoristas sobre mudanças de status da corrida em tempo real (assigned → in_progress → completed).

## Fluxo da Notificação

```
┌──────────────────────────────────────────────────────────────┐
│        FLUXO: MUDANÇAS DE STATUS DA CORRIDA                  │
└──────────────────────────────────────────────────────────────┘

CENÁRIO: Ciclo Completo da Corrida

STEP 1: CORRIDA PENDENTE
   └─ rides/{id} com status="pending"
   └─ Aguardando aceitação do motorista

STEP 2: MOTORISTA ACEITA (status = assigned)
   │
   ├─ Drivers App: AvailableRidesService.acceptRide()
   ├─ Atualiza rides/{id}:
   │  {
   │    status: "assigned",
   │    driverId: "motorista123",
   │    driverAcceptedAt: 2026-01-18T10:30:05Z
   │  }
   │
   ├─ Cria notificação em notifications/{id}:
   │  {
   │    userId: "usuario123"
   │    rideId: "ride123"
   │    type: "ride_assigned"
   │    title: "🚗 Motorista Encontrado!"
   │    body: "Um motorista foi atribuído à sua corrida"
   │    sent: false
   │    createdAt: 2026-01-18T10:30:05Z
   │  }
   │
   └─ 📱 Users App recebe notificação
      └─ RideTrackingScreen é atualizada
      └─ Mostra localização do motorista

STEP 3: MOTORISTA INICIA CORRIDA (status = in_progress)
   │
   ├─ Drivers App: ActiveRideScreen
   ├─ Motorista clica "Iniciar Corrida"
   ├─ AvailableRidesService.updateRideStatus('in_progress')
   ├─ Atualiza rides/{id}:
   │  {
   │    status: "in_progress",
   │    startedAt: 2026-01-18T10:30:30Z
   │  }
   │
   ├─ Cria notificação em notifications/{id}:
   │  {
   │    userId: "usuario123"
   │    rideId: "ride123"
   │    type: "ride_started"
   │    title: "✅ Corrida Iniciada!"
   │    body: "Seu motorista começou a corrida. Acompanhe em tempo real"
   │    sent: false
   │    createdAt: 2026-01-18T10:30:30Z
   │  }
   │
   └─ 📱 Users App recebe notificação
      └─ Começa a atualizar localização do motorista
      └─ Mostra rastreamento em tempo real

STEP 4: MOTORISTA FINALIZA CORRIDA (status = completed)
   │
   ├─ Drivers App: ActiveRideScreen
   ├─ Motorista clica "Finalizar Corrida"
   ├─ AvailableRidesService.updateRideStatus('completed')
   ├─ Atualiza rides/{id}:
   │  {
   │    status: "completed",
   │    completedAt: 2026-01-18T10:35:45Z
   │  }
   │
   ├─ Cria notificação em notifications/{id}:
   │  {
   │    userId: "usuario123"
   │    rideId: "ride123"
   │    type: "ride_completed"
   │    title: "🎉 Corrida Finalizada!"
   │    body: "Sua corrida foi finalizada. Avalie seu motorista"
   │    sent: false
   │    createdAt: 2026-01-18T10:35:45Z
   │  }
   │
   └─ 📱 Users App recebe notificação
      └─ RideTrackingScreen mostra resumo
      └─ Oferece opção para avaliar

STEP 5: USUARIO AVALIA (opcional)
   └─ RatingScreen é exibida
   └─ Usuário escolhe 5 ⭐
   └─ rating/{id} é criado e atualiza motorista

CENÁRIO ALTERNATIVO: Cancelamento

STEP A: USUARIO CANCELA CORRIDA
   │
   ├─ Users App: RideTrackingScreen
   ├─ Usuário clica "Cancelar Corrida"
   ├─ RideService.cancelRideRequest()
   ├─ Atualiza rides/{id}:
   │  {
   │    status: "cancelled"
   │  }
   │
   ├─ Cria notificação em notifications/{id}:
   │  {
   │    userId: "usuario123"
   │    rideId: "ride123"
   │    type: "ride_cancelled"
   │    title: "❌ Corrida Cancelada"
   │    body: "Sua corrida foi cancelada"
   │    sent: false
   │  }
   │
   └─ 🚗 Drivers App recebe notificação
      └─ DriverNotificationService.onUserCancelled()
      └─ Remove de ActiveRideScreen
      └─ Restaura online status

┌──────────────────────────────────────────────────────────────┐
│ Tempo Total Ciclo: ~5 minutos                                │
│ Notificações Enviadas: 3-4 (assigned, started, completed)   │
│ Sincronização: Firestore + Local Notifications + FCM        │
└──────────────────────────────────────────────────────────────┘
```

## Arquitetura

### 1. Users App - RideService (ATUALIZADO)
```dart
// Atualizar status e enviar notificação
Future<void> updateRideStatus(String rideId, String status) {
  // 1. Atualiza rides/{id}
  // 2. Chama _sendRideStatusNotification()
  // 3. Cria documento em notifications/{id}
}

// Métodos privados
Future<void> _sendRideStatusNotification({
  required String userId,
  required String rideId,
  required String status,
  required Map<String, dynamic> rideData,
}) {
  // Determina title/body baseado no status
  // Armazena em Firestore para Cloud Functions/FCM
}
```

### 2. Users App - RideStatusListenerService (NOVO)
```dart
class RideStatusListenerService {
  // Callbacks para mudanças de status
  Function(String rideId)? onRideAssigned;
  Function(String rideId)? onRideStarted;
  Function(String rideId)? onRideCompleted;
  Function(String rideId)? onRideCancelled;
  
  // Stream listeners
  void startListeningToRideStatus(String rideId)
  Stream<String?> getRideStatusStream(String rideId)
  Stream<Map<String, dynamic>?> getRideDataStream(String rideId)
}
```

### 3. Users App - NotificationService (ATUALIZADO)
```dart
// Callbacks expandidos com comentários sobre ações
void _onRideAssigned(String? rideId) {
  // - Atualizar UI
  // - Reproduzir som
  // - Enviar para analytics
}

void _onRideStarted(String? rideId) {
  // - Transição automática para RideTrackingScreen
  // - Iniciar atualização de localização
}

void _onRideCompleted(String? rideId) {
  // - Notificar usuário
  // - Preparar dados para RatingScreen
  // - Limpar dados de rastreamento
}
```

### 4. Drivers App - AvailableRidesService (ATUALIZADO)
```dart
// Atualizar status e enviar notificação
Future<void> updateRideStatus(String rideId, String newStatus) {
  // 1. Obtém dados da corrida
  // 2. Atualiza rides/{id}
  // 3. Chama _sendRideStatusNotification()
  // 4. Cria documento em notifications/{id}
}

Future<void> _sendRideStatusNotification({
  required String userId,
  required String rideId,
  required String status,
}) {
  // Notifica usuário sobre mudanças (in_progress, completed)
}
```

### 5. Drivers App - DriverRideStatusListenerService (NOVO)
```dart
class DriverRideStatusListenerService {
  // Callbacks para mudanças de status
  Function(String rideId)? onRideCancelled;
  Function(String rideId)? onRideCompleted;
  
  // Stream listeners
  void startListeningToActiveRideStatus(String rideId)
  Stream<String?> getRideStatusStream(String rideId)
  Stream<Map<String, dynamic>?> getRideDataStream(String rideId)
}
```

### 6. Drivers App - DriverNotificationService (ATUALIZADO)
```dart
void _onNewRideAvailable(String? rideId) {
  // - Abrir AvailableRidesScreen automaticamente
  // - Destacar corrida na lista
}

void _onUserCancelled(String? rideId) {
  // - Notificar motorista
  // - Remover da lista
  // - Restaurar disponibilidade
}
```

## Estrutura Firestore

### Coleção: `notifications`
```
notifications/
├─ {notificationId}
│  ├─ userId: "usuario123"
│  ├─ rideId: "ride123"
│  ├─ type: "ride_assigned" | "ride_started" | "ride_completed" | "ride_cancelled"
│  ├─ title: "🚗 Motorista Encontrado!" | "✅ Corrida Iniciada!" | "🎉 Corrida Finalizada!" | "❌ Corrida Cancelada"
│  ├─ body: "Um motorista foi atribuído..." | "Seu motorista começou..." | "Sua corrida foi finalizada..." | "Sua corrida foi cancelada"
│  ├─ status: "assigned" | "in_progress" | "completed" | "cancelled"
│  ├─ sent: false | true
│  └─ createdAt: Timestamp(2026-01-18T10:30:05Z)
```

### Coleção: `rides` (atualizada)
```
rides/
├─ {rideId}
│  ├─ userId: "usuario123"
│  ├─ driverId: "motorista123" (após aceitar)
│  ├─ status: "pending" | "assigned" | "in_progress" | "completed" | "cancelled"
│  ├─ origin: "Av. Paulista, 1000"
│  ├─ destination: "Rua X, 500"
│  ├─ createdAt: Timestamp(2026-01-18T10:30:00Z)
│  ├─ driverAcceptedAt: Timestamp(2026-01-18T10:30:05Z) [se assigned]
│  ├─ startedAt: Timestamp(2026-01-18T10:30:30Z) [se in_progress]
│  └─ completedAt: Timestamp(2026-01-18T10:35:45Z) [se completed]
```

**Índices Recomendados:**
```
Collection: rides
- userId + status + createdAt (compound)
- driverId + status + createdAt (compound)

Collection: notifications
- userId + createdAt
- rideId + type
```

## Tipo de Notificações

| Status | Type | Title | Body | Enviado por |
|--------|------|-------|------|-------------|
| pending | - | - | - | Nenhum |
| assigned | ride_assigned | 🚗 Motorista Encontrado! | Um motorista foi atribuído à sua corrida | Drivers App |
| in_progress | ride_started | ✅ Corrida Iniciada! | Seu motorista começou a corrida | Drivers App |
| completed | ride_completed | 🎉 Corrida Finalizada! | Sua corrida foi finalizada. Avalie seu motorista | Drivers App |
| cancelled | ride_cancelled | ❌ Corrida Cancelada | Sua corrida foi cancelada | Users App |

## Implementação nos Screens

### RideTrackingScreen (Users App)
```dart
class RideTrackingScreen extends StatefulWidget {
  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  late RideStatusListenerService _statusListener;
  
  @override
  void initState() {
    super.initState();
    _statusListener = RideStatusListenerService();
    
    // Escutar mudanças de status
    _statusListener.onRideAssigned = (rideId) {
      setState(() {
        // Atualizar UI
      });
    };
    
    _statusListener.onRideStarted = (rideId) {
      // Iniciar rastreamento
    };
    
    _statusListener.onRideCompleted = (rideId) {
      // Navegar para RatingScreen
      Navigator.pushNamed(context, '/rating', arguments: rideId);
    };
    
    _statusListener.startListeningToRideStatus(widget.rideId);
  }
}
```

### ActiveRideScreen (Drivers App)
```dart
class ActiveRideScreen extends StatefulWidget {
  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  late DriverRideStatusListenerService _statusListener;
  
  @override
  void initState() {
    super.initState();
    _statusListener = DriverRideStatusListenerService();
    
    // Escutar cancelamento
    _statusListener.onRideCancelled = (rideId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário cancelou a corrida')),
      );
      // Voltar para AvailableRidesScreen
      Navigator.pop(context);
    };
    
    _statusListener.startListeningToActiveRideStatus(widget.rideId);
  }
}
```

## Testes

### Teste 1: Fluxo Completo
```
1. Abrir Users App e solicitar corrida
2. Abrir Drivers App e aceitar corrida
3. Verificar: Notificação "🚗 Motorista Encontrado!" aparece ✓
4. Motorista clica "Iniciar Corrida"
5. Verificar: Notificação "✅ Corrida Iniciada!" aparece ✓
6. Motorista clica "Finalizar Corrida"
7. Verificar: Notificação "🎉 Corrida Finalizada!" aparece ✓
8. Usuário é direcionado para RatingScreen ✓
```

### Teste 2: Cancelamento
```
1. Solicitar corrida (status=pending)
2. Motorista aceita (status=assigned)
3. Usuário clica "Cancelar"
4. Verificar: Notificação "❌ Corrida Cancelada" no Drivers App ✓
5. Verificar: Corrida removida de ActiveRideScreen ✓
```

### Teste 3: Stream em Tempo Real
```
1. Abrir RideTrackingScreen
2. Em outro dispositivo, mudar status em Firestore diretamente
3. Verificar: UI atualiza em < 1 segundo ✓
4. Verificar: Callbacks são acionados corretamente ✓
```

## Cloud Functions (Recomendado)

```javascript
// Processar notificações e enviar via FCM
exports.sendRideStatusNotification = functions
  .firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    // Buscar FCM token do usuário
    const userDoc = await admin
      .firestore()
      .collection('users')
      .doc(notification.userId)
      .get();
    
    const fcmToken = userDoc.data()?.fcmToken;
    
    if (!fcmToken) {
      console.log('Usuário sem FCM token');
      return;
    }
    
    // Enviar notificação via FCM
    await admin.messaging().sendToDevice(fcmToken, {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: {
        rideId: notification.rideId,
        type: notification.type,
        status: notification.status,
      }
    });
    
    // Marcar como enviada
    await snap.ref.update({ sent: true });
    
    console.log(`Notificação enviada para ${notification.userId}`);
  });
```

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Notificação não aparece | Verificar se documento está em notifications/{id} |
| Delay na notificação | Verificar listeners estão ativos em RideTrackingScreen |
| Status não atualiza na UI | Verificar StreamBuilder está conectado a getRideStatusStream() |
| Múltiplas notificações | Verificar if (snapshot.docs.isEmpty) antes de processar |

## Próximas Fases

1. **Cloud Functions:** Automação de envio via FCM
2. **Analytics:** Rastrear tempo entre cada status
3. **Retry Logic:** Tentar enviar novamente se falhar
4. **Batch Notifications:** Agrupar múltiplas notificações

## Documentação Relacionada

- [NOVA_CORRIDA_DISPONIVEL.md](NOVA_CORRIDA_DISPONIVEL.md)
- [PUSH_NOTIFICATIONS_SETUP.md](PUSH_NOTIFICATIONS_SETUP.md)
- [DRIVERS_APP_INTEGRATION.md](DRIVERS_APP_INTEGRATION.md)
- [VISAO_COMPLETA_PROJETO.md](VISAO_COMPLETA_PROJETO.md)
