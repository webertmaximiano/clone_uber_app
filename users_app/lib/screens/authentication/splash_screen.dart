// [0] IMPORTAÇÕES NECESSÁRIAS
// Cada 'import' traz funcionalidades essenciais para o nosso arquivo.
// Sem eles, o Dart não saberia o que são 'Future', 'Widget', 'FirebaseAuth', etc.
import 'dart:async'; // Correto!
// Traz a classe 'Timer' e a funcionalidade 'Future'.
import 'package:flutter/material.dart'; // A biblioteca principal do Flutter para UI.
import 'package:firebase_auth/firebase_auth.dart'; // Traz tudo relacionado à autenticação do Firebase.
import 'package:users_app/screens/authentication/login_screen.dart'; // Permite navegar para a tela de Login.
import 'package:users_app/screens/home_screen.dart'; // Permite navegar para a tela Principal.

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

    // [3.4] NAVEGAÇÃO
    // Usamos Navigator.pushReplacement para que o usuário não consiga
    // voltar para a SplashScreen apertando o botão "voltar" do celular.
    if (user == null) {
      // Se NÃO há usuário, o app substitui a SplashScreen pela LoginScreen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Se HÁ um usuário, o app substitui a SplashScreen pela HomeScreen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // [4] CONSTRUÇÃO DA INTERFACE (UI)
  // O que o usuário vê enquanto a lógica acima está rodando.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DICA: Coloque a logo do seu aplicativo aqui.
            // Exemplo: Image.asset('assets/images/logo.png', height: 150),
            
            SizedBox(height: 30),

            Text(
              'Inicializando...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 20),
            
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}