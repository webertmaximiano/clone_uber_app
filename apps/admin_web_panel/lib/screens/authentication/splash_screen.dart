// [0] IMPORTAÇÕES NECESSÁRIAS
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_web_panel/screens/authentication/login_screen.dart';
import 'package:admin_web_panel/screens/dashboard/dashboard_screen.dart';

// [1] DEFINIÇÃO DO WIDGET
// Um StatefulWidget é necessário porque a tela executa uma lógica
// de inicialização (initState) para decidir para onde navegar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // [2] MÉTODO initState
  // Este método é chamado pelo Flutter exatamente uma vez, quando o widget
  // é criado. É o local perfeito para iniciar tarefas de inicialização.
  @override
  void initState() {
    super.initState();
    // Chamamos nossa função de redirecionamento assim que a tela é construída.
    _redirectAfterDelay();
  }

  // [3] LÓGICA DE REDIRECIONAMENTO
  // Esta é a função principal da SplashScreen. Ela tem um único trabalho:
  // esperar um pouco e depois enviar o usuário para o lugar certo.
  Future<void> _redirectAfterDelay() async {
    // [3.1] ESPERA
    // Usamos Future.delayed para garantir que sua tela de splash
    // (com sua logo, por exemplo) seja visível por um curto período.
    await Future.delayed(const Duration(seconds: 3));

    // [3.2] VERIFICAÇÃO DE SEGURANÇA (if mounted)
    // Antes de qualquer navegação, verificamos se o widget ainda está
    // "montado" (visível na tela). Isso previne erros que podem
    // acontecer se o usuário fechar o app durante esses 3 segundos.
    if (!mounted) return;

    // [3.3] VERIFICAÇÃO DO USUÁRIO (UMA ÚNICA VEZ)
    // Verificamos o 'currentUser' para saber se já existe uma sessão ativa.
    final user = FirebaseAuth.instance.currentUser;

    // [3.4] REDIRECIONAMENTO BASEADO NO ESTADO
    if (user != null) {
      // Usuário já autenticado -> Dashboard
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      // Nenhum usuário -> Login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // [4] BUILD - A interface visual
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou ícone da aplicação
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            // Texto de boas-vindas
            const Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Clone Uber Management System',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            // Indicador de carregamento
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}
