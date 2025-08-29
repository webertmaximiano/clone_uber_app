# Tutorial: Aplicativo do Usuário (users_app)

Este documento detalha o passo a passo para o desenvolvimento do aplicativo do passageiro do nosso clone do Uber.

> **Arquivo de Dicas:** Para aprofundar seus conhecimentos, consulte nosso arquivo de [Dicas e Boas Práticas de Flutter](./DICAS_FLUTTER.md).


## Pré-requisitos

Antes de começar, certifique-se de que você configurou seu ambiente de desenvolvimento conforme descrito no [`README.md`](../README.md) principal do projeto.

---

## Fase 1: Estrutura e Configuração Inicial

### Passo 1: Configuração do Firebase

Nesta etapa, conectamos nosso aplicativo Flutter a um projeto Firebase.

**1.1. Crie um Projeto no Firebase:**
   - Acesse o [console do Firebase](https://console.firebase.google.com/).
   - Crie um novo projeto (ex: `clone-uber-app`).

**1.2. Instale a CLI do FlutterFire:**
   - Em qualquer terminal, execute o comando global para instalar a ferramenta de linha de comando do FlutterFire:
     ```bash
     dart pub global activate flutterfire_cli
     ```

**1.3. Configure o App com o FlutterFire:**
   - **Navegue até a pasta do projeto:**
     ```bash
     cd users_app
     ```
   - Execute o comando de configuração, substituindo `clone-uber-app-c21a1` pelo ID do seu projeto Firebase:
     ```bash
     flutterfire configure --project=clone-uber-app-c21a1
     ```
   - Este comando gera o arquivo `lib/firebase_options.dart`.

**1.4. Adicione as Dependências do Firebase:**
   - Ainda no diretório `users_app`, adicione os pacotes necessários para o Firebase funcionar:
     ```bash
     # Pacote principal do Firebase
     flutter pub add firebase_core

     # Pacotes para autenticação e banco de dados
     flutter pub add firebase_auth cloud_firestore
     ```

**1.5. Inicialize o Firebase no Código:**
   - Modifique o arquivo `lib/main.dart` para garantir que o Firebase seja inicializado antes do app iniciar.

   ```dart
   // lib/main.dart

   import 'package:flutter/material.dart';
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart';

   void main() async { // 1. Transforme o main em assíncrono
     // 2. Garanta que os Widgets do Flutter foram inicializados
     WidgetsFlutterBinding.ensureInitialized();
     
     // 3. Inicialize o Firebase
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );

     runApp(const MyApp());
   }

   // ... (resto do código)
   ```

---

### Passo 2: Autenticação de Usuários

Agora, vamos construir as telas e a lógica para que os usuários possam se cadastrar e entrar no aplicativo.

**2.1. Crie a Estrutura de Pastas:**
   - Para organizar as telas, criaremos a seguinte estrutura dentro da pasta `lib`:
     ```
     /lib
     |-- screens/
     |   `-- authentication/
     ```

**2.2. Crie a Tela de Splash (Próximo Passo):**
   - Criaremos o arquivo `lib/screens/authentication/splash_screen.dart`.
   - Esta tela será a primeira a ser exibida, e irá verificar se o usuário já está logado ou não.
