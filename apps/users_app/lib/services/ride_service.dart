import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:users_app/models/ride_request.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar nova solicitação de corrida
  Future<String> createRideRequest(RideRequest rideRequest) async {
    try {
      final docRef = await _firestore.collection('rides').add(rideRequest.toMap());
      
      // Notificar motoristas próximos sobre nova corrida
      await _notifyNearbyDrivers(
        rideId: docRef.id,
        origin: rideRequest.origin,
        originLat: rideRequest.originLat,
        originLng: rideRequest.originLng,
        rideType: rideRequest.rideType,
      );
      
      return docRef.id;
    } catch (e) {
      print('Erro ao criar solicitação de corrida: $e');
      rethrow;
    }
  }

  // Notificar motoristas próximos sobre nova corrida
  Future<void> _notifyNearbyDrivers({
    required String rideId,
    required String origin,
    required double originLat,
    required double originLng,
    required String rideType,
  }) async {
    try {
      // Armazenar notificação genérica que será processada por Cloud Function
      // A Cloud Function vai consultar drivers online próximos e enviar notificações individuais
      await _firestore
          .collection('ride_notifications')
          .add({
        'rideId': rideId,
        'origin': origin,
        'originLat': originLat,
        'originLng': originLng,
        'rideType': rideType,
        'type': 'new_ride_available',
        'title': '🚗 Nova Corrida Disponível!',
        'body': 'Corrida de $rideType saindo de $origin',
        'createdAt': DateTime.now(),
        'processed': false,
      });

      print('Notificação de nova corrida criada para motoristas');
    } catch (e) {
      print('Erro ao notificar motoristas: $e');
      // Não fazer rethrow pois é uma funcionalidade secundária
    }
  }

  // Buscar corrida atual do usuário
  Stream<RideRequest?> getUserActiveRideStream(String userId) {
    return _firestore
        .collection('rides')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'assigned', 'in_progress'])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return RideRequest.fromMap(
        snapshot.docs.first.data() as Map<String, dynamic>,
        snapshot.docs.first.id,
      );
    });
  }

  // Buscar corrida específica
  Future<RideRequest?> getRideRequest(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      if (doc.exists) {
        return RideRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar corrida: $e');
      return null;
    }
  }

  // Atualizar status da corrida e notificar usuário
  Future<void> updateRideStatus(String rideId, String status) async {
    try {
      // Obter dados da corrida antes de atualizar
      final rideDoc = await _firestore.collection('rides').doc(rideId).get();
      final rideData = rideDoc.data() as Map<String, dynamic>?;
      final userId = rideData?['userId'] as String?;

      // Atualizar status
      await _firestore.collection('rides').doc(rideId).update({
        'status': status,
        if (status == 'in_progress') 'startedAt': DateTime.now(),
        if (status == 'completed') 'completedAt': DateTime.now(),
      });

      // Enviar notificação ao usuário sobre mudança de status
      if (userId != null) {
        await _sendRideStatusNotification(
          userId: userId,
          rideId: rideId,
          status: status,
          rideData: rideData,
        );
      }
    } catch (e) {
      print('Erro ao atualizar status da corrida: $e');
      rethrow;
    }
  }

  // Enviar notificação de mudança de status
  Future<void> _sendRideStatusNotification({
    required String userId,
    required String rideId,
    required String status,
    required Map<String, dynamic> rideData,
  }) async {
    try {
      late String title;
      late String body;
      late String type;

      switch (status) {
        case 'assigned':
          title = '🚗 Motorista Encontrado!';
          body = 'Um motorista foi atribuído à sua corrida e está a caminho';
          type = 'ride_assigned';
          break;
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
        case 'cancelled':
          title = '❌ Corrida Cancelada';
          body = 'Sua corrida foi cancelada';
          type = 'ride_cancelled';
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

  // Cancelar corrida
  Future<void> cancelRideRequest(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      print('Erro ao cancelar corrida: $e');
      rethrow;
    }
  }

  // Buscar histórico de corridas do usuário
  Future<List<RideRequest>> getUserRideHistory(String userId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => RideRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar histórico de corridas: $e');
      return [];
    }
  }

  // Atualizar localização do motorista na corrida
  Future<void> updateDriverLocation(String rideId, double latitude, double longitude) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'driverLatitude': latitude,
        'driverLongitude': longitude,
      });
    } catch (e) {
      print('Erro ao atualizar localização do motorista: $e');
    }
  }

  // Enviar notificação para o usuário (via Cloud Messaging)
  Future<void> sendNotificationToUser({
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
}
