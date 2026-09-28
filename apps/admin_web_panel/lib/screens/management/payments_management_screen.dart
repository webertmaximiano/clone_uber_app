import 'package:flutter/material.dart';
import 'package:admin_web_panel/models/payment.dart';
import 'package:admin_web_panel/services/payment_service.dart';
import 'package:intl/intl.dart';

class PaymentsManagementScreen extends StatefulWidget {
  const PaymentsManagementScreen({super.key});

  @override
  State<PaymentsManagementScreen> createState() =>
      _PaymentsManagementScreenState();
}

class _PaymentsManagementScreenState extends State<PaymentsManagementScreen> {
  final PaymentService _paymentService = PaymentService();
  late Future<double> _totalRevenue;
  String _selectedStatus = 'all';
  int _currentPage = 1;
  final int _itemsPerPage = 15;

  final List<String> _statusOptions = [
    'all',
    'pending',
    'completed',
    'failed',
    'refunded',
  ];

  @override
  void initState() {
    super.initState();
    _totalRevenue = _paymentService.getTotalRevenue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Pagamentos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Card
            FutureBuilder<double>(
              future: _totalRevenue,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Receita Total (Completados)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                          Text(
                            'R\$ ${snapshot.data!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 24),

            // Payments Table
            const Text(
              'Histórico de Pagamentos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Status Filter
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
                      child: Text(status == 'all' ? 'Todos' : status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'all';
                      _currentPage = 1;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Payment>>(
                stream: _paymentService.getPaymentsStream(),
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
                      child: Text('Erro ao carregar pagamentos: ${snapshot.error}'),
                    );
                  }

                  final payments = snapshot.data ?? [];

                  // Filter by status
                  final filteredPayments = _selectedStatus == 'all'
                      ? payments
                      : payments
                          .where((payment) => payment.status == _selectedStatus)
                          .toList();

                  // Pagination
                  final totalPages = (filteredPayments.length / _itemsPerPage).ceil();
                  final startIndex = (_currentPage - 1) * _itemsPerPage;
                  final endIndex =
                      (startIndex + _itemsPerPage).clamp(0, filteredPayments.length);
                  final paginatedPayments =
                      filteredPayments.sublist(startIndex, endIndex);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Corrida ID')),
                        DataColumn(label: Text('Usuário ID')),
                        DataColumn(label: Text('Motorista ID')),
                        DataColumn(label: Text('Valor')),
                        DataColumn(label: Text('Método')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Criado em')),
                        DataColumn(label: Text('Ações')),
                      ],
                      rows: paginatedPayments.map((payment) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  payment.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  payment.rideId,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Text(
                                  payment.userId,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Text(
                                  payment.driverId,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Text('R\$ ${payment.amount.toStringAsFixed(2)}'),
                            ),
                            DataCell(
                              Text(_getPaymentMethodLabel(payment.paymentMethod)),
                            ),
                            DataCell(
                              Chip(
                                label: Text(_getStatusLabel(payment.status)),
                                backgroundColor: _getStatusColor(payment.status),
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat('dd/MM HH:mm').format(payment.createdAt),
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
                                      _showPaymentDetails(payment);
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
                  Text('Página $_currentPage'),
                  ElevatedButton(
                    onPressed: _currentPage < 5
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

  void _showPaymentDetails(Payment payment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detalhes do Pagamento'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', payment.id),
                _buildDetailRow('Corrida ID', payment.rideId),
                _buildDetailRow('Usuário ID', payment.userId),
                _buildDetailRow('Motorista ID', payment.driverId),
                _buildDetailRow('Valor', 'R\$ ${payment.amount.toStringAsFixed(2)}'),
                _buildDetailRow(
                  'Método',
                  _getPaymentMethodLabel(payment.paymentMethod),
                ),
                _buildDetailRow('Status', _getStatusLabel(payment.status)),
                _buildDetailRow(
                  'Criado em',
                  DateFormat('dd/MM/yyyy HH:mm').format(payment.createdAt),
                ),
                if (payment.processedAt != null)
                  _buildDetailRow(
                    'Processado em',
                    DateFormat('dd/MM/yyyy HH:mm').format(payment.processedAt!),
                  ),
                if (payment.failureReason != null)
                  _buildDetailRow('Motivo da Falha', payment.failureReason!),
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
        return 'Pendente';
      case 'completed':
        return 'Concluído';
      case 'failed':
        return 'Falha';
      case 'refunded':
        return 'Reembolsado';
      default:
        return status;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'card':
        return 'Cartão';
      case 'wallet':
        return 'Carteira';
      case 'cash':
        return 'Dinheiro';
      default:
        return method;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.withOpacity(0.2);
      case 'completed':
        return Colors.green.withOpacity(0.2);
      case 'failed':
        return Colors.red.withOpacity(0.2);
      case 'refunded':
        return Colors.blue.withOpacity(0.2);
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
