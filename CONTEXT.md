# Contexto do Projeto: Clone Uber com Flutter e Firebase

Este arquivo reflete o estado atual do nosso projeto e o progresso no tutorial.

## Visão Geral do Projeto

Estamos desenvolvendo um ecossistema de aplicativos (usuário, motorista e painel admin) com Flutter e Firebase. O foco atual é o `users_app`.

## Progresso do `users_app` (Aplicativo do Usuário)

### Fase 1: Configuração e Autenticação

*   **Configuração Inicial do Firebase:**
    *   Projeto Firebase criado (`clone-uber-app-c21a1`).
    *   CLI do FlutterFire instalada e configurada (`flutterfire configure`).
    *   Dependências essenciais do Firebase adicionadas (`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`).
    *   Firebase inicializado em `main.dart` e conectado ao emulador de autenticação.
*   **Estrutura de Telas de Autenticação:**
    *   Diretórios `lib/screens/authentication/` e `lib/screens/` criados.
    *   `splash_screen.dart`, `login_screen.dart`, `signup_screen.dart` criados.
    *   `home_screen.dart` (placeholder) criado.
*   **Fluxo de Navegação:**
    *   `SplashScreen` redireciona para `LoginScreen` ou `HomeScreen` com base no estado de autenticação (`authStateChanges`).
    *   Navegação entre `LoginScreen` e `SignupScreen` implementada.
*   **Lógica de Autenticação:**
    *   Validação de formulário implementada em `SignupScreen` e `LoginScreen`.
    *   Cadastro de usuário com e-mail/senha (`createUserWithEmailAndPassword`) implementado em `SignupScreen`.
    *   Login de usuário com e-mail/senha (`signInWithEmailAndPassword`) implementado em `LoginScreen`.
    *   Login com Google (`signInWithGoogle`) implementado em `LoginScreen` (com ajuste para não usar emulador na web).
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