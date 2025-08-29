# Plano de Ação do Projeto Clone Uber

Este documento serve como um checklist detalhado das tarefas a serem executadas. Cada item será marcado como concluído (`[x]`) à medida que avançamos.

## Tarefa Principal: Finalizar o Fluxo de Autenticação e Configuração Inicial

### Checklist:

- [ ] **Configurar Repositório GitHub:**
    - [ ] Adicionar o remote `git@github.com:webertmaximiano/clone_uber_app.git`.
    - [ ] Fazer o push inicial do código para o GitHub.
- [ ] **Google Sign-In - Ação do Usuário:**
    - [ ] Colocar o arquivo `google_logo.png` no diretório `users_app/assets/images/`.
- [ ] **Testar o Fluxo de Autenticação:**
    - [ ] Testar o cadastro com e-mail/senha.
    - [ ] Testar o login com e-mail/senha.
    - [ ] Testar o login com Google.
    - [ ] Verificar o redirecionamento da `SplashScreen` para `LoginScreen` ou `HomeScreen`.
- [ ] **Implementar Logout:**
    - [ ] Adicionar um botão de logout na `HomeScreen`.
    - [ ] Implementar a lógica de logout usando `FirebaseAuth.instance.signOut()`.
- [ ] **Navegação Pós-Autenticação:**
    - [ ] Redirecionar para `HomeScreen` após login/cadastro bem-sucedido.
- [ ] **Armazenar Dados do Usuário (Firestore):**
    - [ ] Após o cadastro, salvar informações adicionais do usuário (ex: nome) no Cloud Firestore.
- [ ] **Configuração iOS para Google Sign-In (Opcional/Futuro):**
    - [ ] Configurar o `REVERSED_CLIENT_ID` no Xcode.
- [ ] **Implementar Redefinição de Senha (Opcional/Futuro):**
    - [ ] Adicionar funcionalidade de "Esqueceu a senha?" na `LoginScreen`.
    - [ ] Implementar `FirebaseAuth.instance.sendPasswordResetEmail()`.
