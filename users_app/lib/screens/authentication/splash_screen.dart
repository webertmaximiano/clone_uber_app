import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importação para Firebase Auth
import 'package:users_app/screens/authentication/login_screen.dart';
import 'package:users_app/screens/home_screen.dart'; // Importação para a tela principal

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  /// O método initState() é chamado apenas uma vez quando o widget é inserido
  /// na árvore de widgets. É o lugar perfeito para inicializar dados ou, como
  /// neste caso, iniciar uma tarefa que só precisa ser executada uma vez.
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  /// Verifica o estado de autenticação do usuário e navega para a tela apropriada.
  void _checkAuthState() {
    // FirebaseAuth.instance.authStateChanges() é um Stream que emite um evento
    // sempre que o estado de autenticação do usuário muda (login, logout).
    // O .listen() nos permite reagir a esses eventos.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // Adicionamos um pequeno atraso para que a Splash Screen seja visível.
      Timer(const Duration(seconds: 3), () {
        // Verifica se o widget ainda está montado antes de tentar navegar.
        if (mounted) {
          if (user == null) {
            // Se o usuário for nulo, significa que não há ninguém logado.
            // Navega para a tela de Login.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else {
            // Se o usuário não for nulo, significa que há alguém logado.
            // Navega para a tela principal (Home).
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Carregando...',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
