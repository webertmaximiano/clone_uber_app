import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_app/screens/authentication/login_screen.dart';
import 'package:geolocator/geolocator.dart'; // Import para o Geolocator
import 'package:users_app/services/location_service.dart'; // Import para o nosso LocationService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  final LocationService _locationService = LocationService();
  Set<Marker> _markers = {};

  // Posição inicial da câmera do mapa (fallback).
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation(); // Removido daqui
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final newPosition = LatLng(position.latitude, position.longitude);
      // Adicionado um null-check para _controller
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 16));
      }

      setState(() {
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: newPosition,
          infoWindow: const InfoWindow(title: 'Sua Localização'),
        ));
      });
    } else {
      // Tratar caso a localização não possa ser obtida (ex: permissão negada)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível obter a localização. Verifique as permissões.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uber Clone'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        mapType: MapType.normal,
        myLocationEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _getCurrentLocation(); // Chamado aqui
        },
        markers: _markers,
      ),
    );
  }
}