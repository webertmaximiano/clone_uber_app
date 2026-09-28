import 'package:flutter/material.dart';
import 'package:admin_web_panel/models/user.dart';
import 'package:admin_web_panel/services/user_service.dart';
import 'package:admin_web_panel/widgets/advanced_filter_widget.dart';
import 'package:intl/intl.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All';
  int _currentPage = 1;
  final int _itemsPerPage = 15;
  List<User> _cachedFilteredUsers = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _searchQuery = (filters['search'] as String? ?? '').toLowerCase();
      _filterStatus = filters['status'] as String? ?? 'All';
      _currentPage = 1;
    });
  }

  /// Getter para os usuários filtrados (usado na paginação)
  List<User> get filteredUsers => _cachedFilteredUsers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Usuários'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Advanced Filter Widget
            AdvancedFilterWidget(
              filterOptions: const ['status'],
              onFilterChanged: _applyFilters,
            ),
            const SizedBox(height: 24),

            // Users Table
            Expanded(
              child: StreamBuilder<List<User>>(
                stream: _userService.getUsersStream(),
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
                      child: Text('Erro ao carregar usuários: ${snapshot.error}'),
                    );
                  }

                  final allUsers = snapshot.data ?? [];
                  _cachedFilteredUsers = allUsers
                      .where((user) {
                        bool matchSearch = _searchQuery.isEmpty ||
                            user.email.toLowerCase().contains(_searchQuery) ||
                            user.name.toLowerCase().contains(_searchQuery);

                        bool matchStatus = _filterStatus == 'All' ||
                            (_filterStatus == 'Active' && user.isActive) ||
                            (_filterStatus == 'Inactive' && !user.isActive);

                        return matchSearch && matchStatus;
                      })
                      .toList();

                  // Pagination
                  final totalPages = (_cachedFilteredUsers.length / _itemsPerPage).ceil();
                  final startIndex = (_currentPage - 1) * _itemsPerPage;
                  final endIndex = (startIndex + _itemsPerPage).clamp(0, _cachedFilteredUsers.length);
                  final paginatedUsers = _cachedFilteredUsers.sublist(startIndex, endIndex);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nome')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Telefone')),
                        DataColumn(label: Text('Avaliação')),
                        DataColumn(label: Text('Corridas')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Criado em')),
                        DataColumn(label: Text('Ações')),
                      ],
                      rows: paginatedUsers.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  user.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(Text(user.name)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.phoneNumber)),
                            DataCell(
                              Chip(
                                label: Text('${user.rating.toStringAsFixed(1)} ⭐'),
                                backgroundColor: Colors.amber.withOpacity(0.2),
                              ),
                            ),
                            DataCell(Text(user.totalRides.toString())),
                            DataCell(
                              Chip(
                                label: user.isActive ? const Text('Ativo') : const Text('Inativo'),
                                backgroundColor: user.isActive
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat('dd/MM/yyyy').format(user.createdAt),
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
                                      _showUserDetails(user);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    tooltip: 'Deletar',
                                    onPressed: () {
                                      _showDeleteConfirmation(user);
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
                  Text('Página $_currentPage de ${((filteredUsers.length / _itemsPerPage).ceil())}'),
                  ElevatedButton(
                    onPressed: _currentPage <
                            (filteredUsers.length / _itemsPerPage).ceil()
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

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalhes do Usuário'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', user.id),
                _buildDetailRow('Nome', user.name),
                _buildDetailRow('Email', user.email),
                _buildDetailRow('Telefone', user.phoneNumber),
                _buildDetailRow('Avaliação', '${user.rating.toStringAsFixed(1)} ⭐'),
                _buildDetailRow('Total de Corridas', user.totalRides.toString()),
                _buildDetailRow('Status', user.isActive ? 'Ativo' : 'Inativo'),
                _buildDetailRow(
                  'Criado em',
                  DateFormat('dd/MM/yyyy HH:mm').format(user.createdAt),
                ),
                if (user.lastActive != null)
                  _buildDetailRow(
                    'Último Acesso',
                    DateFormat('dd/MM/yyyy HH:mm').format(user.lastActive!),
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

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja deletar o usuário ${user.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _userService.deleteUser(user.id);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuário deletado com sucesso')),
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
