import 'package:flutter/material.dart';
import 'package:drivers_app/services/driver_auth_service.dart';

class DriverSignupScreen extends StatefulWidget {
  const DriverSignupScreen({Key? key}) : super(key: key);

  @override
  State<DriverSignupScreen> createState() => _DriverSignupScreenState();
}

class _DriverSignupScreenState extends State<DriverSignupScreen> {
  final DriverAuthService _authService = DriverAuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final List<String> _vehicleTypes = [
    'Selecione um tipo de veículo',
    'Carro Popular',
    'Carro Confortável',
    'SUV',
    'Executivo',
  ];
  late String _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _selectedVehicleType = _vehicleTypes[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleType == _vehicleTypes[0]) {
      _showSnackBar('Selecione um tipo de veículo', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        vehicleType: _selectedVehicleType,
        licensePlate: _licensePlateController.text.trim().toUpperCase(),
      );

      if (mounted) {
        _showSnackBar('Cadastro realizado com sucesso!');
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      _showSnackBar(
        'Erro ao cadastrar: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro - Motorista'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple.shade100,
                  ),
                  child: Icon(
                    Icons.directions_car,
                    size: 40,
                    color: Colors.deepPurple.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    hintText: 'João da Silva',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'seu@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email é obrigatório';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(11) 98765-4321',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telefone é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: '••••••••',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Senha é obrigatória';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Vehicle Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedVehicleType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Veículo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.car_rental),
                  ),
                  items: _vehicleTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedVehicleType = newValue ?? _vehicleTypes[0];
                    });
                  },
                ),
                const SizedBox(height: 16),

                // License Plate Field
                TextFormField(
                  controller: _licensePlateController,
                  decoration: InputDecoration(
                    labelText: 'Placa do Veículo',
                    hintText: 'ABC1D23',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.confirmation_number),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Placa é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Cadastrar',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem conta? ',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Faça login',
                        style: TextStyle(
                          color: Colors.deepPurple.shade600,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
