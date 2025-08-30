# Estrutura de Pastas em Projetos Flutter

O Flutter é flexível e **não impõe uma estrutura de pastas rígida** para o código que fica dentro da pasta `lib/`. No entanto, a comunidade adota alguns padrões para manter os projetos organizados e escaláveis.

As duas abordagens mais populares são:

#### 1. Agrupamento por Funcionalidade (Feature-first)

Neste padrão, você cria pastas para cada funcionalidade principal do seu aplicativo. Todo o código relacionado a uma feature (telas, widgets, lógica de estado, etc.) fica agrupado no mesmo lugar.

**Exemplo:**
```
/lib
|-- authentication/  # Tudo de autenticação aqui
|   |-- screens/
|   |   |-- login_screen.dart
|   |   `-- signup_screen.dart
|   |-- widgets/
|   |   `-- auth_button.dart
|   `-- services/
|       `-- auth_service.dart
|-- home/            # Tudo da tela principal aqui
|-- profile/         # Tudo do perfil do usuário aqui
```

- **Vantagem:** Excelente para escalabilidade e manutenção, pois encontrar e modificar uma funcionalidade completa é muito mais fácil. É o padrão mais recomendado para projetos médios e grandes.

#### 2. Agrupamento por Tipo (Layer-first)

Nesta abordagem, você agrupa os arquivos pelo que eles *são* tecnicamente.

**Exemplo:**
```
/lib
|-- screens/         # Todas as telas do app
|   |-- login_screen.dart
|   `-- home_screen.dart
|-- widgets/         # Todos os widgets reutilizáveis
|   |-- custom_button.dart
|   `-- user_avatar.dart
|-- models/          # Todas as classes de modelo de dados
|-- services/        # Toda a lógica de negócio e APIs
```

- **Vantagem:** Pode ser mais simples de entender para iniciantes e em projetos pequenos. 

#### Nossa Abordagem (Híbrida)

No nosso projeto, estamos usando uma abordagem híbrida, que é muito comum: separamos as `screens` (um tipo) e, dentro delas, agrupamos por `authentication` (uma funcionalidade). Isso nos dá um bom equilíbrio entre organização e simplicidade.
