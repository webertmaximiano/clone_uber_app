# Uber Clone - Driver App

Aplicação mobile para motoristas da plataforma Clone Uber.

## Recursos

### Fase 1: Autenticação e Dashboard
- ✅ Autenticação com email/senha
- ✅ Autenticação com Google Sign-In
- ✅ Tela de Splash
- ✅ Dashboard do motorista
- ✅ Status online/offline
- ✅ Perfil do motorista

## Próximas Fases

- [ ] **Fase 2**: Localização em tempo real e mapa
- [ ] **Fase 3**: Aceitação de corridas
- [ ] **Fase 4**: Navegação e rastreamento
- [ ] **Fase 5**: Histórico de corridas e avaliações

## Estrutura do Projeto

```
lib/
├── main.dart                      # Entry point
├── firebase_options.dart          # Firebase configuration
├── services/
│   └── driver_auth_service.dart   # Authentication logic
├── screens/
│   ├── authentication/
│   │   ├── splash_screen.dart
│   │   ├── driver_login_screen.dart
│   │   └── driver_signup_screen.dart
│   └── dashboard/
│       └── driver_dashboard.dart
└── models/
    └── (upcoming)
```

## Dependências Principais

- **firebase_core**: Inicialização do Firebase
- **firebase_auth**: Autenticação
- **cloud_firestore**: Banco de dados em tempo real
- **google_maps_flutter**: Integração com Google Maps
- **geolocator**: Geolocalização
- **google_sign_in**: Login com Google

## Como Executar

```bash
# Instalar dependências
flutter pub get

# Rodar em debug (emulador ou dispositivo)
flutter run

# Build para produção (Android)
flutter build apk --release

# Build para produção (iOS)
flutter build ios --release
```

## Configuração do Firebase

O projeto utiliza a mesma instância Firebase do Clone Uber:
- Project ID: `clone-uber-app-c21a1`
- Autenticação com Email/Senha e Google

## Estrutura Firestore

```
drivers/
├── {driverId}/
│   ├── email
│   ├── name
│   ├── phoneNumber
│   ├── vehicleType
│   ├── licensePlate
│   ├── rating
│   ├── totalEarnings
│   ├── totalRides
│   ├── isOnline
│   ├── currentLatitude
│   ├── currentLongitude
│   ├── createdAt
│   └── lastActive
```

## Contribuidores

- Vítor Costa

## Licença

Proprietary - Clone Uber Project
