import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drivers_app/services/available_rides_service.dart';
import 'package:drivers_app/screens/rides/accept_ride_details_screen.dart';

class AvailableRidesScreen extends StatefulWidget {
  const AvailableRidesScreen({Key? key}) : super(key: key);

  @override
  State<AvailableRidesScreen> createState() => _AvailableRidesScreenState();
}

class _AvailableRidesScreenState extends State<AvailableRidesScreen> {
  final AvailableRidesService _ridesService = AvailableRidesService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;

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
    } catch (e) {
      setState(() {
        _locationError = 'Erro ao obter localização: $e';
        _isLoadingLocation = false;
      });
    }
  }

  void _showRideDetails(Map<String, dynamic> ride) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AcceptRideDetailsScreen(rideData: ride),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return Scaffold(
        appBar: AppBar(title: const Text('Corridas Disponíveis')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_locationError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Corridas Disponíveis')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_locationError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Corridas Disponíveis')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corridas Disponíveis'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ridesService.getAvailableRidesStream(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          radiusKm: 10.0,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final rides = snapshot.data ?? [];

          if (rides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma corrida disponível no momento',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Atualizar'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                final distance = ride['distance'] as double;
                final fare = ride['estimatedFare'] as double?;
                final rideType = ride['rideType'] as String?;
                final origin = ride['origin'] as String?;
                final destination = ride['destination'] as String?;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tipo de corrida e distância
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRideTypeColor(rideType),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                rideType?.toUpperCase() ?? 'PADRÃO',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${distance.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Origem
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                origin ?? 'Origem desconhecida',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Destino
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                destination ?? 'Destino desconhecido',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Tarifa
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'R\$ ${fare?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _showRideDetails(ride),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: const Text(
                                'Aceitar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getRideTypeColor(String? rideType) {
    switch (rideType?.toLowerCase()) {
      case 'economy':
        return Colors.blue;
      case 'comfort':
        return Colors.orange;
      case 'executive':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}
