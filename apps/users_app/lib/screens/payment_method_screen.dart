import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:users_app/models/payment_method.dart';
import 'package:users_app/services/payment_service.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final PaymentService _paymentService = PaymentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedPaymentType = 'card';
  double _walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final balance = await _paymentService.getWalletBalance(userId);
      setState(() => _walletBalance = balance);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pagamento'),
        backgroundColor: Colors.deepPurple,
      ),
      body: userId == null
          ? const Center(child: Text('Usuário não autenticado'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saldo da Carteira
                    Card(
                      elevation: 4,
                      color: Colors.deepPurple,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saldo da Carteira',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'R\$ ${_walletBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _showAddBalanceDialog(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Adicionar Saldo',
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Método de Pagamento
                    const Text(
                      'Método de Pagamento',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Opções de pagamento
                    _buildPaymentOption(
                      'card',
                      'Cartão de Crédito/Débito',
                      Icons.credit_card,
                      'XXXX XXXX XXXX 1234',
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      'wallet',
                      'Carteira Digital',
                      Icons.account_balance_wallet,
                      'R\$ ${_walletBalance.toStringAsFixed(2)} disponível',
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      'cash',
                      'Dinheiro',
                      Icons.money,
                      'Pagamento em dinheiro na chegada',
                    ),
                    const SizedBox(height: 32),

                    // Métodos salvos
                    const Text(
                      'Métodos Salvos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    FutureBuilder<List<PaymentMethod>>(
                      future: _paymentService.getUserPaymentMethods(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Erro: ${snapshot.error}'));
                        }

                        final methods = snapshot.data ?? [];

                        if (methods.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Nenhum método de pagamento salvo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: methods.map((method) {
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                leading: Icon(
                                  method.type == 'card'
                                      ? Icons.credit_card
                                      : method.type == 'wallet'
                                          ? Icons.account_balance_wallet
                                          : Icons.money,
                                  color: Colors.deepPurple,
                                ),
                                title: Text(method.cardholderName ?? method.type),
                                subtitle: Text(method.cardNumber ?? 'Método de pagamento'),
                                trailing: method.isDefault
                                    ? const Chip(
                                        label: Text('Padrão'),
                                        backgroundColor: Colors.green,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botão de confirmar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, _selectedPaymentType),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text(
                          'Confirmar Método de Pagamento',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPaymentOption(
    String type,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedPaymentType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentType = type),
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.deepPurple, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBalanceDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Saldo'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Valor (R\$)',
            hintText: '0,00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text.replaceAll(',', '.'));
              if (amount != null && amount > 0) {
                final userId = _auth.currentUser?.uid;
                if (userId != null) {
                  await _paymentService.addWalletBalance(userId, amount);
                  await _loadWalletBalance();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saldo adicionado com sucesso!')),
                    );
                  }
                }
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
