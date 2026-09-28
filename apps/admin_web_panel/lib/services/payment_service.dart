import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web_panel/models/payment.dart';

class PaymentService {
  final FirebaseFirestore _firestore;

  PaymentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Busca todos os pagamentos como um Stream (tempo real).
  Stream<List<Payment>> getPaymentsStream() {
    return _firestore
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Busca um pagamento específico pelo ID.
  Future<Payment?> getPayment(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      if (doc.exists) {
        return Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar pagamento: $e');
      return null;
    }
  }

  /// Cria um novo pagamento.
  Future<void> createPayment(Payment payment) async {
    try {
      await _firestore.collection('payments').doc(payment.id).set(payment.toMap());
    } catch (e) {
      print('Erro ao criar pagamento: $e');
      rethrow;
    }
  }

  /// Atualiza um pagamento existente.
  Future<void> updatePayment(Payment payment) async {
    try {
      await _firestore.collection('payments').doc(payment.id).update(payment.toMap());
    } catch (e) {
      print('Erro ao atualizar pagamento: $e');
      rethrow;
    }
  }

  /// Deleta um pagamento.
  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection('payments').doc(paymentId).delete();
    } catch (e) {
      print('Erro ao deletar pagamento: $e');
      rethrow;
    }
  }

  /// Busca pagamentos com status específico em tempo real.
  Stream<List<Payment>> getPaymentsByStatusStream(String status) {
    return _firestore
        .collection('payments')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Busca pagamentos de um usuário específico.
  Stream<List<Payment>> getUserPaymentsStream(String userId) {
    return _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Busca pagamentos de um motorista específico.
  Stream<List<Payment>> getDriverPaymentsStream(String driverId) {
    return _firestore
        .collection('payments')
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Conta o total de pagamentos.
  Future<int> getPaymentCount() async {
    try {
      final snapshot = await _firestore.collection('payments').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Erro ao contar pagamentos: $e');
      return 0;
    }
  }

  /// Calcula a receita total (soma de todos os pagamentos completados).
  Future<double> getTotalRevenue() async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('status', isEqualTo: 'completed')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Erro ao calcular receita total: $e');
      return 0;
    }
  }
}
