# Plano de Ação - Fase 2: Mapa e Localização

O objetivo desta fase é implementar o mapa e a funcionalidade de localização do usuário, que são o coração do aplicativo.

## Checklist da Fase 2:

- [ ] **Adicionar Dependências de Mapa e Localização:**
  - [ ] Adicionar `google_maps_flutter` ao `pubspec.yaml`.
  - [ ] Adicionar `geolocator` ao `pubspec.yaml`.
  - [ ] Executar `flutter pub get`.

- [ ] **Configurar a Plataforma Android:**
  - [ ] Obter a chave da API do Google Maps no Google Cloud Console.
  - [ ] Adicionar a chave da API ao `android/app/src/main/AndroidManifest.xml`.
  - [ ] Garantir que as permissões de localização (`ACCESS_FINE_LOCATION`) estão no `AndroidManifest.xml`.

- [ ] **Configurar a Plataforma iOS:**
  - [ ] Adicionar a chave da API do Google Maps ao `ios/Runner/AppDelegate.swift`.
  - [ ] Adicionar as chaves de permissão de localização (`NSLocationWhenInUseUsageDescription`) ao `ios/Runner/Info.plist`.

- [ ] **Implementar a Tela do Mapa:**
  - [ ] Substituir o `Scaffold` atual da `HomeScreen` por um widget `GoogleMap`.
  - [ ] Definir uma posição inicial padrão para a câmera do mapa.

- [ ] **Implementar o Serviço de Localização:**
  - [ ] Criar uma classe `LocationService` para encapsular a lógica do `geolocator`.
  - [ ] Implementar um método para verificar e solicitar permissão de localização.
  - [ ] Implementar um método para obter a localização atual do usuário (`Position`).

- [ ] **Integrar Mapa e Localização:**
  - [ ] Na `HomeScreen`, ao inicializar, chamar o `LocationService` para obter a localização do usuário.
  - [ ] Animar a câmera do `GoogleMap` para a posição atual do usuário.
  - [ ] Adicionar um marcador (`Marker`) no mapa para indicar a localização do usuário.

- [ ] **Refatorar e Limpar:**
  - [ ] Garantir que a lógica de UI e a lógica de negócio (serviços) estão bem separadas.
  - [ ] Adicionar tratamento de erros para casos em que a permissão de localização é negada.
