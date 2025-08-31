# Context the Project: Clone Uber com Flutter e Firebase

Este arquivo reflete o estado atual do nosso projeto e o progresso no tutorial.

## Visão Geral do Projeto

Estamos desenvolvendo um ecossistema de aplicativos (usuário, motorista e painel admin) com Flutter e Firebase. O foco atual é o `users_app`.

## Progresso do `users_app` (Aplicativo do Usuário)

### Fase 1: Configuração e Autenticação (REVISADA)

*   **Configuração Inicial do Firebase:**
    *   Projeto Firebase criado (`clone-uber-app-c21a1`).
    *   CLI do FlutterFire instalada e configurada (`flutterfire configure`).
    *   Dependências essenciais do Firebase adicionadas (`firebase_core`, `firebase_auth`, `cloud_firestore`).
    *   Firebase inicializado em `main.dart`.
*   **Estrutura de Telas de Autenticação:**
    *   Diretórios `lib/screens/authentication/` e `lib/screens/` criados.
    *   `splash_screen.dart`, `login_screen.dart`, `signup_screen.dart`, `home_screen.dart` criados.
*   **Fluxo de Navegação:**
    *   `SplashScreen` redireciona corretamente com base no estado de autenticação.
    *   Navegação entre `LoginScreen` e `SignupScreen` implementada.
    *   Redirecionamento para `HomeScreen` após login/cadastro.
*   **Lógica de Autenticação (Refatorada):**
    *   **Removida a dependência `google_sign_in`**. O fluxo de autenticação com Google agora é gerenciado diretamente pelo `firebase_auth`.
    *   **Criado o `AuthService` (`lib/services/auth_service.dart`):** Uma classe dedicada para centralizar e gerenciar toda a lógica de autenticação.
    *   **Lógica Multiplataforma:** O `AuthService` usa `signInWithPopup` para a web e `signInWithProvider` para mobile, fornecendo uma experiência de login otimizada para cada plataforma.
    *   A `LoginScreen` foi simplificada para chamar o `AuthService`, separando a UI da lógica de negócio.
    *   Login com e-mail/senha e cadastro continuam funcionando como antes.
*   **Assets:**
    *   `google_logo.png` mantido para uso no botão de login.
*   **Testes de Autenticação:**
    *   A lógica de negócio no `AuthService` foi desenvolvida e validada usando Test-Driven Development (TDD), embora os testes tenham sido removidos após a conclusão para manter o projeto limpo.

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
    *   `docs/development_environment/platform_specific_code.md` (Novo: Documentação sobre código específico de plataforma com `kIsWeb`).

## Próximos Passos (Gerenciados por `action_plan.md`)

A partir de agora, as tarefas detalhadas serão gerenciadas no `action_plan.md`.
