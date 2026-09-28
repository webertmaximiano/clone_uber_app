import 'package:flutter/material.dart';
import 'package:admin_web_panel/models/ride.dart';
import 'package:admin_web_panel/services/ride_service.dart';
import 'package:intl/intl.dart';

class RidesMonitoringScreen extends StatefulWidget {
  const RidesMonitoringScreen({super.key});

  @override
  State<RidesMonitoringScreen> createState() => _RidesMonitoringScreenState();
}

class _RidesMonitoringScreenState extends State<RidesMonitoringScreen> {
  final RideService _rideService = RideService();
  String _selectedStatus = 'all'; // all, pending, in_progress, completed, cancelled
  int _currentPage = 1;
  final int _itemsPerPage = 15;
  List<Ride> _cachedFilteredRides = [];

  final List<String> _statusOptions = [
    'all',
    'pending',
    'in_progress',
    'completed',
    'cancelled'
  ];

  /// Getter para as corridas filtradas (usado na paginação)
  List<Ride> get filteredRides => _cachedFilteredRides;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoramento de Corridas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter by Status
            Row(
              children: [
                const Text(
                  'Filtrar por Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusLabel(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rides Table
            Expanded(
              child: StreamBuilder<List<Ride>>(
                stream: _selectedStatus == 'all'
                    ? _rideService.getRidesStream()
                    : _rideService.getActiveRidesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar corridas: ${snapshot.error}'),
                    );
                  }

                  final allRides = snapshot.data ?? [];
                  _cachedFilteredRides = _selectedStatus == 'all'
                      ? allRides
                      : allRides
                          .where((ride) => ride.status == _selectedStatus)
                          .toList();

                  // Pagination
                  final totalPages = (_cachedFilteredRides.length / _itemsPerPage).ceil();
                  final startIndex = (_currentPage - 1) * _itemsPerPage;
                  final endIndex = (startIndex + _itemsPerPage).clamp(0, _cachedFilteredRides.length);
                  final paginatedRides = _cachedFilteredRides.sublist(startIndex, endIndex);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Origem')),
                        DataColumn(label: Text('Destino')),
                        DataColumn(label: Text('Valor')),
                        DataColumn(label: Text('Distância')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Tempo Est.')),
                        DataColumn(label: Text('Criado em')),
                        DataColumn(label: Text('Ações')),
                      ],
                      rows: paginatedRides.map((ride) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  ride.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  ride.originAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  ride.destinationAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Text('R\$ ${ride.fare.toStringAsFixed(2)}'),
                            ),
                            DataCell(
                              Text('${ride.distance.toStringAsFixed(1)} km'),
                            ),
                            DataCell(
                              Chip(
                                label: Text(_getStatusLabel(ride.status)),
                                backgroundColor: _getStatusColor(ride.status),
                              ),
                            ),
                            DataCell(
                              Text('${ride.estimatedDuration} min'),
                            ),
                            DataCell(
                              Text(
                                DateFormat('dd/MM HH:mm').format(ride.createdAt),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility,
                                        color: Colors.blue),
                                    tooltip: 'Ver detalhes',
                                    onPressed: () {
                                      _showRideDetails(ride);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.map,
                                        color: Colors.green),
                                    tooltip: 'Ver no mapa',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Funcionalidade em desenvolvimento'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Pagination Controls
            Center(
              child: Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    child: const Text('Anterior'),
                  ),
                  Text('Página $_currentPage de ${((filteredRides.length / _itemsPerPage).ceil())}'),
                  ElevatedButton(
                    onPressed: _currentPage <
                            (filteredRides.length / _itemsPerPage).ceil()
                        ? () => setState(() => _currentPage++)
                        : null,
                    child: const Text('Próxima'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRideDetails(Ride ride) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalhes da Corrida'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', ride.id),
                _buildDetailRow('Usuário ID', ride.userId),
                _buildDetailRow('Motorista ID', ride.driverId ?? 'N/A'),
                _buildDetailRow('Origem', ride.originAddress),
                _buildDetailRow('Destino', ride.destinationAddress),
                _buildDetailRow('Valor', 'R\$ ${ride.fare.toStringAsFixed(2)}'),
                _buildDetailRow('Distância', '${ride.distance.toStringAsFixed(1)} km'),
                _buildDetailRow('Tempo Estimado', '${ride.estimatedDuration} min'),
                if (ride.actualDuration > 0)
                  _buildDetailRow('Tempo Real', '${ride.actualDuration} min'),
                _buildDetailRow('Status', _getStatusLabel(ride.status)),
                _buildDetailRow(
                  'Criado em',
                  DateFormat('dd/MM/yyyy HH:mm').format(ride.createdAt),
                ),
                if (ride.completedAt != null)
                  _buildDetailRow(
                    'Concluído em',
                    DateFormat('dd/MM/yyyy HH:mm').format(ride.completedAt!),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Aguardando';
      case 'in_progress':
        return 'Em Andamento';
      case 'completed':
        return 'Concluída';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Todas';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.withOpacity(0.2);
      case 'in_progress':
        return Colors.blue.withOpacity(0.2);
      case 'completed':
        return Colors.green.withOpacity(0.2);
      case 'cancelled':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
