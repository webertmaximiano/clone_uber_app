# Fluxo de Login (LoginScreen)

Este documento detalha a implementação da tela de login, incluindo validação de formulário e autenticação com e-mail/senha e Google Sign-In.

## Visão Geral da Tela

A `LoginScreen` é uma `StatefulWidget` que gerencia o estado dos campos de e-mail e senha, além de interagir com o Firebase Authentication.

## Componentes Principais

-   **`TextEditingController`**: Usados para capturar o texto digitado nos campos de e-mail e senha.
-   **`GlobalKey<FormState>`**: Essencial para validar o formulário.
-   **`_isLoading`**: Variável booleana para controlar o indicador de carregamento e desabilitar botões durante a autenticação.

## Lógica de Autenticação com E-mail e Senha (`_submitForm`)

Este método é acionado quando o usuário clica no botão "Entrar".

```dart
Future<void> _submitForm() async {
  // 1. Validação do Formulário:
  //    Verifica se todos os campos do formulário são válidos de acordo com os 'validator' definidos.
  if (!_formKey.currentState!.validate()) {
    return; // Se houver erros de validação, a execução é interrompida.
  }

  // 2. Ativar Indicador de Carregamento:
  //    Atualiza o estado para mostrar um CircularProgressIndicator e desabilitar o botão.
  setState(() {
    _isLoading = true;
  });

  try {
    // 3. Autenticação com Firebase:
    //    Chama o método signInWithEmailAndPassword do Firebase Authentication.
    //    'await' pausa a execução até que a operação assíncrona seja concluída.
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // 4. Feedback de Sucesso:
    //    Exibe uma mensagem de sucesso na parte inferior da tela.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login realizado com sucesso!')),
    );

    // TODO: Navegar para a tela principal do app após o login.
    // Esta navegação será implementada em um passo futuro.

  } on FirebaseAuthException catch (e) {
    // 5. Tratamento de Erros Específicos do Firebase:
    //    Captura exceções lançadas pelo Firebase Authentication e exibe mensagens amigáveis.
    String message;
    if (e.code == 'user-not-found') {
      message = 'Nenhum usuário encontrado para este e-mail.';
    } else if (e.code == 'wrong-password') {
      message = 'Senha incorreta.';
    } else {
      message = 'Ocorreu um erro de autenticação.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  } catch (e) {
    // 6. Tratamento de Erros Genéricos:
    //    Captura qualquer outro erro inesperado.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ocorreu um erro inesperado.'), backgroundColor: Colors.red),
    );
  }

  // 7. Desativar Indicador de Carregamento:
  //    Garante que o indicador de carregamento seja desativado, independentemente do resultado.
  if (mounted) { // Verifica se o widget ainda está na árvore antes de chamar setState.
    setState(() {
      _isLoading = false;
    });
  }
}

## Lógica de Autenticação com Google (`_signInWithGoogle`)

Este método é acionado quando o usuário clica no botão "Entrar com Google".

```dart
Future<void> _signInWithGoogle() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // 1. Inicia o fluxo de login do Google:
    //    Abre a janela de seleção de conta Google.
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // O usuário cancelou o login.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // 2. Obtém os detalhes de autenticação do Google:
    //    Pega o accessToken e o idToken necessários para o Firebase.
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 3. Cria uma credencial do Firebase com as credenciais do Google:
    //    Converte as credenciais do Google em um formato que o Firebase entende.
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Autentica o usuário no Firebase com a credencial do Google:
    //    Usa a credencial para fazer o login no Firebase.
    await FirebaseAuth.instance.signInWithCredential(credential);

    // 5. Feedback de Sucesso:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login com Google realizado com sucesso!')),
    );

    // TODO: Navegar para a tela principal do app após o login.

  } on FirebaseAuthException catch (e) {
    // 6. Tratamento de Erros Específicos do Firebase Auth:
    String message;
    if (e.code == 'account-exists-with-different-credential') {
      message = 'Uma conta já existe com o mesmo e-mail, mas com credenciais diferentes.';
    } else if (e.code == 'invalid-credential') {
      message = 'A credencial do Google é inválida ou expirou.';
    } else {
      message = 'Ocorreu um erro ao fazer login com o Google.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  } catch (e) {
    // 7. Tratamento de Erros Genéricos:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ocorreu um erro inesperado ao fazer login com o Google.'), backgroundColor: Colors.red),
    );
  }

  if (mounted) {
    setState(() {
      _isLoading = false;
    });
  }
}
