import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:admin_web_panel/screens/authentication/splash_screen.dart';
import 'package:admin_web_panel/screens/authentication/login_screen.dart';
import 'package:admin_web_panel/screens/dashboard/dashboard_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    // Conecta o Firebase Auth ao emulador local APENAS SE NÃO FOR WEB.
    // Web usa popup de autenticação, portanto emulador não é aplicável.
    if (!kIsWeb) {
      try {
        FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      } catch (e) {
        // Hot restart pode causar um erro se o emulador já estiver configurado.
        print('Erro ao configurar emulador do Auth (ignorado em debug): $e');
      }
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin - Clone Uber',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
