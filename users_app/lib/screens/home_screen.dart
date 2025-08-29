import 'package:flutter/material.dart';

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
