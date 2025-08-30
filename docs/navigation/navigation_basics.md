# Navegação em Flutter (Navigator)

O Flutter gerencia as telas (chamadas de `Route`s) em uma pilha. A tela que você vê é a que está no topo da pilha. O `Navigator` é a ferramenta que usamos para manipular essa pilha.

#### `Navigator.push()` - Empurrar

- **O que faz?** Adiciona uma nova tela (rota) no **topo da pilha**. A tela antiga continua existindo por baixo da nova.
- **Quando usar?** É o método mais comum. Use quando você quer ir para uma nova tela e permitir que o usuário volte para a anterior usando o botão "voltar".
- **Nosso uso:** Usamos `push` para ir da `LoginScreen` para a `SignupScreen`. O usuário pode querer cancelar o cadastro e voltar para o login.

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => const SignupScreen()),
);
```

#### `Navigator.pop()` - Desempurrar

- **O que faz?** Remove a tela que está no **topo da pilha**, revelando a que estava embaixo.
- **Quando usar?** Para fechar a tela atual e voltar para a anterior. É a ação padrão do botão "voltar" do sistema ou de um `AppBar`.
- **Nosso uso:** Usamos `pop` na `SignupScreen` para fechar a tela de cadastro e voltar para a de login.

```dart
Navigator.of(context).pop();
```

#### `Navigator.pushReplacement()` - Substituir

- **O que faz?** Adiciona uma nova tela no topo da pilha, mas **remove a tela anterior** que estava lá. 
- **Quando usar?** Quando você quer ir para uma nova tela e **impedir** que o usuário volte para a anterior. 
- **Nosso uso:** Usamos `pushReplacement` na `SplashScreen`. Após o carregamento, o usuário vai para a tela de Login, e não faz sentido ele poder "voltar" para a tela de carregamento. O mesmo vale para quando o usuário faz login com sucesso: ele vai para a tela principal e não deve poder voltar para a tela de login.

```dart
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => const LoginScreen()),
);
```