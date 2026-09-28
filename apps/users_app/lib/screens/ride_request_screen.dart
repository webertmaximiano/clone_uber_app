import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:users_app/models/ride_request.dart';
import 'package:users_app/services/ride_service.dart';
import 'package:uuid/uuid.dart';

class RideRequestScreen extends StatefulWidget {
  final String origin;
  final double originLat;
  final double originLng;
  final String destination;
  final double destinationLat;
  final double destinationLng;
  final double estimatedDistance;

  const RideRequestScreen({
    Key? key,
    required this.origin,
    required this.originLat,
    required this.originLng,
    required this.destination,
    required this.destinationLat,
    required this.destinationLng,
    required this.estimatedDistance,
  }) : super(key: key);

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final RideService _rideService = RideService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedRideType = 'economy';
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> _rideTypes = {
    'economy': {
      'name': 'Economy',
      'description': 'Opção econômica',
      'multiplier': 1.0,
      'icon': Icons.directions_car,
      'color': Colors.green,
    },
    'comfort': {
      'name': 'Comfort',
      'description': 'Mais confortável',
      'multiplier': 1.5,
      'icon': Icons.car_rental,
      'color': Colors.blue,
    },
    'executive': {
      'name': 'Executive',
      'description': 'Executivo Premium',
      'multiplier': 2.0,
      'icon': Icons.sports_car,
      'color': Colors.purple,
    },
  };

  double _calculateFare() {
    const basePrice = 5.0;
    const pricePerKm = 2.5;
    final multiplier = _rideTypes[_selectedRideType]!['multiplier'] as double;
    return (basePrice + (widget.estimatedDistance * pricePerKm)) * multiplier;
  }

  int _calculateDuration() {
    const avgSpeed = 30; // km/h
    return (widget.estimatedDistance / avgSpeed * 60).ceil();
  }

  Future<void> _requestRide() async {
    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final rideId = const Uuid().v4();
      final fare = _calculateFare();
      final duration = _calculateDuration();

      final rideRequest = RideRequest(
        id: rideId,
        userId: userId,
        originAddress: widget.origin,
        originLatitude: widget.originLat,
        originLongitude: widget.originLng,
        destinationAddress: widget.destination,
        destinationLatitude: widget.destinationLat,
        destinationLongitude: widget.destinationLng,
        estimatedDistance: widget.estimatedDistance,
        estimatedFare: fare,
        rideType: _selectedRideType,
        status: 'pending',
        createdAt: DateTime.now(),
        estimatedDurationMinutes: duration,
      );

      await _rideService.createRideRequest(rideRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Corrida solicitada com sucesso!')),
        );
        Navigator.pop(context, rideRequest);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao solicitar corrida: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fare = _calculateFare();
    final duration = _calculateDuration();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Corrida'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rotas
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.green, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Origem', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(widget.origin, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Destino', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(widget.destination, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resumo da corrida
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.straighten, size: 24, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text('${widget.estimatedDistance.toStringAsFixed(1)} km'),
                          const Text('Distância', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.schedule, size: 24, color: Colors.orange),
                          const SizedBox(height: 8),
                          Text('$duration min'),
                          const Text('Tempo est.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.attach_money, size: 24, color: Colors.green),
                          const SizedBox(height: 8),
                          Text('R\$ ${fare.toStringAsFixed(2)}'),
                          const Text('Preço est.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seleção de tipo de corrida
              const Text(
                'Tipo de Corrida',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Column(
                children: _rideTypes.entries.map((entry) {
                  final type = entry.key;
                  final data = entry.value;
                  final isSelected = _selectedRideType == type;
                  final multiplier = data['multiplier'] as double;
                  final baseFare = _calculateFare() / multiplier;
                  final typeFare = baseFare * multiplier;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedRideType = type),
                    child: Card(
                      elevation: isSelected ? 4 : 1,
                      color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(
                              data['icon'] as IconData,
                              color: data['color'] as Color,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    data['description'] as String,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'R\$ ${typeFare.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.deepPurple),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Botão de confirmar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Solicitar Corrida',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
