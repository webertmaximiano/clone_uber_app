# Fluxo de Cadastro (SignupScreen)

Este documento detalha a implementação da tela de cadastro, incluindo validação de formulário e criação de usuário com e-mail/senha no Firebase Authentication.

## Visão Geral da Tela

A `SignupScreen` é uma `StatefulWidget` que gerencia o estado dos campos de nome, e-mail, senha e confirmação de senha, além de interagir com o Firebase Authentication.

## Componentes Principais

-   **`TextEditingController`**: Usados para capturar o texto digitado nos campos.
-   **`GlobalKey<FormState>`**: Essencial para validar o formulário.
-   **`_isLoading`**: Variável booleana para controlar o indicador de carregamento e desabilitar o botão durante o cadastro.

## Lógica de Cadastro (`_submitForm`)

Este método é acionado quando o usuário clica no botão "Cadastrar".

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
    // 3. Criação de Usuário com Firebase:
    //    Chama o método createUserWithEmailAndPassword do Firebase Authentication.
    //    'await' pausa a execução até que a operação assíncrona seja concluída.
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // 4. Feedback de Sucesso:
    //    Exibe uma mensagem de sucesso na parte inferior da tela.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro realizado com sucesso!')),
    );

    // 5. Navegação Pós-Cadastro:
    //    Após o sucesso, podemos navegar para a próxima tela (ex: tela principal)
    //    ou voltar para a tela de login. Por enquanto, voltamos para a tela de login.
    if (mounted) Navigator.of(context).pop();

  } on FirebaseAuthException catch (e) {
    // 6. Tratamento de Erros Específicos do Firebase:
    //    Captura exceções lançadas pelo Firebase Authentication e exibe mensagens amigáveis.
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
    // 7. Tratamento de Erros Genéricos:
    //    Captura qualquer outro erro inesperado.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ocorreu um erro inesperado.'), backgroundColor: Colors.red),
    );
  }

  // 8. Desativar Indicador de Carregamento:
  //    Garante que o indicador de carregamento seja desativado, independentemente do resultado.
  if (mounted) { // Verifica se o widget ainda está na árvore antes de chamar setState.
    setState(() {
      _isLoading = false;
    });
  }
}
