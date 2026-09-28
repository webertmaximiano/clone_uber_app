import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:admin_web_panel/services/admin_auth_service.dart';
import 'package:admin_web_panel/screens/authentication/login_screen.dart';
import 'package:admin_web_panel/screens/management/users_management_screen.dart';
import 'package:admin_web_panel/screens/management/drivers_management_screen.dart';
import 'package:admin_web_panel/screens/management/rides_monitoring_screen.dart';
import 'package:admin_web_panel/screens/management/payments_management_screen.dart';
import 'package:admin_web_panel/services/user_service.dart';
import 'package:admin_web_panel/services/driver_service.dart';
import 'package:admin_web_panel/services/ride_service.dart';
import 'package:admin_web_panel/services/payment_service.dart';
import 'package:admin_web_panel/widgets/status_pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AdminAuthService _authService = AdminAuthService();
  final UserService _userService = UserService();
  final DriverService _driverService = DriverService();
  final RideService _rideService = RideService();
  final PaymentService _paymentService = PaymentService();

  late User? _currentUser;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const UsersManagementScreen();
      case 2:
        return const DriversManagementScreen();
      case 3:
        return const RidesMonitoringScreen();
      case 4:
        return const PaymentsManagementScreen();
      case 5:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                _currentUser?.email ?? 'Admin',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _navigateTo,
            labelType: NavigationRailLabelType.selected,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people),
                label: Text('Usuários'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.directions_car),
                selectedIcon: Icon(Icons.directions_car),
                label: Text('Motoristas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt),
                selectedIcon: Icon(Icons.receipt),
                label: Text('Corridas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.attach_money),
                selectedIcon: Icon(Icons.attach_money),
                label: Text('Pagamentos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings),
                label: Text('Configurações'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: _getCurrentScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-vindo ao Admin Panel',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Olá, ${_currentUser?.email ?? "Admin"}! 👋',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            // Dashboard Cards
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCardWithStream(
                  title: 'Total de Usuários',
                  icon: Icons.people,
                  color: Colors.blue,
                  futureBuilder: _userService.getUserCount(),
                ),
                _buildDashboardCardWithStream(
                  title: 'Total de Motoristas',
                  icon: Icons.directions_car,
                  color: Colors.green,
                  futureBuilder: _driverService.getDriverCount(),
                ),
                _buildDashboardCardWithStream(
                  title: 'Corridas Ativas',
                  icon: Icons.receipt,
                  color: Colors.orange,
                  futureBuilder: _rideService.getActiveRideCount(),
                ),
                _buildDashboardCardWithStream(
                  title: 'Receita Total',
                  icon: Icons.attach_money,
                  color: Colors.red,
                  futureBuilder: _paymentService.getTotalRevenue(),
                  isRevenue: true,
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Gráficos
            const Text(
              'Análises e Estatísticas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Pie Charts com dados reais
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<Map<String, int>>(
                    future: _rideService.getRideCountByStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data!;
                        return StatusPieChart(
                          title: 'Distribuição de Corridas por Status',
                          dataMap: {
                            'Aguardando': data['pending'] ?? 0,
                            'Em Andamento': data['in_progress'] ?? 0,
                            'Concluída': data['completed'] ?? 0,
                            'Cancelada': data['cancelled'] ?? 0,
                          },
                          colorMap: {
                            'Aguardando': Colors.orange,
                            'Em Andamento': Colors.blue,
                            'Concluída': Colors.green,
                            'Cancelada': Colors.red,
                          },
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.deepPurple.shade600),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: FutureBuilder<Map<String, int>>(
                    future: _userService.getUserCountByStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data!;
                        return StatusPieChart(
                          title: 'Distribuição de Usuários',
                          dataMap: {
                            'Ativos': data['active'] ?? 0,
                            'Inativos': data['inactive'] ?? 0,
                          },
                          colorMap: {
                            'Ativos': Colors.green,
                            'Inativos': Colors.grey,
                          },
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.deepPurple.shade600),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Gráfico de Receita com dados reais
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Receita dos Últimos 7 Dias',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<double>>(
                      future: _rideService.get7DayRevenue(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final revenueData = snapshot.data!;
                          final maxY = (revenueData.isNotEmpty
                              ? (revenueData.reduce((a, b) => a > b ? a : b) * 1.2)
                              : 5000.0) as double;

                          return SizedBox(
                            height: 300,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Faturamento dos últimos 7 dias',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'R\$ ${revenueData.fold<double>(0, (a, b) => a + b).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.deepPurple.shade600),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCardWithStream({
    required String title,
    required IconData icon,
    required Color color,
    required Future<dynamic> futureBuilder,
    bool isRevenue = false,
  }) {
    return FutureBuilder<dynamic>(
      future: futureBuilder,
      builder: (context, snapshot) {
        String displayValue = '...';
        if (snapshot.hasData) {
          if (isRevenue) {
            displayValue = 'R\$ ${(snapshot.data as double).toStringAsFixed(2)}';
          } else {
            displayValue = snapshot.data.toString();
          }
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 36),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayValue,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sobre o Sistema',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Clone Uber - Admin Panel v1.0.0'),
                  const SizedBox(height: 8),
                  const Text('Desenvolvido com Flutter e Firebase'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text(
                      'Fazer Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
