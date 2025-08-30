import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:users_app/screens/authentication/splash_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- Adicione este bloco de código ---
  if (kDebugMode) {
    // Conecta o Firebase Auth ao emulador local APENAS SE NÃO FOR WEB.
    // Para web, o Google Sign-In funciona melhor com o serviço real do Firebase.
    if (!kIsWeb) { // Adicione esta condição!
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    }
  }
  // --- Fim do bloco de código a ser adicionado ---

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Passageiro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
