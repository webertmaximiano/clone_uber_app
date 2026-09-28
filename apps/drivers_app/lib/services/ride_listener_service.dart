import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivers_app/services/driver_notification_service.dart';
import 'dart:math';

/// Serviço que monitora novas corridas disponíveis e envia notificações para motoristas próximos
class RideListenerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DriverNotificationService _notificationService;

  RideListenerService(this._notificationService);

  /// Iniciar listener para novas corridas
  /// Monitora a coleção ride_notifications e envia notificações para motoristas online próximos
  void startListeningForNewRides({
    required double driverLat,
    required double driverLng,
    required String driverId,
    double radiusKm = 5.0,
  }) {
    _firestore
        .collection('ride_notifications')
        .where('processed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      for (var doc in snapshot.docs) {
        final rideNotification = doc.data();
        
        // Calcular distância entre motorista e origem da corrida
        final distance = _calculateDistance(
          driverLat,
          driverLng,
          rideNotification['originLat'] as double? ?? 0,
          rideNotification['originLng'] as double? ?? 0,
        );

        // Se motorista está dentro do raio, enviar notificação
        if (distance <= radiusKm) {
          await _sendNewRideNotification(
            rideId: rideNotification['rideId'] as String,
            origin: rideNotification['origin'] as String,
            rideType: rideNotification['rideType'] as String,
            distance: distance,
          );
        }

        // Marcar como processada para não enviar repetidamente
        if (snapshot.docs.length == 1) {
          await doc.reference.update({'processed': true});
        }
      }
    });
  }

  /// Enviar notificação de nova corrida disponível
  Future<void> _sendNewRideNotification({
    required String rideId,
    required String origin,
    required String rideType,
    required double distance,
  }) async {
    try {
      // Usar o sistema de notificações local para simular notificação com som de alerta
      final title = '🚗 Nova Corrida Disponível!';
      final body = '$rideType a ${distance.toStringAsFixed(1)}km - Saindo de $origin';

      // Enviar notificação local imediatamente
      await _notificationService.showLocalNotification(
        id: rideId.hashCode,
        title: title,
        body: body,
        payload: {
          'rideId': rideId,
          'type': 'new_ride_available',
          'origin': origin,
          'rideType': rideType,
        },
        playSound: true,
        useAlertSound: true, // Som especial para nova corrida
        enableVibration: true,
      );

      print('Notificação enviada: $title - $body');
    } catch (e) {
      print('Erro ao enviar notificação de nova corrida: $e');
    }
  }

  /// Calcular distância entre dois pontos (Fórmula de Haversine)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Parar de escutar novas corridas
  void stopListening() {
    // StreamSubscription é gerenciada automaticamente quando o widget é descartado
  }
}
