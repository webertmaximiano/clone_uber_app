import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:drivers_app/firebase_options.dart';
import 'package:drivers_app/screens/authentication/splash_screen.dart';
import 'package:drivers_app/screens/authentication/driver_login_screen.dart';
import 'package:drivers_app/screens/authentication/driver_signup_screen.dart';
import 'package:drivers_app/screens/dashboard/driver_dashboard.dart';
import 'package:drivers_app/services/driver_notification_service.dart';
import 'package:drivers_app/services/ride_listener_service.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DriverApp());
}

class DriverApp extends StatefulWidget {
  const DriverApp({Key? key}) : super(key: key);

  @override
  State<DriverApp> createState() => _DriverAppState();
}

class _DriverAppState extends State<DriverApp> {
  late DriverNotificationService _notificationService;
  late RideListenerService _rideListenerService;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeRideListener();
  }

  Future<void> _initializeNotifications() async {
    _notificationService = DriverNotificationService();
    await _notificationService.initialize();
  }

  Future<void> _initializeRideListener() async {
    _rideListenerService = RideListenerService(_notificationService);
    
    // Iniciar escuta de novas corridas com localização atual
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      
      if (mounted) {
        _rideListenerService.startListeningForNewRides(
          driverLat: position.latitude,
          driverLng: position.longitude,
          driverId: 'motorista', // Será substituído pela lógica real
          radiusKm: 5.0,
        );
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber Clone - Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.deepPurple.shade600,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const DriverLoginScreen(),
        '/signup': (context) => const DriverSignupScreen(),
        '/dashboard': (context) => const DriverDashboard(),
      },
    );
  }
}
