# Autenticação com Firebase (Firebase Authentication)

O Firebase Authentication é um serviço completo que facilita a adição de autenticação segura ao seu aplicativo. Ele suporta vários métodos de login (e-mail/senha, Google, Facebook, etc.) e gerencia o ciclo de vida do usuário.

#### Como funciona?

- **Provedores de Autenticação:** Você configura os provedores que deseja usar (e-mail/senha, Google, etc.) no console do Firebase.

- **SDK do Cliente:** No seu aplicativo Flutter, você usa o SDK do Firebase Authentication (`firebase_auth`) para interagir com o serviço.

- **Criação de Usuários (`createUserWithEmailAndPassword`):**
  - Usado para registrar novos usuários com e-mail e senha.
  - Se bem-sucedido, o Firebase cria um novo registro de usuário e retorna um `UserCredential`.

- **Login de Usuários (`signInWithEmailAndPassword`):**
  - Usado para autenticar usuários existentes com e-mail e senha.
  - Se bem-sucedido, o Firebase verifica as credenciais e retorna um `UserCredential`.

- **Login com Provedores Externos (ex: Google) - A Abordagem Correta:**
  - O próprio pacote `firebase_auth` agora gerencia o fluxo completo, sem a necessidade do pacote `google_sign_in`.
  - A lógica é separada por plataforma para uma melhor experiência do usuário:
    - **Na Web:** Usa-se `FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider())`. Isso abre o popup de login padrão do Google no navegador.
    - **No Mobile (Android/iOS):** Usa-se `FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider())`. Isso usa o fluxo de login nativo do sistema operacional, integrado à conta Google do aparelho.
  - Essa abordagem é mais robusta e simplifica o código, eliminando dependências extras.

#### Centralizando a Lógica no `AuthService`

Para manter nosso código limpo e organizado, toda essa lógica de autenticação foi centralizada em uma classe `AuthService` (`lib/services/auth_service.dart`). As telas de UI (como `LoginScreen`) agora simplesmente chamam os métodos deste serviço (ex: `_authService.signInWithGoogle()`), sem precisar conhecer os detalhes da implementação. Isso é um princípio de design de software chamado **Separação de Responsabilidades**.

#### Gerenciamento de Usuários no Console do Firebase

Você pode ver e gerenciar todos os usuários autenticados na seção **Authentication** do seu projeto no [console do Firebase](https://console.firebase.google.com/).
