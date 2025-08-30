# Programação Assíncrona em Dart (async, await, Future)

No desenvolvimento de aplicativos, muitas operações levam tempo para serem concluídas, como buscar dados da internet, ler um arquivo ou, no nosso caso, interagir com o Firebase. Se essas operações fossem executadas de forma síncrona (uma após a outra), a interface do usuário ficaria "congelada" e não responsiva.

Dart, a linguagem do Flutter, lida com isso de forma elegante usando programação assíncrona com `async`, `await` e `Future`.

#### `Future`

- **O que é?** Um `Future` é um objeto que representa o resultado de uma operação assíncrona que ainda não foi concluída. Pense nele como uma "promessa" de que um valor estará disponível no futuro.
- **Estados:** Um `Future` pode estar em um de três estados:
    - **Incompleto:** A operação ainda está em andamento.
    - **Concluído com um valor:** A operação terminou com sucesso e produziu um resultado.
    - **Concluído com um erro:** A operação falhou e lançou uma exceção.

#### `async`

- **O que é?** A palavra-chave `async` é usada para marcar uma função como assíncrona. Uma função `async` sempre retorna um `Future`.
- **Quando usar??** Quando sua função precisa realizar uma operação que leva tempo e você não quer bloquear a interface do usuário.

#### `await`

- **O que é?** A palavra-chave `await` só pode ser usada dentro de uma função `async`. Ela pausa a execução da função `async` até que o `Future` que ela está "aguardando" seja concluído. Enquanto a função está pausada, o Flutter pode continuar a construir a interface do usuário e responder a outras interações.
- **Quando usar?** Antes de uma chamada de função que retorna um `Future` e você precisa do resultado dessa `Future` para continuar a execução da sua função.

#### Exemplo no nosso código:

No método `_submitForm` da `SignupScreen` e `LoginScreen`, usamos:

```dart
Future<void> _submitForm() async { // Função é assíncrona
  // ...
  await FirebaseAuth.instance.createUserWithEmailAndPassword(...); // Aguarda o Firebase
  // ...
}
```

Isso permite que o aplicativo continue responsivo enquanto espera a resposta do Firebase, proporcionando uma experiência de usuário fluida.