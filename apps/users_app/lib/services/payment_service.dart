import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:users_app/models/payment_method.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar método de pagamento
  Future<String> createPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(paymentMethod.userId)
          .collection('paymentMethods')
          .add(paymentMethod.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao criar método de pagamento: $e');
      rethrow;
    }
  }

  // Buscar métodos de pagamento do usuário
  Future<List<PaymentMethod>> getUserPaymentMethods(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .get();

      return snapshot.docs
          .map((doc) => PaymentMethod.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar métodos de pagamento: $e');
      return [];
    }
  }

  // Atualizar método de pagamento padrão
  Future<void> setDefaultPaymentMethod(String userId, String paymentMethodId) async {
    try {
      // Primeiro, desabilitar todos os métodos como padrão
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'isDefault': false});
      }

      // Depois, habilitar o selecionado
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(paymentMethodId)
          .update({'isDefault': true});
    } catch (e) {
      print('Erro ao atualizar método de pagamento padrão: $e');
      rethrow;
    }
  }

  // Deletar método de pagamento
  Future<void> deletePaymentMethod(String userId, String paymentMethodId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(paymentMethodId)
          .delete();
    } catch (e) {
      print('Erro ao deletar método de pagamento: $e');
      rethrow;
    }
  }

  // Registrar pagamento de corrida
  Future<String> recordPayment({
    required String rideId,
    required String userId,
    required String driverId,
    required double amount,
    required String paymentType,
  }) async {
    try {
      final docRef = await _firestore.collection('payments').add({
        'rideId': rideId,
        'userId': userId,
        'driverId': driverId,
        'amount': amount,
        'paymentType': paymentType,
        'status': 'completed',
        'createdAt': DateTime.now(),
      });

      return docRef.id;
    } catch (e) {
      print('Erro ao registrar pagamento: $e');
      rethrow;
    }
  }

  // Adicionar saldo à carteira
  Future<void> addWalletBalance(String userId, double amount) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final currentBalance = (userDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;

      await _firestore.collection('users').doc(userId).update({
        'walletBalance': currentBalance + amount,
      });
    } catch (e) {
      print('Erro ao adicionar saldo à carteira: $e');
      rethrow;
    }
  }

  // Verificar saldo da carteira
  Future<double> getWalletBalance(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return (userDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('Erro ao verificar saldo da carteira: $e');
      return 0.0;
    }
  }
}
