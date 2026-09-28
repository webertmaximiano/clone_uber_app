import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web_panel/models/ride.dart';

class RideService {
  final FirebaseFirestore _firestore;

  RideService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Busca todas as corridas como um Stream (tempo real).
  Stream<List<Ride>> getRidesStream() {
    return _firestore
        .collection('rides')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Ride.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Busca uma corrida específica pelo ID.
  Future<Ride?> getRide(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      if (doc.exists) {
        return Ride.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar corrida: $e');
      return null;
    }
  }

  /// Cria uma nova corrida.
  Future<void> createRide(Ride ride) async {
    try {
      await _firestore.collection('rides').doc(ride.id).set(ride.toMap());
    } catch (e) {
      print('Erro ao criar corrida: $e');
      rethrow;
    }
  }

  /// Atualiza uma corrida existente.
  Future<void> updateRide(Ride ride) async {
    try {
      await _firestore.collection('rides').doc(ride.id).update(ride.toMap());
    } catch (e) {
      print('Erro ao atualizar corrida: $e');
      rethrow;
    }
  }

  /// Deleta uma corrida.
  Future<void> deleteRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).delete();
    } catch (e) {
      print('Erro ao deletar corrida: $e');
      rethrow;
    }
  }

  /// Busca corridas ativas (pending ou in_progress) em tempo real.
  Stream<List<Ride>> getActiveRidesStream() {
    return _firestore
        .collection('rides')
        .where('status', whereIn: ['pending', 'in_progress'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Ride.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Busca corridas de um usuário específico.
  Stream<List<Ride>> getUserRidesStream(String userId) {
    return _firestore
        .collection('rides')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Ride.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Busca corridas de um motorista específico.
  Stream<List<Ride>> getDriverRidesStream(String driverId) {
    return _firestore
        .collection('rides')
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Ride.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Conta o total de corridas.
  Future<int> getRideCount() async {
    try {
      final snapshot = await _firestore.collection('rides').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Erro ao contar corridas: $e');
      return 0;
    }
  }

  /// Conta corridas ativas.
  Future<int> getActiveRideCount() async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('status', whereIn: ['pending', 'in_progress'])
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Erro ao contar corridas ativas: $e');
      return 0;
    }
  }

  /// Retorna contagem de corridas por status (para gráficos).
  Future<Map<String, int>> getRideCountByStatus() async {
    try {
      final snapshot = await _firestore.collection('rides').get();
      final rides = snapshot.docs
          .map((doc) => Ride.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final countByStatus = {
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (var ride in rides) {
        countByStatus[ride.status] = (countByStatus[ride.status] ?? 0) + 1;
      }

      return countByStatus;
    } catch (e) {
      print('Erro ao contar corridas por status: $e');
      return {
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
      };
    }
  }

  /// Retorna receita do último período por dia (para gráfico de linha).
  Future<List<double>> get7DayRevenue() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('payments')
          .where('status', isEqualTo: 'completed')
          .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
          .get();

      final dailyRevenue = List<double>.filled(7, 0.0);

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final amount = (data['amount'] as num).toDouble();
        final daysAgo = now.difference(createdAt).inDays;

        if (daysAgo >= 0 && daysAgo < 7) {
          dailyRevenue[6 - daysAgo] += amount;
        }
      }

      return dailyRevenue;
    } catch (e) {
      print('Erro ao buscar receita de 7 dias: $e');
      return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    }
  }
}
