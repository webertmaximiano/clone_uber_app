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
    *   Firebase inicializado em `main.dart`.
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
    *   Login com Google (`signInWithGoogle`) implementado em `LoginScreen`.
*   **Assets:**
    *   Diretório `assets/images/` criado e configurado em `pubspec.yaml`.
    *   **PENDENTE:** O arquivo `google_logo.png` precisa ser colocado manualmente pelo usuário em `users_app/assets/images/`.

## Documentação Adicional

*   `README.md` (raiz do projeto) criado e atualizado.
*   `users_app/TUTORIAL.md` criado e atualizado com o passo a passo do `users_app`.
*   `users_app/DICAS_FLUTTER.md` criado e atualizado com diversas dicas sobre Flutter e Firebase.
    *   **PROBLEMA CONHECIDO:** Houve uma dificuldade persistente em adicionar a dica sobre gerenciamento de assets a este arquivo. A tarefa foi abortada para evitar um loop.

## Próximos Passos (Gerenciados por `action_plan.md`)

A partir de agora, as tarefas detalhadas serão gerenciadas no `action_plan.md`.
