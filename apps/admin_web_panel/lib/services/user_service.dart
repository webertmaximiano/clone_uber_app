import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web_panel/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Busca todos os usuários como um Stream (tempo real).
  Stream<List<User>> getUsersStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Busca um usuário específico pelo ID.
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  /// Cria um novo usuário.
  Future<void> createUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Erro ao criar usuário: $e');
      rethrow;
    }
  }

  /// Atualiza um usuário existente.
  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      rethrow;
    }
  }

  /// Deleta um usuário.
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Erro ao deletar usuário: $e');
      rethrow;
    }
  }

  /// Busca usuários com filtro (ex: por status ativo).
  Stream<List<User>> getUsersByStatus(bool isActive) {
    return _firestore
        .collection('users')
        .where('isActive', isEqualTo: isActive)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Conta o total de usuários.
  Future<int> getUserCount() async {
    try {
      final snapshot = await _firestore.collection('users').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Erro ao contar usuários: $e');
      return 0;
    }
  }

  /// Retorna contagem de usuários por status (ativo/inativo).
  Future<Map<String, int>> getUserCountByStatus() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final countByStatus = {
        'active': 0,
        'inactive': 0,
      };

      for (var user in users) {
        if (user.isActive) {
          countByStatus['active'] = (countByStatus['active'] ?? 0) + 1;
        } else {
          countByStatus['inactive'] = (countByStatus['inactive'] ?? 0) + 1;
        }
      }

      return countByStatus;
    } catch (e) {
      print('Erro ao contar usuários por status: $e');
      return {
        'active': 0,
        'inactive': 0,
      };
    }
  }
}
