import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users_app/models/place_suggestion.dart';
import 'package:users_app/models/ride_request.dart';
import 'package:users_app/screens/authentication/login_screen.dart';
import 'package:users_app/screens/ride_request_screen.dart';
import 'package:users_app/screens/ride_tracking_screen.dart';
import 'package:users_app/screens/rating_screen.dart';
import 'package:users_app/screens/payment_method_screen.dart';
import 'package:users_app/services/location_service.dart';
import 'package:users_app/services/driver_service.dart';
import 'package:users_app/services/places_service.dart';
import 'package:users_app/services/ride_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  final LocationService _locationService = LocationService();
  final DriverService _driverService = DriverService();
  final PlacesService _placesService = PlacesService();
  final RideService _rideService = RideService();

  Position? _currentPosition;
  final Set<Marker> _userMarker = {};

  // Controladores para os campos de texto
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();

  // Gerenciamento de foco e sugestões
  List<PlaceSuggestion> _suggestions = [];
  Timer? _debounce;

  // Posição inicial da câmera do mapa (fallback).
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    // Adiciona um listener para reconstruir a UI quando o foco mudar
    _destinationFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Limpeza dos controladores para evitar vazamento de memória
    _originController.dispose();
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    _debounce?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      if (kDebugMode) {
        print('Location received: Lat: ${position.latitude}, Lng: ${position.longitude}');
      }

      final newPosition = LatLng(position.latitude, position.longitude);
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 16));
      }

      final address = await _locationService.getAddressFromCoordinates(
          newPosition.latitude, newPosition.longitude);

      setState(() {
        _currentPosition = position; // Salva a posição no estado
        _userMarker.clear();
        _userMarker.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: newPosition,
          infoWindow: const InfoWindow(title: 'Sua Localização'),
        ));
        if (address != null) {
          _originController.text = address;
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível obter a localização. Verifique as permissões.')),
        );
      }
    }
  }

  void _onDestinationChanged(String input) {
    if (kDebugMode) print('DEBUG: _onDestinationChanged - input: $input, destinationController.text: ${_destinationController.text}');
    // Cancela o timer anterior para evitar chamadas múltiplas
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Inicia um novo timer
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (input.isNotEmpty) {
        // Passa a posição atual para a busca
        final suggestions = await _placesService.getAutocompleteSuggestions(input, _currentPosition);
        if (mounted) {
          setState(() {
            _suggestions = suggestions;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _suggestions = [];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print('DEBUG: build - destinationController.text: ${_destinationController.text}');
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
      body: Stack(
        children: [
          // Camada 1: O Mapa
          StreamBuilder<QuerySnapshot>(
            stream: _driverService.getDriversStream(),
            builder: (context, snapshot) {
              final Set<Marker> allMarkers = Set.from(_userMarker);

              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  if (data.containsKey('latitude') && data.containsKey('longitude')) {
                    var lat = data['latitude'];
                    var lng = data['longitude'];
                    final double latitude = (lat is int) ? lat.toDouble() : lat;
                    final double longitude = (lng is int) ? lng.toDouble() : lng;

                    if (kDebugMode) {
                      print('Processing driver: ${doc.id}, Lat: $latitude, Lng: ${longitude}');
                    }

                    allMarkers.add(
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: LatLng(latitude, longitude),
                        infoWindow: const InfoWindow(title: 'Sua Localização'),
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
          // Camada 2: O Painel de Busca
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _originController,
                    decoration: InputDecoration(
                      hintText: 'Ponto de partida',
                      prefixIcon: const Icon(Icons.my_location, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _destinationController,
                    focusNode: _destinationFocusNode,
                    onChanged: _onDestinationChanged,
                    decoration: InputDecoration(
                      hintText: 'Para onde vamos?',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botão de solicitar corrida
                  if (_originController.text.isNotEmpty && _destinationController.text.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _openPaymentAndRequestRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text(
                          'Solicitar Corrida',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Botão de histórico e configurações (menu flutuante)
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'payment',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
                    );
                  },
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.payment),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'history',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Histórico de corridas - Em desenvolvimento')),
                    );
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.history),
                ),
              ],
            ),
          ),
          // Camada 3: A Lista de Sugestões
          if (_suggestions.isNotEmpty && _destinationFocusNode.hasFocus)
            Positioned(
              top: 180, // Ajuste conforme necessário para ficar abaixo do painel
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                height: 200, // Altura máxima da lista
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      title: Text(suggestion.description),
                      onTap: () {
                        _destinationFocusNode.unfocus();
                        setState(() {
                          _destinationController.text = suggestion.description;
                          _suggestions = [];
                        });
                        if (kDebugMode) print('DEBUG: onTap - destinationController.text set to: ${_destinationController.text}');
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openPaymentAndRequestRide() async {
    try {
      // Obter a posição do destino através do Places API
      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Localização atual não disponível')),
        );
        return;
      }

      // Obter coordenadas do destino (simplificado - usar coordenadas aproximadas)
      final destinationSuggestions = await _placesService.getAutocompleteSuggestions(
        _destinationController.text,
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );

      if (destinationSuggestions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destino não encontrado')),
        );
        return;
      }

      final selectedDestination = destinationSuggestions.first;

      // Calcular a distância aproximada (usando fórmula simples)
      final estimatedDistance = _calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        -23.5505,
        -46.6333, // Coordenadas padrão (São Paulo)
      );

      // Navegar para RideRequestScreen
      final result = await Navigator.push<RideRequest>(
        context,
        MaterialPageRoute(
          builder: (context) => RideRequestScreen(
            origin: _originController.text,
            originLat: _currentPosition!.latitude,
            originLng: _currentPosition!.longitude,
            destination: _destinationController.text,
            destinationLat: -23.5505,
            destinationLng: -46.6333,
            estimatedDistance: estimatedDistance,
          ),
        ),
      );

      if (result != null) {
        // Limpar os campos de entrada
        _originController.clear();
        _destinationController.clear();

        // Navegar para RideTrackingScreen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideTrackingScreen(rideRequest: result),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao solicitar corrida: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao solicitar corrida: $e')),
      );
    }
  }

  // Função auxiliar para calcular distância entre coordenadas (Haversine)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}