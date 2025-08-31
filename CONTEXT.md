# Context the Project: Clone Uber com Flutter e Firebase

Este arquivo reflete o estado atual do nosso projeto e o progresso no tutorial.

## Visão Geral do Projeto

Estamos desenvolvendo um ecossistema de aplicativos (usuário, motorista e painel admin) com Flutter e Firebase. O foco atual é o `users_app`.

## Progresso do `users_app` (Aplicativo do Usuário)

### Fase 1: Configuração e Autenticação (COMPLETA)

*   **Configuração Inicial do Firebase:**
    *   Projeto Firebase criado (`clone-uber-app-c21a1`).
    *   CLI do FlutterFire instalada e configurada (`flutterfire configure`).
    *   Dependências essenciais do Firebase adicionadas (`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`).
    *   Firebase inicializado em `main.dart` e conectado ao emulador de autenticação (condicionalmente para web).
*   **Estrutura de Telas de Autenticação:**
    *   Diretórios `lib/screens/authentication/` e `lib/screens/` criados.
    *   `splash_screen.dart`, `login_screen.dart`, `signup_screen.dart` criados.
    *   `home_screen.dart` (placeholder) criado.
*   **Fluxo de Navegação:**
    *   `SplashScreen` redireciona para `LoginScreen` ou `HomeScreen` com base no estado de autenticação (`authStateChanges`), com correção para widget desmontado.
    *   Navegação entre `LoginScreen` e `SignupScreen` implementada.
    *   Redirecionamento para `HomeScreen` após login/cadastro bem-sucedido.
*   **Lógica de Autenticação:**
    *   Validação de formulário implementada em `SignupScreen` e `LoginScreen`.
    *   Cadastro de usuário com e-mail/senha (`createUserWithEmailAndPassword`) implementado em `SignupScreen`.
    *   Login de usuário com e-mail/senha (`signInWithEmailAndPassword`) implementado em `LoginScreen`.
    *   Login com Google (`signInWithGoogle`) implementado em `LoginScreen` (com `clientId` e ajuste para não usar emulador na web).
    *   Logout implementado na `HomeScreen`.
    *   Dados do usuário (nome) armazenados no Cloud Firestore após o cadastro.
*   **Assets:**
    *   Diretório `assets/images/` criado e configurado em `pubspec.yaml`.
    *   `google_logo.png` colocado manualmente pelo usuário em `users_app/assets/images/`.
*   **Testes de Autenticação:**
    *   Cadastro com e-mail/senha testado e funcionando.
    *   Login com e-mail/senha testado e funcionando.
    *   Login com Google testado e funcionando.
    *   Redirecionamento da `SplashScreen` para `LoginScreen` ou `HomeScreen` verificado e funcionando.
*   **Correções Adicionais:**
    *   Meta tag deprecated em `index.html` corrigida.

## Documentação Adicional (NOVA ESTRUTURA)

*   `README.md` (raiz do projeto) criado e atualizado.
*   `users_app/TUTORIAL.md` atualizado para apontar para a nova estrutura `docs/`.
*   **Nova estrutura `docs/` criada e populada com conteúdo migrado:**
    *   `docs/project_structure/project_structure.md`
    *   `docs/flutter_basics/stateless_stateful_widgets.md`
    *   `docs/navigation/navigation_basics.md`
    *   `docs/development_environment/web_run.md`
    *   `docs/forms/form_validation.md`
    *   `docs/async_programming/async_await_futures.md`
    *   `docs/firebase/authentication.md`
    *   `docs/assets/asset_management.md`
    *   `docs/login/login_flow.md`
    *   `docs/signup/signup_flow.md`
    *   `docs/user_stories/` (diretório criado, aguardando conteúdo)

## Próximos Passos (Gerenciados por `action_plan.md`)

A partir de agora, as tarefas detalhadas serão gerenciadas no `action_plan.md`.

Realizar o upgrade sem quebrar o sistema, nosso app precisa ser capaz de rodar em android e no web app dos navegadores

git reset --hard 3ea9864cc26ddfeddaec2e4272262dae9cbb1fa3
HEAD is now at 3ea9864 Update CONTEXT.md and GEMINI.md for daily resume.
webert@webert-Aspire-E5-575:~/clone_uber/users_app$ flutter run -d chrome --web-port 3000
Resolving dependencies... (5.1s)
Downloading packages... (1.1s)
async 2.11.0 (2.13.0 available)
boolean_selector 2.1.1 (2.1.2 available)
> characters 1.4.0 (was 1.3.0) (1.4.1 available)
> clock 1.1.2 (was 1.1.1)
> collection 1.19.1 (was 1.18.0)
> fake_async 1.3.3 (was 1.3.1)
flutter_lints 3.0.2 (6.0.0 available)
google_sign_in 6.2.2 (7.1.1 available)
google_sign_in_android 6.1.31 (7.0.5 available)
google_sign_in_ios 5.9.0 (6.1.0 available)
google_sign_in_platform_interface 2.5.0 (3.0.0 available)
google_sign_in_web 0.12.4+4 (1.0.0 available)
http_parser 4.0.2 (4.1.2 available)
> leak_tracker 11.0.1 (was 10.0.4)
> leak_tracker_flutter_testing 3.0.10 (was 3.0.3)
> leak_tracker_testing 3.0.2 (was 3.0.1)
lints 3.0.0 (6.0.0 available)
> matcher 0.12.17 (was 0.12.16+1)
> material_color_utilities 0.11.1 (was 0.8.0) (0.13.0 available)
> meta 1.16.0 (was 1.12.0) (1.17.0 available)
> path 1.9.1 (was 1.9.0)
< sky_engine 0.0.0 from sdk flutter (was 0.0.99 from sdk flutter)
source_span 1.10.0 (1.10.1 available)
> stack_trace 1.12.1 (was 1.11.1)
> stream_channel 2.1.4 (was 2.1.2)
string_scanner 1.2.0 (1.4.1 available)
term_glyph 1.2.1 (1.2.2 available)
> test_api 0.7.6 (was 0.7.0) (0.7.7 available)
typed_data 1.3.2 (1.4.0 available)
> vector_math 2.2.0 (was 2.1.4)
vm_service 14.2.1 (15.0.2 available)
Changed 16 dependencies!
19 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Launching lib/main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...            133,2s
DebugService: Error serving requestsError: Unsupported operation: Cannot send Null
DebugService: Error serving requestsError: Unsupported operation: Cannot send Null
DebugService: Error serving requestsError: Unsupported operation: Cannot send Null
DebugService: Error serving requestsError: Unsupported operation: Cannot send Null
DebugService: Error serving requestsError: Unsupported operation: Cannot send Null

Guia pra migração https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in/MIGRATION.md

pacote https://pub.dev/packages/google_sign_in
guia web https://pub.dev/packages/google_sign_in_web#integration
e Android https://pub.dev/packages/google_sign_in_android#integration

vi que nosso sistema precisa ter a inteligencia pra saber se ele esta rodando no android ou no web, até mesmo no ios,
isso é possivel com o fluter como configuramos e documentamos isso?

login_screen.dart cheio de erro tem um erro que persiste
lutter run -d chrome --web-port 3000
Launching lib/main.dart on Chrome in debug mode...
lib/screens/authentication/login_screen.dart:32:38: Error: Couldn't find constructor 'GoogleSignIn'.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
                                     ^^^^^^^^^^^^
lib/screens/authentication/login_screen.dart:63:67: Error: The method 'signIn' isn't defined for the type 'GoogleSignIn'.
 - 'GoogleSignIn' is from 'package:google_sign_in/google_sign_in.dart'
 ('../../.pub-cache/hosted/pub.dev/google_sign_in-7.1.1/lib/google_sign_in.dart').
Try correcting the name to the name of an existing method, or defining a method named 'signIn'.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
                                                                  ^^^^^^
Waiting for connection from debug service on Chrome...             69,8s
Failed to compile application.

Diante disso, ativei a Identy Platform no gcloud 
Os métodos que os usuários podem usar para fazer login no seu projeto. Por padrão, todos os provedores estão desativados.

Nome
Ativadas
Email / Password	
Google	
Agora precisamos configurar o projeto pra usar a plataforma de autenticação 
<script src="https://www.gstatic.com/firebasejs/8.0/firebase.js"></script>
<script>
  var config = {
    apiKey: "AIzaSyBXEXtPpwlHk8ZDGxp2eiJPDHbd6kkeDJI",
    authDomain: "clone-uber-app-c21a1.firebaseapp.com",
  };
  firebase.initializeApp(config);
</script>