import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String vehicleType,
    required String licensePlate,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create driver document in Firestore
      await _firestore.collection('drivers').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'profileImageUrl': '',
        'vehicleType': vehicleType,
        'licensePlate': licensePlate,
        'rating': 5.0,
        'totalEarnings': 0.0,
        'totalRides': 0,
        'isOnline': false,
        'isActive': true,
        'currentLatitude': 0.0,
        'currentLongitude': 0.0,
        'createdAt': DateTime.now(),
        'lastActive': DateTime.now(),
        'documentVerified': false,
      });

      return userCredential;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last active time
      await _firestore
          .collection('drivers')
          .doc(userCredential.user!.uid)
          .update({
        'lastActive': DateTime.now(),
      });

      return userCredential;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Check if driver exists, if not create
      final driverDoc = await _firestore
          .collection('drivers')
          .doc(userCredential.user!.uid)
          .get();

      if (!driverDoc.exists) {
        await _firestore
            .collection('drivers')
            .doc(userCredential.user!.uid)
            .set({
          'id': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? 'Motorista',
          'phoneNumber': userCredential.user!.phoneNumber ?? '',
          'profileImageUrl': userCredential.user!.photoURL ?? '',
          'vehicleType': '',
          'licensePlate': '',
          'rating': 5.0,
          'totalEarnings': 0.0,
          'totalRides': 0,
          'isOnline': false,
          'isActive': true,
          'currentLatitude': 0.0,
          'currentLongitude': 0.0,
          'createdAt': DateTime.now(),
          'lastActive': DateTime.now(),
          'documentVerified': false,
        });
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Update online status before signing out
      if (currentUser != null) {
        await _firestore
            .collection('drivers')
            .doc(currentUser!.uid)
            .update({
          'isOnline': false,
          'lastActive': DateTime.now(),
        });
      }

      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Update driver online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      if (currentUser != null) {
        await _firestore
            .collection('drivers')
            .doc(currentUser!.uid)
            .update({
          'isOnline': isOnline,
          'lastActive': DateTime.now(),
        });
      }
    } catch (e) {
      print('Error updating online status: $e');
      rethrow;
    }
  }

  // Update driver location
  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      if (currentUser != null) {
        await _firestore
            .collection('drivers')
            .doc(currentUser!.uid)
            .update({
          'currentLatitude': latitude,
          'currentLongitude': longitude,
          'lastActive': DateTime.now(),
        });
      }
    } catch (e) {
      print('Error updating location: $e');
      rethrow;
    }
  }
}
