import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:users_app/screens/home_screen.dart'; // Importação para a tela principal

/// Tela de Cadastro
///
/// Assim como a tela de Login, esta é uma `StatefulWidget` para que possamos
/// gerenciar os dados de entrada do usuário nos campos do formulário.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controladores para cada campo de texto do formulário.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Chave global para identificar e gerenciar o estado do nosso formulário.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variável de estado para controlar a exibição do indicador de carregamento.
  bool _isLoading = false;

  /// Método para submeter o formulário de cadastro.
  ///
  /// A palavra-chave `async` indica que este método pode executar operações
  /// demoradas (assíncronas), como uma chamada de rede para o Firebase.
  Future<void> _submitForm() async {
    // Aciona a validação do formulário.
    if (!_formKey.currentState!.validate()) {
      return; // Se inválido, interrompe a execução.
    }

    // Ativa o indicador de carregamento e redesenha a tela.
    setState(() {
      _isLoading = true;
    });

    try {
      // A palavra-chave `await` pausa a execução do método até que a Future
      // (operação assíncrona) seja concluída. Neste caso, esperamos o Firebase
      // criar o usuário.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Se o código chegar aqui, o usuário foi criado com sucesso.
      // A lógica para salvar o nome do usuário no Firestore virá aqui depois.

      // Exibe uma mensagem de sucesso.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      // Navega para a tela principal do app e remove todas as rotas anteriores.
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      // O bloco `on` captura exceções de um tipo específico. Aqui, pegamos
      // erros específicos do Firebase Authentication.
      String message;
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'O e-mail fornecido já está em uso.';
      } else {
        message = 'Ocorreu um erro. Tente novamente.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // O bloco `catch` genérico captura qualquer outro tipo de erro.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorreu um erro inesperado.'), backgroundColor: Colors.red),
      );
    }

    // Desativa o indicador de carregamento, independentemente do resultado.
    // O `if (mounted)` verifica se o widget ainda está na tela antes de chamar
    // o setState, para evitar erros.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira seu nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Se _isLoading for true, mostra o CircularProgressIndicator.
                // Caso contrário, mostra o botão.
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Cadastrar', style: TextStyle(fontSize: 18)),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Já tem uma conta? Faça Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
