import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_app/screens/authentication/login_screen.dart';
import 'package:geolocator/geolocator.dart'; // Import para o Geolocator
import 'package:users_app/services/location_service.dart'; // Import para o nosso LocationService
import 'package:users_app/services/driver_service.dart'; // Import para o nosso DriverService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  final LocationService _locationService = LocationService();
  final DriverService _driverService = DriverService();
  final Set<Marker> _userMarker = {}; // Marcador do usuário separado

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
      // DEBUG: Imprime a localização recebida
      if (kDebugMode) {
        print('Location received: Lat: ${position.latitude}, Lng: ${position.longitude}');
      }

      final newPosition = LatLng(position.latitude, position.longitude);
      // Adicionado um null-check para _controller
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 16));
      }

      setState(() {
        _userMarker.clear();
        _userMarker.add(Marker(
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _driverService.getDriversStream(),
        builder: (context, snapshot) {
          // Começamos com o marcador do usuário e adicionamos os dos motoristas.
          final Set<Marker> allMarkers = Set.from(_userMarker);

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              // Validação simples para garantir que os dados de localização existem
              if (data.containsKey('latitude') && data.containsKey('longitude')) {
                var lat = data['latitude'];
                var lng = data['longitude'];

                // Garante que lat e lng são double
                final double latitude = (lat is int) ? lat.toDouble() : lat;
                final double longitude = (lng is int) ? lng.toDouble() : lng;

                // DEBUG: Imprime os dados do motorista que está sendo processado
                if (kDebugMode) {
                  print('Processing driver: ${doc.id}, Lat: $latitude, Lng: $longitude');
                }

                allMarkers.add(
                  Marker(
                    markerId: MarkerId(doc.id),
                    position: LatLng(latitude, longitude),
                    infoWindow: InfoWindow(title: data['name'] ?? 'Motorista'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  ),
                );
              }
            }
          }

          return GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              _getCurrentLocation();
            },
            markers: allMarkers,
          );
        },
      ),
    );
  }
}
