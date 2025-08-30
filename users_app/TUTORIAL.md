# Tutorial: Aplicativo do Usuário (users_app)

Este documento detalha o passo a passo para o desenvolvimento do aplicativo do passageiro do nosso clone do Uber.

## Pré-requisitos

Antes de começar, certifique-se de que você configurou seu ambiente de desenvolvimento conforme descrito no [`README.md`](../README.md) principal do projeto.

---

## Fase 1: Estrutura e Configuração Inicial

### Passo 1: Configuração do Firebase

Nesta etapa, conectamos nosso aplicativo Flutter a um projeto Firebase.

*   **Crie um Projeto no Firebase:** Acesse o [console do Firebase](https://console.firebase.google.com/) e crie um novo projeto (ex: `clone-uber-app`).
*   **Instale a CLI do FlutterFire:** Em qualquer terminal, execute `dart pub global activate flutterfire_cli`.
*   **Configure o App com o FlutterFire:** Navegue até `users_app/` e execute `flutterfire configure --project=clone-uber-app-c21a1`.
*   **Adicione as Dependências do Firebase:** Ainda em `users_app/`, execute `flutter pub add firebase_core firebase_auth cloud_firestore google_sign_in`.
*   **Inicialize o Firebase no Código:** Modifique `lib/main.dart` para inicializar o Firebase e conectar ao emulador em modo de debug.

    *   **Para mais detalhes sobre a configuração do Firebase, consulte:** [`docs/firebase/authentication.md`](../../docs/firebase/authentication.md)

### Passo 2: Autenticação de Usuários

Agora, vamos construir as telas e a lógica para que os usuários possam se cadastrar e entrar no aplicativo.

*   **Crie a Estrutura de Pastas:** Crie `lib/screens/authentication/` e `lib/screens/`.
*   **Crie a Tela de Splash:** Crie `lib/screens/authentication/splash_screen.dart` e configure `lib/main.dart` para usá-la.
*   **Crie as Telas de Login e Cadastro:** Crie `lib/screens/authentication/login_screen.dart` e `lib/screens/authentication/signup_screen.dart`.
*   **Implemente o Fluxo de Navegação:** Configure a navegação entre `SplashScreen`, `LoginScreen` e `SignupScreen`.
*   **Implemente a Lógica de Autenticação:** Adicione validação de formulário e integração com Firebase Auth (e-mail/senha e Google Sign-In) nas telas de Login e Cadastro.
*   **Implemente o Logout:** Adicione um botão de logout na `HomeScreen`.

    *   **Para mais detalhes sobre a estrutura de pastas, consulte:** [`docs/project_structure/project_structure.md`](../../docs/project_structure/project_structure.md)
    *   **Para mais detalhes sobre StatelessWidget vs. StatefulWidget, consulte:** [`docs/flutter_basics/stateless_stateful_widgets.md`](../../docs/flutter_basics/stateless_stateful_widgets.md)
    *   **Para mais detalhes sobre navegação, consulte:** [`docs/navigation/navigation_basics.md`](../../docs/navigation/navigation_basics.md)
    *   **Para mais detalhes sobre validação de formulários, consulte:** [`docs/forms/form_validation.md`](../../docs/forms/form_validation.md)
    *   **Para mais detalhes sobre programação assíncrona, consulte:** [`docs/async_programming/async_await_futures.md`](../../docs/async_programming/async_await_futures.md)
    *   **Para mais detalhes sobre o fluxo de Login, consulte:** [`docs/login/login_flow.md`](../../docs/login/login_flow.md)
    *   **Para mais detalhes sobre o fluxo de Cadastro, consulte:** [`docs/signup/signup_flow.md`](../../docs/signup/signup_flow.md)

---

## Próximos Passos

Consulte o `action_plan.md` na raiz do projeto para as próximas tarefas detalhadas.