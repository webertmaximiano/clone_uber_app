# Uber Clone - Driver App - Tutorial

## 📋 Visão Geral

O **Drivers App** é a aplicação mobile para motoristas da plataforma Clone Uber. Ele permite que motoristas se registrem, façam login, gerenciem seu perfil, visualizem corridas disponíveis e aceitem/recusem corridas.

## 🚀 Fase 1: Autenticação e Dashboard (COMPLETO)

### Screens Implementadas

#### 1. **SplashScreen** (`splash_screen.dart`)
- Exibe o ícone e nome do app por 3 segundos
- Verifica se o usuário já está autenticado
- Redireciona para `/dashboard` se autenticado, `/login` caso contrário

#### 2. **DriverLoginScreen** (`driver_login_screen.dart`)
- Login com email e senha
- Login com Google Sign-In
- Validação de formulário
- Tratamento de erros com SnackBar
- Link para tela de cadastro

**Fluxo:**
```
Email + Senha → DriverAuthService.signInWithEmail()
          ↓
     Firestore atualiza lastActive
          ↓
    → Dashboard
```

#### 3. **DriverSignupScreen** (`driver_signup_screen.dart`)
- Registro com email e senha
- Dados adicionais: nome, telefone, tipo de veículo, placa
- Validação de todos os campos
- Dropdown para seleção de tipo de veículo
- Cria documento do motorista no Firestore

**Fluxo:**
```
Form dados → DriverAuthService.signUpWithEmail()
         ↓
    Firestore.drivers.doc(uid).set({...})
         ↓
      Dashboard
```

#### 4. **DriverDashboard** (`driver_dashboard.dart`)
- Exibição do perfil do motorista
- Switch para status Online/Offline
- Cards com estatísticas (corridas hoje, ganho, total)
- Seção de corridas ativas (placeholder)
- Seção de próximas corridas (placeholder)
- Botão de logout com confirmação

**Funcionalidades:**
- `_toggleOnlineStatus()`: Atualiza status no Firestore e app
- `_handleLogout()`: Confirma logout e redireciona para login
- Exibe email do usuário logado (via `currentUser`)

### Serviço de Autenticação

#### **DriverAuthService** (`driver_auth_service.dart`)

**Métodos Principais:**

```dart
// Sign Up
signUpWithEmail({
  email, password, name, phoneNumber, vehicleType, licensePlate
}) → UserCredential

// Sign In
signInWithEmail({email, password}) → UserCredential

// Google Sign-In
signInWithGoogle() → UserCredential

// Sign Out
signOut() → Future<void>

// Status Updates
updateOnlineStatus(isOnline) → Future<void>
updateLocation(latitude, longitude) → Future<void>

// Getters
currentUser → User?
authStateChanges → Stream<User?>
```

**Fluxo de Autenticação:**
1. Firebase Auth cria usuário
2. Firestore cria documento `drivers/{uid}` com dados iniciais
3. Validação de email antes de usar certos recursos
4. Google Sign-In cria doc apenas se não existir

### Estrutura Firestore (Drivers)

```javascript
{
  "drivers": {
    "driverId": {
      "id": "driverId",
      "email": "driver@email.com",
      "name": "João Motorista",
      "phoneNumber": "(11) 98765-4321",
      "profileImageUrl": "url_imagem",
      "vehicleType": "Carro Popular",
      "licensePlate": "ABC1D23",
      "rating": 5.0,
      "totalEarnings": 0.0,
      "totalRides": 0,
      "isOnline": false,
      "isActive": true,
      "currentLatitude": 0.0,
      "currentLongitude": 0.0,
      "createdAt": Timestamp(2024-01-17),
      "lastActive": Timestamp(2024-01-17),
      "documentVerified": false
    }
  }
}
```

### Configuração Firebase

O projeto usa a mesma instância Firebase do Clone Uber:
- **Project ID**: `clone-uber-app-c21a1`
- **Arquivo**: `firebase_options.dart` com credenciais para Web, Android, iOS, macOS, Windows, Linux

### Rotas da Aplicação

```
/splash    → SplashScreen (inicial)
/login     → DriverLoginScreen
/signup    → DriverSignupScreen
/dashboard → DriverDashboard
```

## 📱 Dependências Principais

- **firebase_core**: Inicialização e configuração do Firebase
- **firebase_auth**: Autenticação Firebase
- **cloud_firestore**: Banco de dados em tempo real
- **google_sign_in**: Login com Google
- **google_maps_flutter**: Maps (próximas fases)
- **geolocator**: Localização (próximas fases)
- **intl**: Formatação de data/hora

## 🔧 Instalação e Execução

### Pré-requisitos
- Flutter SDK 3.4.3+
- Firebase Project configurado
- Google Maps API Key (para próximas fases)

### Passos

```bash
# 1. Instalar dependências
cd apps/drivers_app
flutter pub get

# 2. (Opcional) Configurar emulador do Firebase
firebase emulators:start

# 3. Rodar em debug
flutter run

# 4. (Produção) Build Android
flutter build apk --release

# 5. (Produção) Build iOS
flutter build ios --release
```

## 📊 Fluxo de Navegação

```
App Start
    ↓
SplashScreen (3s delay)
    ↓
Auth Check → Autenticado? ✓ → Dashboard
                ✗ → Login
    ↓
DriverLoginScreen
├─ Email/Senha login → Dashboard
├─ Google login → Dashboard
└─ Signup link → DriverSignupScreen
    ↓
DriverSignupScreen
├─ Cadastro sucesso → Dashboard
└─ Link voltar → DriverLoginScreen
    ↓
Dashboard
├─ Toggle Online/Offline
├─ View Stats
├─ Logout → DriverLoginScreen
└─ (Próximas: Aceitar corridas, Ver mapa, etc)
```

## 🎯 Próximas Fases

### **Fase 2: Localização em Tempo Real** ⏳
- Solicitar permissão de localização
- Atualizar localização a cada 10-30 segundos
- Mostrar motorista no mapa em tempo real
- Integração com Google Maps

### **Fase 3: Aceitação de Corridas** ⏳
- QueryStream para buscar corridas disponíveis
- Notificações push quando corrida disponível
- Tela para aceitar/recusar corrida
- Status visual da corrida (pendente, em progresso, concluída)

### **Fase 4: Navegação e Rastreamento** ⏳
- Google Maps com rota até passageiro
- Google Maps com rota até destino
- Atualização de localização do motorista
- ETA em tempo real

### **Fase 5: Histórico e Avaliações** ⏳
- Tela com histórico de corridas
- Exibição de avaliações dos passageiros
- Relatório de ganhos por período
- Estatísticas do motorista

## 💡 Padrões Utilizados

### **Service Pattern**
```dart
// DriverAuthService encapsula toda lógica de autenticação
final _authService = DriverAuthService();
await _authService.signInWithEmail(email, password);
```

### **State Management com setState**
- Usado em telas simples (Login, Dashboard)
- Próximas fases: Provider para complexidade

### **Firestore Integration**
- Documentos de motorista em `drivers/{uid}`
- Campos denormalizados para queries rápidas
- Timestamps para auditoria

### **Error Handling**
```dart
try {
  await _authService.signInWithEmail(...);
} catch (e) {
  _showSnackBar('Erro: $e', isError: true);
}
```

### **Validação de Formulário**
```dart
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  },
)
```

## 🔐 Segurança

- ✅ Senhas armazenadas no Firebase Auth (hash SHA-256)
- ✅ Tokens JWT para API calls (Firebase)
- ✅ Firestore Security Rules (a implementar em próximas fases)
- ✅ Google Sign-In OAuth 2.0
- ✅ Variáveis de ambiente em `.env`

## 📝 Notas Importantes

1. **Firebase Emulator**: Em debug mode, auth local em `localhost:9099`
2. **Localização**: Requer permissões `android.permission.ACCESS_FINE_LOCATION`
3. **Mapa**: Requer Google Maps API Key válida
4. **iOS**: Requer configuração de Bundle ID

## 📧 Suporte

Para dúvidas ou problemas, consultar:
- Documentação Firebase: https://firebase.flutter.dev
- Documentação Flutter: https://flutter.dev/docs
- GitHub do projeto: https://github.com/vitorcf22/clone_uber_app
