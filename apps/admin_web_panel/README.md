# Admin Web Panel - Clone Uber

Sistema de administração web para gerenciar a plataforma Clone Uber.

## Funcionalidades

- 📊 Dashboard com estatísticas
- 👥 Gerenciamento de usuários
- 🚗 Gerenciamento de motoristas
- 🗺️ Monitoramento de corridas em tempo real
- 💰 Gerenciamento de pagamentos
- ⚙️ Configurações do sistema

## Pré-requisitos

- Flutter SDK (>=3.4.3)
- Dart SDK
- Firebase Project configurado
- VS Code ou Android Studio

## Instalação

### 1. Configuração do Firebase

Navegue até este diretório:

```bash
cd admin_web_panel
```

Configure o Firebase:

```bash
flutterfire configure --project=clone-uber-app-c21a1
```

### 2. Instalação de Dependências

```bash
flutter pub get
```

## Executando a Aplicação

### No navegador (Chrome)

```bash
flutter run -d chrome --web-port=8080
```

### Em modo de produção

```bash
flutter build web --release
```

## Estrutura de Pastas

```
lib/
├── main.dart                          # Ponto de entrada
├── firebase_options.dart              # Configuração do Firebase
├── screens/
│   ├── authentication/
│   │   ├── splash_screen.dart        # Tela de inicialização
│   │   └── login_screen.dart         # Tela de login
│   └── dashboard/
│       └── dashboard_screen.dart     # Dashboard principal
├── services/
│   └── admin_auth_service.dart       # Serviço de autenticação
└── models/
    └── (modelos de dados)
```

## Autenticação

O painel de admin utiliza autenticação baseada em e-mail e senha com Firebase Auth.

### Credenciais Padrão (Desenvolvimento)

Após criar um usuário admin no Firebase Console, use suas credenciais para fazer login.

## Fluxo de Navegação

1. **SplashScreen** → Verifica se há usuário autenticado
2. Se autenticado → **DashboardScreen**
3. Se não autenticado → **LoginScreen** → **DashboardScreen**

## Para Mais Informações

Consulte a documentação principal em `../../README.md`
