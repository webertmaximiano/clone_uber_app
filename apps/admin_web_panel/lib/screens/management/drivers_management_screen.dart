import 'package:flutter/material.dart';
import 'package:admin_web_panel/models/driver.dart';
import 'package:admin_web_panel/services/driver_service.dart';
import 'package:intl/intl.dart';

class DriversManagementScreen extends StatefulWidget {
  const DriversManagementScreen({super.key});

  @override
  State<DriversManagementScreen> createState() => _DriversManagementScreenState();
}

class _DriversManagementScreenState extends State<DriversManagementScreen> {
  final DriverService _driverService = DriverService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 15;
  List<Driver> _cachedFilteredDrivers = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Getter para os motoristas filtrados (usado na paginação)
  List<Driver> get filteredDrivers => _cachedFilteredDrivers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Motoristas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar motoristas por email ou nome...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 24),

            // Drivers Table
            Expanded(
              child: StreamBuilder<List<Driver>>(
                stream: _driverService.getDriversStream(),
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
                      child: Text('Erro ao carregar motoristas: ${snapshot.error}'),
                    );
                  }

                  final allDrivers = snapshot.data ?? [];
                  _cachedFilteredDrivers = allDrivers
                      .where((driver) =>
                          driver.email.toLowerCase().contains(_searchQuery) ||
                          driver.name.toLowerCase().contains(_searchQuery))
                      .toList();

                  // Pagination
                  final totalPages = (_cachedFilteredDrivers.length / _itemsPerPage).ceil();
                  final startIndex = (_currentPage - 1) * _itemsPerPage;
                  final endIndex = (startIndex + _itemsPerPage).clamp(0, _cachedFilteredDrivers.length);
                  final paginatedDrivers = _cachedFilteredDrivers.sublist(startIndex, endIndex);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nome')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Placa')),
                        DataColumn(label: Text('Avaliação')),
                        DataColumn(label: Text('Corridas')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Online')),
                        DataColumn(label: Text('Criado em')),
                        DataColumn(label: Text('Ações')),
                      ],
                      rows: paginatedDrivers.map((driver) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  driver.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(Text(driver.name)),
                            DataCell(Text(driver.email)),
                            DataCell(Text(driver.licensePlate)),
                            DataCell(
                              Chip(
                                label: Text('${driver.rating.toStringAsFixed(1)} ⭐'),
                                backgroundColor: Colors.amber.withOpacity(0.2),
                              ),
                            ),
                            DataCell(Text(driver.totalRides.toString())),
                            DataCell(
                              Chip(
                                label: driver.isActive ? const Text('Ativo') : const Text('Inativo'),
                                backgroundColor: driver.isActive
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                              ),
                            ),
                            DataCell(
                              Chip(
                                label: driver.isOnline ? const Text('Online') : const Text('Offline'),
                                backgroundColor: driver.isOnline
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat('dd/MM/yyyy').format(driver.createdAt),
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
                                      _showDriverDetails(driver);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    tooltip: 'Deletar',
                                    onPressed: () {
                                      _showDeleteConfirmation(driver);
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
                  Text('Página $_currentPage de ${((filteredDrivers.length / _itemsPerPage).ceil())}'),
                  ElevatedButton(
                    onPressed: _currentPage <
                            (filteredDrivers.length / _itemsPerPage).ceil()
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

  void _showDriverDetails(Driver driver) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalhes do Motorista'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', driver.id),
                _buildDetailRow('Nome', driver.name),
                _buildDetailRow('Email', driver.email),
                _buildDetailRow('Telefone', driver.phoneNumber),
                _buildDetailRow('Tipo de Veículo', driver.vehicleType),
                _buildDetailRow('Placa do Veículo', driver.licensePlate),
                _buildDetailRow('Avaliação', '${driver.rating.toStringAsFixed(1)} ⭐'),
                _buildDetailRow('Total de Corridas', driver.totalRides.toString()),
                _buildDetailRow('Ganhos Totais', 'R\$ ${driver.totalEarnings.toString()}'),
                _buildDetailRow('Status', driver.isActive ? 'Ativo' : 'Inativo'),
                _buildDetailRow('Online', driver.isOnline ? 'Sim' : 'Não'),
                _buildDetailRow(
                  'Criado em',
                  DateFormat('dd/MM/yyyy HH:mm').format(driver.createdAt),
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

  void _showDeleteConfirmation(Driver driver) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja deletar o motorista ${driver.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _driverService.deleteDriver(driver.id);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Motorista deletado com sucesso')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao deletar: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );
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
