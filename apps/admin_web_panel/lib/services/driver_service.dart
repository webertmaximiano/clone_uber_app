import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web_panel/models/driver.dart';

class DriverService {
  final FirebaseFirestore _firestore;

  DriverService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Busca todos os motoristas como um Stream (tempo real).
  Stream<List<Driver>> getDriversStream() {
    return _firestore
        .collection('drivers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Driver.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Busca um motorista específico pelo ID.
  Future<Driver?> getDriver(String driverId) async {
    try {
      final doc = await _firestore.collection('drivers').doc(driverId).get();
      if (doc.exists) {
        return Driver.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar motorista: $e');
      return null;
    }
  }

  /// Cria um novo motorista.
  Future<void> createDriver(Driver driver) async {
    try {
      await _firestore.collection('drivers').doc(driver.id).set(driver.toMap());
    } catch (e) {
      print('Erro ao criar motorista: $e');
      rethrow;
    }
  }

  /// Atualiza um motorista existente.
  Future<void> updateDriver(Driver driver) async {
    try {
      await _firestore.collection('drivers').doc(driver.id).update(driver.toMap());
    } catch (e) {
      print('Erro ao atualizar motorista: $e');
      rethrow;
    }
  }

  /// Deleta um motorista.
  Future<void> deleteDriver(String driverId) async {
    try {
      await _firestore.collection('drivers').doc(driverId).delete();
    } catch (e) {
      print('Erro ao deletar motorista: $e');
      rethrow;
    }
  }

  /// Busca motoristas online em tempo real.
  Stream<List<Driver>> getOnlineDriversStream() {
    return _firestore
        .collection('drivers')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Driver.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Conta o total de motoristas.
  Future<int> getDriverCount() async {
    try {
      final snapshot = await _firestore.collection('drivers').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Erro ao contar motoristas: $e');
      return 0;
    }
  }

  /// Busca motoristas ativos.
  Stream<List<Driver>> getActiveDriversStream() {
    return _firestore
        .collection('drivers')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Driver.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
