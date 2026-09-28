import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drivers_app/services/available_rides_service.dart';

class AcceptRideDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;

  const AcceptRideDetailsScreen({
    Key? key,
    required this.rideData,
  }) : super(key: key);

  @override
  State<AcceptRideDetailsScreen> createState() =>
      _AcceptRideDetailsScreenState();
}

class _AcceptRideDetailsScreenState extends State<AcceptRideDetailsScreen> {
  final AvailableRidesService _ridesService = AvailableRidesService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isAccepting = false;
  Position? _currentPosition;

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
      setState(() => _currentPosition = position);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }

  Future<void> _acceptRide() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização não disponível')),
      );
      return;
    }

    setState(() => _isAccepting = true);

    try {
      final rideId = widget.rideData['id'];
      await _ridesService.acceptRide(
        rideId,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Corrida aceita com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retornar true para indicar sucesso
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aceitar corrida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final origin = widget.rideData['origin'] ?? 'Origem desconhecida';
    final originLat = widget.rideData['originLat'] ?? 0.0;
    final originLng = widget.rideData['originLng'] ?? 0.0;
    final destination = widget.rideData['destination'] ?? 'Destino desconhecido';
    final destinationLat = widget.rideData['destinationLat'] ?? 0.0;
    final destinationLng = widget.rideData['destinationLng'] ?? 0.0;
    final estimatedDistance = widget.rideData['estimatedDistance'] as double? ?? 0.0;
    final estimatedFare = widget.rideData['estimatedFare'] as double? ?? 0.0;
    final rideType = widget.rideData['rideType'] as String? ?? 'economy';
    final distance = widget.rideData['distance'] as double? ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Corrida'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card com tipo de corrida
            Card(
              color: _getRideTypeColor(rideType),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rideType.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${estimatedFare.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Até você',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seção: Origem
            const Text(
              'Origem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          origin,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Latitude: ${originLat.toStringAsFixed(4)}, Longitude: ${originLng.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Seção: Destino
            const Text(
              'Destino',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          destination,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Latitude: ${destinationLat.toStringAsFixed(4)}, Longitude: ${destinationLng.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seção: Informações da corrida
            const Text(
              'Informações da Corrida',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Distância',
                    '${estimatedDistance.toStringAsFixed(2)} km',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Tarifa Estimada',
                    'R\$ ${estimatedFare.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Tipo de Corrida',
                    rideType.toUpperCase(),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Minha Distância até a Origem',
                    '${distance.toStringAsFixed(2)} km',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botões de ação
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAccepting ? null : _acceptRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isAccepting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Aceitar Corrida',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAccepting ? null : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getRideTypeColor(String rideType) {
    switch (rideType.toLowerCase()) {
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
