# Dicas e Boas Práticas de Flutter

Este arquivo é um registro de dicas, padrões e boas práticas que aprendemos durante o desenvolvimento do projeto. 

---

### Dica 1: Estrutura de Pastas em Projetos Flutter

O Flutter é flexível e **não impõe uma estrutura de pastas rígida** para o código que fica dentro da pasta `lib/`. No entanto, a comunidade adota alguns padrões para manter os projetos organizados e escaláveis.

As duas abordagens mais populares são:

#### 1. Agrupamento por Funcionalidade (Feature-first)

Neste padrão, você cria pastas para cada funcionalidade principal do seu aplicativo. Todo o código relacionado a uma feature (telas, widgets, lógica de estado, etc.) fica agrupado no mesmo lugar.

**Exemplo:**
```
/lib
|-- authentication/  # Tudo de autenticação aqui
|   |-- screens/
|   |   |-- login_screen.dart
|   |   `-- signup_screen.dart
|   |-- widgets/
|   |   `-- auth_button.dart
|   `-- services/
|       `-- auth_service.dart
|-- home/            # Tudo da tela principal aqui
|-- profile/         # Tudo do perfil do usuário aqui
```

- **Vantagem:** Excelente para escalabilidade e manutenção, pois encontrar e modificar uma funcionalidade completa é muito mais fácil. É o padrão mais recomendado para projetos médios e grandes.

#### 2. Agrupamento por Tipo (Layer-first)

Nesta abordagem, você agrupa os arquivos pelo que eles *são* tecnicamente.

**Exemplo:**
```
/lib
|-- screens/         # Todas as telas do app
|   |-- login_screen.dart
|   `-- home_screen.dart
|-- widgets/         # Todos os widgets reutilizáveis
|   |-- custom_button.dart
|   `-- user_avatar.dart
|-- models/          # Todas as classes de modelo de dados
|-- services/        # Toda a lógica de negócio e APIs
```

- **Vantagem:** Pode ser mais simples de entender para iniciantes e em projetos pequenos. 

#### Nossa Abordagem (Híbrida)

No nosso projeto, estamos usando uma abordagem híbrida, que é muito comum: separamos as `screens` (um tipo) e, dentro delas, agrupamos por `authentication` (uma funcionalidade). Isso nos dá um bom equilíbrio entre organização e simplicidade.

---

### Dica 2: StatelessWidget vs. StatefulWidget

No Flutter, tudo é um widget, mas eles se dividem em duas categorias principais:

#### `StatelessWidget` (Widget Sem Estado)

- **O que é?** Um widget que **não pode mudar** sua aparência ou os dados que exibe depois de ser construído. Ele é "burro" e apenas exibe as informações que recebe.
- **Quando usar?** Para qualquer parte da interface que é estática. Pense em ícones, textos fixos, botões que sempre têm a mesma aparência, ou qualquer widget que apenas recebe dados e os exibe sem interagir com eles.
- **Exemplo:** Uma tela de "Sobre", um cartão de informações, o título de uma página.

#### `StatefulWidget` (Widget Com Estado)

- **O que é?** Um widget que **pode mudar** dinamicamente. Ele tem um objeto `State` associado que pode guardar dados (o "estado") e notificar o Flutter para redesenhar a tela quando esses dados mudam (usando o método `setState()`).
- **Quando usar?** Sempre que a interface precisar ser atualizada em resposta a uma interação do usuário ou a dados que chegam (de uma API, por exemplo).
- **Exemplo:**
    - **Formulários:** Como nas nossas telas de Login e Cadastro, onde precisamos armazenar o que o usuário digita.
    - **Animações:** O estado da animação (progresso, cor, tamanho) muda com o tempo.
    - **Checkboxes e Sliders:** O estado de "marcado" ou o valor do slider precisam ser armazenados.
    - **Qualquer tela que busca dados da internet:** Ela começa em um estado de "carregando" e depois muda para "dados recebidos" ou "erro".

Nós usamos `StatefulWidget` para `LoginScreen` e `SignupScreen` porque os `TextEditingController` e o que o usuário digita neles são um **estado** que precisa ser gerenciado pela tela.

---

### Dica 3: Navegação em Flutter (Navigator)

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

- **O que faz??** Remove a tela que está no **topo da pilha**, revelando a que estava embaixo.
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

---

### Dica 4: Executando um App Flutter na Web

Quando você executa `flutter run` e escolhe `Chrome` como dispositivo, o Flutter compila a versão web do seu aplicativo e a serve localmente.

#### Porta de Execução

- **Porta Automática:** Por padrão, o Flutter procura uma porta de rede que esteja livre no seu computador e a utiliza. É por isso que o número da porta (como em `http://localhost:42321`) pode mudar a cada execução.

- **Especificando uma Porta:** Se você precisar usar uma porta específica (por exemplo, para configurar um proxy ou porque outra parte do seu sistema espera por isso), você pode usar a flag `--web-port`.

```bash
# Executa o app na web na porta 8080
flutter run -d chrome --web-port=8080
```

Isso lhe dá mais controle sobre o ambiente de desenvolvimento local.

---

### Dica 5: Validação de Formulários com Form e GlobalKey

Coletar dados do usuário é uma tarefa comum, e garantir que esses dados sejam válidos é essencial. O Flutter oferece um sistema robusto para isso usando três componentes principais:

1.  **`Form`**: Um widget que atua como um contêiner para agrupar múltiplos campos de formulário (`TextFormField`). Ele ajuda a gerenciar o estado de todos os campos de uma só vez.

2.  **`TextFormField`**: Uma versão do `TextField` que já vem preparada para trabalhar dentro de um `Form`. Sua principal característica é a propriedade `validator`.

3.  **`GlobalKey<FormState>`**: Uma chave que nos dá acesso direto ao `Form` de qualquer lugar da nossa árvore de widgets (dentro do mesmo `State`). Pense nela como um "controle remoto" para o nosso formulário.

#### Como Funciona o Fluxo?

- **Criação da Chave:** Primeiro, criamos uma `GlobalKey<FormState>` no estado do nosso widget.
  ```dart
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ```

- **Associação:** Em seguida, associamos essa chave ao nosso widget `Form`.
  ```dart
  Form(
    key: _formKey,
    child: ...
  )
  ```

- **Validação:** Em cada `TextFormField`, nós fornecemos uma função para a propriedade `validator`. Essa função recebe o texto atual do campo e deve retornar:
    - `null` se o valor for válido.
    - Uma `String` com a mensagem de erro se o valor for inválido.

- **Acionamento:** Finalmente, para acionar a validação de todos os campos dentro do `Form`, usamos nossa chave para acessar o estado do formulário e chamar o método `validate()`.
  ```dart
  if (_formKey.currentState!.validate()) {
    // Se validate() retornar true, todos os campos são válidos.
    // Podemos prosseguir com a lógica de negócio.
  } else {
    // Se retornar false, o Flutter exibirá automaticamente as mensagens
    // de erro que definimos nos validadores de cada campo.
  }
  ```

Este mecanismo é poderoso porque separa a lógica de validação em pequenos pedaços (em cada campo) e nos dá um controle centralizado para acionar essa validação e verificar o resultado.

---

### Dica 6: Programação Assíncrona em Dart (async, await, Future)

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
- **Quando usar?** Quando sua função precisa realizar uma operação que leva tempo e você não quer bloquear a interface do usuário.

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

---

### Dica 7: Autenticação com Firebase (Firebase Authentication)

O Firebase Authentication é um serviço completo que facilita a adição de autenticação segura ao seu aplicativo. Ele suporta vários métodos de login (e-mail/senha, Google, Facebook, etc.) e gerencia o ciclo de vida do usuário.

#### Como funciona?

- **Provedores de Autenticação:** O Firebase atua como um intermediário. Você configura os provedores de autenticação que deseja usar (e-mail/senha, Google, etc.) no console do Firebase.

- **SDK do Cliente:** No seu aplicativo Flutter, você usa o SDK do Firebase Authentication (`firebase_auth`) para interagir com o serviço.

- **Criação de Usuários (`createUserWithEmailAndPassword`):**
  - Usado para registrar novos usuários com e-mail e senha.
  - Se bem-sucedido, o Firebase cria um novo registro de usuário e retorna um `UserCredential`.
  - Erros comuns: e-mail já em uso, senha fraca, e-mail inválido.

- **Login de Usuários (`signInWithEmailAndPassword`):**
  - Usado para autenticar usuários existentes com e-mail e senha.
  - Se bem-sucedido, o Firebase verifica as credenciais e retorna um `UserCredential`.
  - Erros comuns: usuário não encontrado, senha incorreta.

- **Login com Provedores Externos (ex: Google, Facebook):**
  - O processo é um pouco diferente: primeiro, você autentica o usuário com o provedor externo (ex: `google_sign_in`).
  - O provedor externo retorna um token de acesso ou ID. 
  - Você usa esse token para criar uma credencial do Firebase (`GoogleAuthProvider.credential`).
  - Finalmente, você usa `FirebaseAuth.instance.signInWithCredential()` para autenticar o usuário no Firebase com essa credencial.

#### Gerenciamento de Usuários no Console do Firebase

Você pode ver e gerenciar todos os usuários autenticados (e-mail/senha, Google, etc.) na seção **Authentication** do seu projeto no [console do Firebase](https://console.firebase.google.com/). Isso é útil para depuração e administração.