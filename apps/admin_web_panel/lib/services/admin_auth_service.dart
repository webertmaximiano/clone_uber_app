import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  final FirebaseAuth _firebaseAuth;

  // O construtor permite injetar uma instância do FirebaseAuth para testes,
  // mas usará a instância global por padrão.
  AdminAuthService({FirebaseAuth? firebaseAuth}) 
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Faz login com e-mail e senha.
  /// Retorna o usuário se bem-sucedido, null caso contrário.
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Erro de autenticação: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Faz logout do usuário atual.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Retorna o usuário atualmente autenticado.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Stream que emite mudanças no estado de autenticação.
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}
