import 'package:cloud_firestore/cloud_firestore.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna um Stream com as atualizações da coleção de motoristas.
  ///
  /// O `snapshots()` do Firestore garante que receberemos os dados em tempo real
  /// sempre que houver uma alteração no banco de dados.
  Stream<QuerySnapshot> getDriversStream() {
    // Por enquanto, estamos buscando todos os motoristas.
    // No futuro, podemos otimizar para buscar apenas os mais próximos.
    return _firestore.collection('drivers').snapshots();
  }
}
