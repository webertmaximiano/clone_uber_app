import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivers_app/services/driver_auth_service.dart';
import 'package:drivers_app/screens/rides/available_rides_screen.dart';
import 'package:drivers_app/screens/rides/active_ride_screen.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final DriverAuthService _authService = DriverAuthService();
  bool _isOnline = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  Future<void> _toggleOnlineStatus() async {
    try {
      await _authService.updateOnlineStatus(!_isOnline);
      setState(() => _isOnline = !_isOnline);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isOnline
                ? 'Você está online e pronto para receber corridas'
                : 'Você está offline',
          ),
          backgroundColor: _isOnline ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da aplicação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sair: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Motorista'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Driver Info Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.deepPurple.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser?.email ?? 'Motorista',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '5.0',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Online Status Toggle
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Switch(
                        value: _isOnline,
                        onChanged: (value) {
                          _toggleOnlineStatus();
                        },
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    'Corridas Hoje',
                    '0',
                    Icons.directions_car,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Ganho Hoje',
                    'R\$ 0,00',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Total de Corridas',
                    '0',
                    Icons.receipt,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Total Ganho',
                    'R\$ 0,00',
                    Icons.account_balance_wallet,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botões de navegação
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AvailableRidesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Ver Corridas Disponíveis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActiveRideScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Minha Corrida Ativa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Corridas Ativas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              // Placeholder for active rides
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma corrida ativa',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Fique online para receber corridas',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upcoming Rides
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Próximas Corridas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma corrida agendada',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
