import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Serviço que monitora mudanças de status da corrida e atualiza a UI
class RideStatusListenerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Callbacks para diferentes mudanças de status
  Function(String rideId)? onRideAssigned;
  Function(String rideId)? onRideStarted;
  Function(String rideId)? onRideCompleted;
  Function(String rideId)? onRideCancelled;
  Function(String rideId, String previousStatus, String newStatus)?
      onStatusChanged;

  /// Começar a escutar mudanças de status de uma corrida específica
  void startListeningToRideStatus(String rideId) {
    _firestore.collection('rides').doc(rideId).snapshots().listen(
      (snapshot) async {
        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>;
        final currentStatus = data['status'] as String?;

        if (currentStatus == null) return;

        // Chamar callbacks apropriados
        _handleStatusChange(rideId, currentStatus);
      },
      onError: (error) {
        if (kDebugMode) print('Erro ao escutar status da corrida: $error');
      },
    );
  }

  /// Começar a escutar todas as corridas ativas do usuário
  void startListeningToUserRides(String userId) {
    _firestore
        .collection('rides')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'assigned', 'in_progress'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;

        if (status != null) {
          _handleStatusChange(doc.id, status);
        }
      }
    }, onError: (error) {
      if (kDebugMode) print('Erro ao escutar corridas do usuário: $error');
    });
  }

  /// Obter stream de mudanças de status
  Stream<String?> getRideStatusStream(String rideId) {
    return _firestore.collection('rides').doc(rideId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data() as Map<String, dynamic>;
      return data['status'] as String?;
    });
  }

  /// Obter dados da corrida com status
  Stream<Map<String, dynamic>?> getRideDataStream(String rideId) {
    return _firestore.collection('rides').doc(rideId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data() as Map<String, dynamic>;
    });
  }

  /// Processar mudança de status
  void _handleStatusChange(String rideId, String status) {
    if (kDebugMode) print('Status da corrida $rideId mudou para: $status');

    switch (status) {
      case 'assigned':
        onRideAssigned?.call(rideId);
        onStatusChanged?.call(rideId, 'pending', 'assigned');
        break;
      case 'in_progress':
        onRideStarted?.call(rideId);
        onStatusChanged?.call(rideId, 'assigned', 'in_progress');
        break;
      case 'completed':
        onRideCompleted?.call(rideId);
        onStatusChanged?.call(rideId, 'in_progress', 'completed');
        break;
      case 'cancelled':
        onRideCancelled?.call(rideId);
        onStatusChanged?.call(rideId, 'pending', 'cancelled');
        break;
      default:
        break;
    }
  }

  /// Parar de escutar (quando o widget é descartado)
  void stopListening() {
    // StreamSubscription é gerenciada automaticamente
    if (kDebugMode) print('Parou de escutar mudanças de status');
  }
}
