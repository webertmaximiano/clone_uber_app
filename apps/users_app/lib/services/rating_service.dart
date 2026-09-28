import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:users_app/models/ride_rating.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar avaliação da corrida
  Future<String> createRideRating(RideRating rating) async {
    try {
      final docRef = await _firestore.collection('ratings').add(rating.toMap());
      
      // Atualizar rating do motorista no Firestore
      await _updateDriverRating(rating.driverId);
      
      return docRef.id;
    } catch (e) {
      print('Erro ao criar avaliação: $e');
      rethrow;
    }
  }

  // Atualizar rating médio do motorista
  Future<void> _updateDriverRating(String driverId) async {
    try {
      final ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('driverId', isEqualTo: driverId)
          .get();

      if (ratingsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in ratingsSnapshot.docs) {
          totalRating += (doc['rating'] as num).toDouble();
        }
        final averageRating = totalRating / ratingsSnapshot.docs.length;

        // Atualizar driver
        await _firestore.collection('drivers').doc(driverId).update({
          'rating': averageRating,
        });
      }
    } catch (e) {
      print('Erro ao atualizar rating do motorista: $e');
    }
  }

  // Buscar avaliações de um motorista
  Future<List<RideRating>> getDriverRatings(String driverId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RideRating.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar avaliações: $e');
      return [];
    }
  }

  // Verificar se usuário já avaliou esta corrida
  Future<bool> hasUserRatedRide(String userId, String rideId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: userId)
          .where('rideId', isEqualTo: rideId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar avaliação: $e');
      return false;
    }
  }
}
