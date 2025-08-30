# Gerenciamento de Assets (Imagens, Fontes, etc.)

Assets são arquivos que são empacotados com seu aplicativo e acessados em tempo de execução (como imagens, fontes, vídeos, arquivos JSON, etc.).

#### 1. Declarando Assets no `pubspec.yaml`

Para que o Flutter saiba quais assets incluir no seu aplicativo, você precisa declará-los no arquivo `pubspec.yaml`, na seção `flutter:`. É uma boa prática declarar pastas inteiras.

```yaml
flutter:
  # ...
  assets:
    - assets/images/  # Declara que todos os arquivos nesta pasta serão assets
    # - assets/data/   # Exemplo: se você tivesse arquivos de dados JSON aqui
```

- **Importante:** A indentação é crucial no `pubspec.yaml`. Certifique-se de que `assets:` esteja alinhado com `uses-material-design:`, e a pasta (`- assets/images/`) esteja com dois espaços a mais.

#### 2. Acessando Assets no Código

Depois de declarar os assets no `pubspec.yaml` e executar `flutter pub get` (ou reiniciar o `flutter run`), você pode acessá-los no seu código.

- **Para imagens:** Use o widget `Image.asset()`.

```dart
Image.asset(
  'assets/images/google_logo.png', // Caminho completo para a imagem
  height: 24.0,
)
```

#### Por que é importante?

Declarar assets no `pubspec.yaml` permite que o Flutter otimize o empacotamento e o carregamento desses arquivos, garantindo que eles estejam disponíveis para o seu aplicativo quando necessário. Se um asset não for declarado, o Flutter não o incluirá no build final, e seu aplicativo não conseguirá encontrá-lo em tempo de execução, resultando em erros.