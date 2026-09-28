import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_app/models/ride_request.dart';
import 'package:users_app/services/ride_service.dart';
import 'package:intl/intl.dart';

class RideTrackingScreen extends StatefulWidget {
  final RideRequest rideRequest;

  const RideTrackingScreen({
    Key? key,
    required this.rideRequest,
  }) : super(key: key);

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  final RideService _rideService = RideService();
  GoogleMapController? _controller;
  late RideRequest _currentRide;

  @override
  void initState() {
    super.initState();
    _currentRide = widget.rideRequest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreamento da Corrida'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          // Mapa
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentRide.originLatitude, _currentRide.originLongitude),
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: {
              Marker(
                markerId: const MarkerId('origin'),
                position: LatLng(_currentRide.originLatitude, _currentRide.originLongitude),
                infoWindow: const InfoWindow(title: 'Origem'),
              ),
              Marker(
                markerId: const MarkerId('destination'),
                position: LatLng(_currentRide.destinationLatitude, _currentRide.destinationLongitude),
                infoWindow: const InfoWindow(title: 'Destino'),
              ),
            },
          ),

          // Painel de informações
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StreamBuilder<RideRequest?>(
              stream: _rideService.getUserActiveRideStream(widget.rideRequest.userId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  _currentRide = snapshot.data!;
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_currentRide.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusLabel(_currentRide.status),
                            style: TextStyle(
                              color: _getStatusColor(_currentRide.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Informações da corrida
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoWidget(
                              Icons.straighten,
                              '${_currentRide.estimatedDistance.toStringAsFixed(1)} km',
                              'Distância',
                            ),
                            _buildInfoWidget(
                              Icons.attach_money,
                              'R\$ ${_currentRide.estimatedFare.toStringAsFixed(2)}',
                              'Fare',
                            ),
                            _buildInfoWidget(
                              Icons.schedule,
                              '${_currentRide.estimatedDurationMinutes} min',
                              'Tempo est.',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Rotas
                        _buildRouteWidget(
                          Icons.location_on,
                          Colors.green,
                          _currentRide.originAddress,
                          'Origem',
                        ),
                        const SizedBox(height: 12),
                        _buildRouteWidget(
                          Icons.location_on,
                          Colors.red,
                          _currentRide.destinationAddress,
                          'Destino',
                        ),
                        const SizedBox(height: 24),

                        // Botões de ação
                        if (_currentRide.status == 'pending' || _currentRide.status == 'assigned')
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _showCancelDialog(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                'Cancelar Corrida',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        else if (_currentRide.status == 'completed')
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, _currentRide),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                'Avaliar Corrida',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoWidget(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRouteWidget(IconData icon, Color color, String address, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Corrida'),
        content: const Text('Tem certeza que deseja cancelar esta corrida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () async {
              await _rideService.cancelRideRequest(_currentRide.id);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Sim', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Aguardando motorista...';
      case 'assigned':
        return 'Motorista a caminho';
      case 'in_progress':
        return 'Corrida em progresso';
      case 'completed':
        return 'Corrida concluída';
      case 'cancelled':
        return 'Corrida cancelada';
      default:
        return 'Desconhecido';
    }
  }
}
