import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.shade100,
              ),
              child: Icon(
                Icons.directions_car,
                size: 60,
                color: Colors.deepPurple.shade600,
              ),
            ),
            const SizedBox(height: 30),

            // App Title
            Text(
              'Uber Clone',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade600,
                  ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Driver App',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 50),

            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Colors.deepPurple.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
