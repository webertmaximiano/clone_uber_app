import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _firebaseAuth;

  // O construtor permite injetar uma instância do FirebaseAuth para testes,
  // mas usará a instância global por padrão.
  AuthService({FirebaseAuth? firebaseAuth}) 
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Inicia o fluxo de login com Google, usando o método apropriado para a plataforma.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      if (kIsWeb) {
        // --- FLUXO PARA WEB ---
        // Usa o método signInWithPopup, que é o padrão para navegadores.
        final UserCredential userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        // --- FLUXO PARA MOBILE (Android/iOS) ---
        // Usa o método signInWithProvider, que usa o fluxo nativo do SO.
        final UserCredential userCredential = await _firebaseAuth.signInWithProvider(googleProvider);
        return userCredential.user;
      }

    } on FirebaseAuthException catch (e) {
      // Erro comum quando o usuário fecha a janela de login.
      if (e.code == 'cancelled-popup-request' || e.code == 'popup-closed-by-user' || e.code == 'sign_in_canceled') {
        print('Fluxo de login com Google cancelado pelo usuário.');
        return null;
      }
      // TODO: Adicionar tratamento para outros códigos de erro específicos.
      print('Ocorreu um erro de autenticação do Firebase: $e');
      return null;
    } catch (e) {
      // Captura de outros erros inesperados.
      print('Ocorreu um erro inesperado: $e');
      return null;
    }
  }
}