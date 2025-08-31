# Fluxo de Login (LoginScreen)

Este documento detalha a implementação da tela de login, incluindo validação de formulário e a chamada aos métodos de autenticação.

## Visão Geral da Tela

A `LoginScreen` é uma `StatefulWidget` que gerencia o estado dos campos de e-mail e senha. Após a refatoração, sua principal responsabilidade é coletar os dados do usuário e chamar o `AuthService` para executar a lógica de autenticação, mantendo a UI desacoplada das regras de negócio.

## Componentes Principais

-   **`TextEditingController`**: Para capturar o texto dos campos de e-mail e senha.
-   **`GlobalKey<FormState>`**: Para validar o formulário.
-   **`_isLoading`**: Controla o indicador de carregamento.
-   **`AuthService`**: Uma instância do nosso serviço de autenticação, que contém toda a lógica de comunicação com o Firebase.

## Lógica de Autenticação com E-mail e Senha (`_submitForm`)

Este método permanece na tela de login, pois é uma lógica de UI relativamente simples. Ele valida o formulário e chama diretamente o `FirebaseAuth.instance.signInWithEmailAndPassword`.

```dart
// Lógica de login com e-mail/senha na LoginScreen
Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    }

  } on FirebaseAuthException catch (e) {
    // ... tratamento de erro ...
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

## Lógica de Autenticação com Google (`_signInWithGoogle`)

Este método foi drasticamente simplificado. Ele agora apenas gerencia o estado de `_isLoading` e chama o método correspondente no `AuthService`. Toda a complexidade de lidar com a autenticação do Google, seja para web ou mobile, está encapsulada no serviço.

```dart
// Nova lógica de login com Google na LoginScreen

// Instância do nosso serviço
final AuthService _authService = AuthService();

Future<void> _signInWithGoogle() async {
  setState(() {
    _isLoading = true;
  });

  // Chama o método do serviço
  final User? user = await _authService.signInWithGoogle();

  if (mounted) {
    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      // Navega para a HomeScreen em caso de sucesso
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      // Opcional: Mostrar uma mensagem se o login for cancelado.
      _showSnackBar("Login com Google cancelado ou falhou.");
    }
  }
}
```

## Navegação

-   **Para a Tela de Cadastro:** Um `TextButton` permite que o usuário navegue para a `SignupScreen`.
-   **Após o Login:** Após um login bem-sucedido (seja por e-mail ou Google), o usuário é redirecionado para a `HomeScreen` e a pilha de navegação é limpa para impedir que ele volte para a tela de login.