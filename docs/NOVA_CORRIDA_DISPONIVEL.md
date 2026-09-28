# 🔔 Notificação: Nova Corrida Disponível

## Descrição
Sistema que notifica motoristas em tempo real quando há novas corridas disponíveis próximas à sua localização.

## Fluxo da Notificação

```
┌──────────────────────────────────────────────────────────────┐
│            FLUXO: NOVA CORRIDA DISPONÍVEL                    │
└──────────────────────────────────────────────────────────────┘

STEP 1: USUARIO CRIA CORRIDA
   │
   ├─ Users App: RideRequestScreen
   ├─ Clica "Solicitar Corrida"
   ├─ RideService.createRideRequest()
   └─ 💾 Firestore: rides/{id} com status="pending"

STEP 2: NOTIFICAR MOTORISTAS PROXIMOS
   │
   ├─ RideService._notifyNearbyDrivers()
   ├─ Calcula origem da corrida (lat/lng)
   ├─ Cria documento em ride_notifications
   │  {
   │    rideId: "ride123"
   │    origin: "Av. Paulista, 1000"
   │    originLat: -23.5505
   │    originLng: -46.6333
   │    rideType: "economy"
   │    type: "new_ride_available"
   │    title: "🚗 Nova Corrida Disponível!"
   │    body: "Corrida de economy saindo de Av. Paulista, 1000"
   │    createdAt: 2026-01-18T10:30:00Z
   │    processed: false
   │  }
   └─ 💾 Firestore: ride_notifications/{id}

STEP 3: DRIVERS APP ESCUTA NOVAS CORRIDAS
   │
   ├─ main.dart inicializa RideListenerService
   ├─ _initializeRideListener() com localização atual
   ├─ startListeningForNewRides(driverLat, driverLng, radius=5km)
   └─ 👂 Listener ativo em ride_notifications (processed=false)

STEP 4: CALCULAR DISTANCIA E FILTRAR
   │
   ├─ Quando documento é criado em ride_notifications
   ├─ RideListenerService detecta (snapshots)
   ├─ Calcula distância (Fórmula de Haversine)
   │  distance = distância entre motorista e origem
   ├─ Se distance <= radiusKm (5km padrão)
   │  └─ Motorista recebe notificação ✅
   └─ Marcar documento como processed=true

STEP 5: ENVIAR NOTIFICACAO LOCAL
   │
   ├─ RideListenerService._sendNewRideNotification()
   ├─ Usar DriverNotificationService.showLocalNotification()
   │  {
   │    id: rideId.hashCode
   │    title: "🚗 Nova Corrida Disponível!"
   │    body: "economy a 2.3km - Saindo de Av. Paulista, 1000"
   │    payload: {
   │      rideId: "ride123"
   │      type: "new_ride_available"
   │      origin: "Av. Paulista, 1000"
   │      rideType: "economy"
   │    }
   │    playSound: true
   │    useAlertSound: true (som especial 🔔)
   │    enableVibration: true
   │  }
   └─ 🔔 Notificação exibida ao motorista

STEP 6: MOTORISTA INTERAGE
   │
   ├─ Motorista vê notificação
   ├─ Clica na notificação
   ├─ Vai para AvailableRidesScreen
   ├─ Vê corrida na lista (topo - distância calculada)
   ├─ Pode aceitar usando "Aceitar" button
   └─ AvailableRidesService.acceptRide() →
      enviar notificação ao usuário

┌──────────────────────────────────────────────────────────────┐
│ Tempo Total: < 1 segundo (real-time)                         │
│ Sincronização: Firestore Listener (instantânea)              │
│ Notificação: Local notification (sem FCM necessário)         │
└──────────────────────────────────────────────────────────────┘
```

## Arquitetura

### 1. Users App - RideService
```dart
Future<void> createRideRequest(RideRequest rideRequest) {
  // 1. Cria documento rides/{id}
  // 2. Chama _notifyNearbyDrivers()
  // 3. Cria documento em ride_notifications
}

Future<void> _notifyNearbyDrivers({
  required String rideId,
  required String origin,
  required double originLat,
  required double originLng,
  required String rideType,
}) {
  // Armazena no Firestore para RideListenerService processar
  // Documentos antigos são marcados como processed=true
}
```

### 2. Drivers App - RideListenerService (NOVO)
```dart
class RideListenerService {
  // Inicia listener para novas corridas
  void startListeningForNewRides({
    required double driverLat,
    required double driverLng,
    required String driverId,
    double radiusKm = 5.0,
  })
  
  // Calcula distância e envia notificação se próximo
  Future<void> _sendNewRideNotification({
    required String rideId,
    required String origin,
    required String rideType,
    required double distance,
  })
}
```

### 3. Drivers App - DriverNotificationService (ATUALIZADO)
```dart
// Novo método público para enviar notificações locais
Future<void> showLocalNotification({
  required int id,
  required String title,
  required String body,
  Map<String, dynamic>? payload,
  bool playSound = true,
  bool useAlertSound = false,
  bool enableVibration = true,
})
```

### 4. Drivers App - main.dart (ATUALIZADO)
```dart
class _DriverAppState extends State<DriverApp> {
  late RideListenerService _rideListenerService;
  
  Future<void> _initializeRideListener() {
    // Inicia RideListenerService
    // Obtém localização atual
    // Inicia escuta de novas corridas
  }
}
```

## Estrutura Firestore

### Coleção: `ride_notifications`
```
ride_notifications/
├─ {notificationId}
│  ├─ rideId: "ride123"
│  ├─ origin: "Av. Paulista, 1000"
│  ├─ originLat: -23.5505
│  ├─ originLng: -46.6333
│  ├─ rideType: "economy" | "comfort" | "executive"
│  ├─ type: "new_ride_available"
│  ├─ title: "🚗 Nova Corrida Disponível!"
│  ├─ body: "Corrida de economy saindo de Av. Paulista, 1000"
│  ├─ createdAt: Timestamp(2026-01-18T10:30:00Z)
│  └─ processed: true | false
```

**Índices Recomendados:**
```
Collection: ride_notifications
- processed (Ascending)
- createdAt (Descending)
Composite: processed + createdAt
```

## Configuração

### 1. Coleção `ride_notifications` no Firestore
```
Criar coleção vazia ou via código na primeira criação
Permitir leitura/escrita (será protegido por Cloud Functions depois)
```

### 2. Permissões de Localização
```
Android: 
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION

iOS:
- NSLocationWhenInUseUsageDescription
```

### 3. Sons de Alerta (Android)
```
Arquivo: android/app/src/main/res/raw/alert.mp3
- Som de notificação especial para novas corridas
- Diferente do som de notificação padrão
```

## Fluxo Completo (Exemplo)

### Timeline:
```
10:30:00 - Usuário clica "Solicitar Corrida"
          └─ Origem: Av. Paulista, 1000 (-23.5505, -46.6333)
          └─ Tipo: economy

10:30:01 - RideService.createRideRequest()
          └─ Cria rides/ride123 (status=pending)
          └─ Chama _notifyNearbyDrivers()

10:30:02 - ride_notifications/notif123 criado
          ├─ rideId: "ride123"
          ├─ originLat: -23.5505, originLng: -46.6333
          ├─ processed: false

10:30:03 - Drivers App - RideListenerService detecta
          ├─ Motorista A em: -23.5520, -46.6340 (distância: 2.1km)
          ├─ Motorista B em: -23.5400, -46.6200 (distância: 18km)
          ├─ Motorista C em: -23.5505, -46.6333 (distância: 0km)
          └─ Motorista D offLine (sem escuta ativa)

10:30:04 - Notificações enviadas
          ├─ Motorista A: "🚗 Nova Corrida Disponível!"
          │             "economy a 2.1km - Saindo de Av. Paulista"
          │             [Som: alert.mp3] [Vibração: ON]
          │
          ├─ Motorista C: "🚗 Nova Corrida Disponível!"
          │             "economy a 0km - Saindo de Av. Paulista"
          │             [Som: alert.mp3] [Vibração: ON]
          │
          └─ ride_notifications/notif123.processed = true

10:30:05 - Motorista A clica notificação
          └─ Abre AvailableRidesScreen
          └─ Vê ride123 no topo da lista
          └─ Clica "Aceitar Corrida"
```

## Próximas Fases

### Cloud Functions (Fase 7 - Recomendado)
```javascript
// functions/index.js

exports.notifyNearbyDrivers = functions
  .firestore
  .document('ride_notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notif = snap.data();
    
    if (notif.processed) return; // Já processado
    
    // Buscar drivers online próximos
    const driversSnap = await admin
      .firestore()
      .collection('drivers')
      .where('isOnline', '==', true)
      .get();
    
    // Calcular distância e enviar FCM para cada motorista
    for (const driverDoc of driversSnap.docs) {
      const driver = driverDoc.data();
      
      // Calcular distância (Haversine)
      const distance = calculateDistance(
        notif.originLat, notif.originLng,
        driver.latitude, driver.longitude
      );
      
      // Se próximo (< 5km), enviar notificação FCM
      if (distance <= 5) {
        await admin.messaging().sendToDevice(driver.fcmToken, {
          notification: {
            title: notif.title,
            body: `${notif.rideType} a ${distance.toFixed(1)}km`,
          },
          data: {
            rideId: notif.rideId,
            type: 'new_ride_available',
          }
        });
      }
    }
    
    // Marcar como processada
    await snap.ref.update({ processed: true });
  });
```

## Testes

### Teste 1: Notificação Básica
```
1. Abrir Drivers App com motorista próximo
2. Abrir Users App em outro dispositivo
3. Solicitar corrida
4. Verificar: notificação aparece no Drivers App ✓
```

### Teste 2: Filtro de Distância
```
1. Abrir Drivers App com motorista LONGE (>5km)
2. Solicitar corrida em Users App
3. Verificar: motorista NÃO recebe notificação ✓
4. Abrir Drivers App com motorista PERTO (<5km)
5. Verificar: motorista RECEBE notificação ✓
```

### Teste 3: Som de Alerta
```
1. Abrir Drivers App (modo silencioso desligado)
2. Solicitar corrida
3. Verificar: som de alerta diferente do padrão ✓
4. Verificar: vibração ativada ✓
```

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Notificação não aparece | Verificar permissions de localização |
| Som não toca | Verificar alert.mp3 em android/app/src/main/res/raw/ |
| Motorista não é encontrado | Debugar RideListenerService - verificar listener ativo |
| Distância incorreta | Verificar coordenadas lat/lng no Firestore |

## Commits Relacionados

- `3946dce` - Sistema de Notificações Push
- `[novo]` - Nova Corrida Disponível: Listener em tempo real

## Documentação Relacionada

- [PUSH_NOTIFICATIONS_SETUP.md](PUSH_NOTIFICATIONS_SETUP.md)
- [DRIVERS_APP_INTEGRATION.md](DRIVERS_APP_INTEGRATION.md)
- [VISAO_COMPLETA_PROJETO.md](VISAO_COMPLETA_PROJETO.md)
