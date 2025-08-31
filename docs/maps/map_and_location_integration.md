# Integração de Mapa e Localização

Este documento detalha a implementação da Fase 2 do projeto, focada na exibição de mapas e na obtenção da localização do usuário.

## 1. Adição de Dependências

Para habilitar as funcionalidades de mapa e geolocalização, as seguintes dependências foram adicionadas ao `pubspec.yaml`:

-   `google_maps_flutter`: Pacote oficial do Flutter para integração com o Google Maps.
-   `geolocator`: Pacote para lidar com serviços de localização e permissões.

## 2. Configuração de Chaves de API

Para que o Google Maps funcione corretamente em diferentes plataformas, as chaves de API foram configuradas:

### Android

A chave de API do Google Maps foi adicionada ao `android/app/src/main/AndroidManifest.xml` dentro da tag `<application>`:

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="SUA_CHAVE_DE_API_AQUI"/>
```

As permissões de localização (`ACCESS_FINE_LOCATION`) também foram garantidas no `AndroidManifest.xml`.

### Web

Para a plataforma web, a chave de API do Google Maps JavaScript foi incluída diretamente no `users_app/web/index.html` dentro da seção `<head>`:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=SUA_CHAVE_DE_API_AQUI"></script>
```

**Importante:** A chave de API utilizada para o Google Maps é **diferente** da chave de API do Firebase para web. A chave do Google Maps foi configurada com restrições de aplicativo (Apps Android, Referenciadores HTTP) e restrições de API (Maps JavaScript API, Maps SDK for Android, etc.) para garantir a segurança.

## 3. Implementação do `LocationService`

Uma classe `LocationService` (`lib/services/location_service.dart`) foi criada para encapsular toda a lógica relacionada à localização:

-   **`handleLocationPermission()`**: Verifica e solicita permissões de localização ao usuário.
-   **`getCurrentLocation()`**: Obtém a posição atual do usuário, chamando `handleLocationPermission()` internamente e retornando um objeto `Position`.

## 4. Integração na `HomeScreen`

A `HomeScreen` (`lib/screens/home_screen.dart`) foi modificada para exibir o mapa e integrar o `LocationService`:

-   Um widget `GoogleMap` foi adicionado ao corpo da tela.
-   No `initState` da `HomeScreen`, o método `_getCurrentLocation()` é chamado.
-   `_getCurrentLocation()` utiliza o `LocationService` para obter a posição do usuário.
-   Se a localização for obtida com sucesso, a câmera do mapa é animada para a posição do usuário e um `Marker` é adicionado.
-   Um `SnackBar` é exibido caso a localização não possa ser obtida (ex: permissão negada).

## 5. Refatoração e Limpeza

A lógica de obtenção de localização e exibição no mapa foi separada em um serviço (`LocationService`), seguindo o princípio de Separação de Responsabilidades. O tratamento de erros para permissões de localização negadas foi adicionado na `HomeScreen` para feedback ao usuário.
