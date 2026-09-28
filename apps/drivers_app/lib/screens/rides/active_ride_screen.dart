import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drivers_app/services/available_rides_service.dart';

class ActiveRideScreen extends StatefulWidget {
  const ActiveRideScreen({Key? key}) : super(key: key);

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  final AvailableRidesService _ridesService = AvailableRidesService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _isUpdatingStatus = false;

  late final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Atualizar localização continuamente
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Atualizar a cada 10 metros
        ),
      ).listen((Position position) {
        if (mounted) {
          setState(() => _currentPosition = position);
          _updateDriverLocation();
        }
      });
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }

  Future<void> _updateDriverLocation() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null && _currentPosition != null) {
      try {
        await _ridesService.updateDriverLocation(
          userId,
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      } catch (e) {
        // Silenciosamente falhar
      }
    }
  }

  Future<void> _updateRideStatus(String rideId, String newStatus) async {
    setState(() => _isUpdatingStatus = true);

    try {
      await _ridesService.updateRideStatus(rideId, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Corrida $newStatus com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      if (newStatus == 'completed') {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  void _updateMarkers(Map<String, dynamic> ride) {
    final originLat = ride['originLat'] as double?;
    final originLng = ride['originLng'] as double?;
    final destinationLat = ride['destinationLat'] as double?;
    final destinationLng = ride['destinationLng'] as double?;

    _markers.clear();

    if (originLat != null && originLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: LatLng(originLat, originLng),
          infoWindow: InfoWindow(title: ride['origin'] ?? 'Origem'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    if (destinationLat != null && destinationLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(destinationLat, destinationLng),
          infoWindow: InfoWindow(title: ride['destination'] ?? 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Sua Localização'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Corrida Ativa')),
        body: const Center(child: Text('Usuário não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corrida Ativa'),
        centerTitle: true,
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _ridesService.getActiveRideStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ride = snapshot.data;

          if (ride == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Você não tem corridas ativas',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          if (_isLoadingLocation || _currentPosition == null) {
            return const Center(child: CircularProgressIndicator());
          }

          _updateMarkers(ride);

          final rideStatus = ride['status'] as String?;
          final rideType = ride['rideType'] as String?;
          final estimatedFare = ride['estimatedFare'] as double? ?? 0.0;
          final origin = ride['origin'] as String?;
          final destination = ride['destination'] as String?;
          final estimatedDistance = ride['estimatedDistance'] as double? ?? 0.0;
          final rideId = ride['id'] as String?;

          return Column(
            children: [
              // Mapa
              Expanded(
                flex: 2,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),

              // Painel de informações
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status da corrida
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(rideStatus),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rideStatus?.toUpperCase() ?? 'DESCONHECIDO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Informações da corrida
                      _buildInfoRow('Tipo', rideType?.toUpperCase() ?? 'N/A'),
                      _buildInfoRow(
                        'Tarifa',
                        'R\$ ${estimatedFare.toStringAsFixed(2)}',
                      ),
                      _buildInfoRow(
                        'Distância',
                        '${estimatedDistance.toStringAsFixed(2)} km',
                      ),
                      const SizedBox(height: 16),

                      // Origem e destino resumidos
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              origin ?? 'Origem',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              destination ?? 'Destino',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Botões de ação
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isUpdatingStatus
                              ? null
                              : () {
                                  if (rideId != null) {
                                    final nextStatus = rideStatus == 'assigned'
                                        ? 'in_progress'
                                        : 'completed';
                                    _updateRideStatus(rideId, nextStatus);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: _isUpdatingStatus
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  rideStatus == 'assigned'
                                      ? 'Iniciar Corrida'
                                      : 'Finalizar Corrida',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
