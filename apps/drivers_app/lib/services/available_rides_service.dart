import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AvailableRidesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obter corridas disponíveis próximas ao motorista (stream em tempo real)
  Stream<List<Map<String, dynamic>>> getAvailableRidesStream(double driverLat, double driverLng, {double radiusKm = 5.0}) {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'pending')
        .where('driverId', isNull: true)
        .snapshots()
        .map((snapshot) {
      final rides = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final rideData = doc.data();
        final destinationLat = rideData['destinationLat'] as double?;
        final destinationLng = rideData['destinationLng'] as double?;

        if (destinationLat != null && destinationLng != null) {
          // Calcular distância entre motorista e origem da corrida
          final distance = _calculateDistance(
            driverLat,
            driverLng,
            rideData['originLat'] as double? ?? 0,
            rideData['originLng'] as double? ?? 0,
          );

          // Filtrar apenas corridas dentro do raio
          if (distance <= radiusKm) {
            rides.add({
              ...rideData,
              'id': doc.id,
              'distance': distance, // Distância do motorista até a origem
            });
          }
        }
      }

      // Ordenar por distância (mais perto primeiro)
      rides.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      return rides;
    });
  }

  /// Aceitar uma corrida específica
  Future<void> acceptRide(String rideId, double driverLat, double driverLng) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    try {
      // Obter dados da corrida para notificação
      final rideDoc = await _firestore.collection('rides').doc(rideId).get();
      final rideData = rideDoc.data() as Map<String, dynamic>;
      final userId_ride = rideData['userId'] as String?;
      final origin = rideData['origin'] as String?;

      await _firestore.collection('rides').doc(rideId).update({
        'driverId': userId,
        'status': 'assigned',
        'updatedAt': DateTime.now(),
        'driverAcceptedAt': DateTime.now(),
        'driverLatAtAcceptance': driverLat,
        'driverLngAtAcceptance': driverLng,
      });

      // Atualizar contador de corridas do motorista
      await _firestore.collection('drivers').doc(userId).update({
        'totalRides': FieldValue.increment(1),
        'lastRideAt': DateTime.now(),
      });

      // Enviar notificação para o usuário
      if (userId_ride != null) {
        await _sendNotificationToUser(
          userId: userId_ride,
          rideId: rideId,
          type: 'ride_assigned',
          title: 'Motorista Encontrado! 🚗',
          body: 'Um motorista foi atribuído à sua corrida. Ele está chegando em $origin',
        );
      }
    } catch (e) {
      throw Exception('Erro ao aceitar corrida: $e');
    }
  }
    } catch (e) {
      throw Exception('Erro ao aceitar corrida: $e');
    }
  }

  /// Obter corrida ativa do motorista
  Stream<Map<String, dynamic>?> getActiveRideStream(String driverId) {
    return _firestore
        .collection('rides')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: ['assigned', 'in_progress'])
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return {
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      };
    });
  }

  /// Atualizar status da corrida
  Future<void> updateRideStatus(String rideId, String newStatus) async {
    try {
      // Obter dados da corrida antes de atualizar
      final rideDoc = await _firestore.collection('rides').doc(rideId).get();
      final rideData = rideDoc.data() as Map<String, dynamic>?;
      final userId = rideData?['userId'] as String?;

      await _firestore.collection('rides').doc(rideId).update({
        'status': newStatus,
        'updatedAt': DateTime.now(),
        if (newStatus == 'in_progress') 'startedAt': DateTime.now(),
        if (newStatus == 'completed') 'completedAt': DateTime.now(),
      });

      // Enviar notificação ao usuário sobre mudança de status
      if (userId != null) {
        await _sendRideStatusNotification(
          userId: userId,
          rideId: rideId,
          status: newStatus,
        );
      }
    } catch (e) {
      throw Exception('Erro ao atualizar status da corrida: $e');
    }
  }

  /// Enviar notificação de mudança de status para o usuário
  Future<void> _sendRideStatusNotification({
    required String userId,
    required String rideId,
    required String status,
  }) async {
    try {
      late String title;
      late String body;
      late String type;

      switch (status) {
        case 'in_progress':
          title = '✅ Corrida Iniciada!';
          body = 'Seu motorista começou a corrida. Acompanhe em tempo real';
          type = 'ride_started';
          break;
        case 'completed':
          title = '🎉 Corrida Finalizada!';
          body = 'Sua corrida foi finalizada. Avalie seu motorista';
          type = 'ride_completed';
          break;
        default:
          return;
      }

      // Armazenar notificação no Firestore
      await _firestore.collection('notifications').add({
        'userId': userId,
        'rideId': rideId,
        'type': type,
        'title': title,
        'body': body,
        'status': status,
        'sent': false,
        'createdAt': DateTime.now(),
      });

      print('Notificação de status enviada: $title');
    } catch (e) {
      print('Erro ao enviar notificação de status: $e');
    }
  }

  /// Atualizar localização do motorista durante a corrida
  Future<void> updateDriverLocation(String driverId, double latitude, double longitude) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar localização: $e');
    }
  }

  /// Recusar uma corrida (para futuro uso)
  Future<void> declineRide(String rideId) async {
    try {
      // Por enquanto, apenas não fazer nada
      // Futuramente: registrar recusa, calcular taxa de aceitação, etc.
    } catch (e) {
      throw Exception('Erro ao recusar corrida: $e');
    }
  }

  /// Enviar notificação para o usuário
  Future<void> _sendNotificationToUser({
    required String userId,
    required String rideId,
    required String type,
    required String title,
    required String body,
  }) async {
    try {
      // Armazenar notificação no Firestore para Cloud Functions processar
      await _firestore
          .collection('notifications')
          .add({
        'userId': userId,
        'rideId': rideId,
        'type': type,
        'title': title,
        'body': body,
        'sent': false,
        'createdAt': DateTime.now(),
      });

      print('Notificação agendada para usuário: $userId');
    } catch (e) {
      print('Erro ao agendar notificação: $e');
    }
  }

  /// Calcular distância entre dois pontos (Haversine)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }
}
