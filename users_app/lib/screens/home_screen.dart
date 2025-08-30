import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importação para Firebase Auth
import 'package:users_app/screens/authentication/login_screen.dart'; // Importação para a tela de Login

/// Tela Principal do Aplicativo
///
/// Esta será a tela que o usuário verá após fazer login com sucesso.
/// Por enquanto, é um placeholder simples.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo!'),
        centerTitle: true,
        actions: [
          // Botão de Logout
          IconButton(
            icon: const Icon(Icons.logout), // Ícone de logout
            onPressed: () async {
              // Lógica para fazer logout do Firebase.
              await FirebaseAuth.instance.signOut();
              // Após o logout, navega para a tela de Login e remove todas as rotas anteriores.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false, // Remove todas as rotas anteriores
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Você está logado!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
