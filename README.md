# Clone Uber com Flutter e Firebase

Bem-vindo ao projeto Clone Uber! Este repositório contém o código-fonte para um ecossistema completo de aplicativos (usuário, motorista e painel admin) construído com Flutter e Firebase.

Este documento é o guia central do projeto. A partir daqui, você pode navegar para os tutoriais específicos de cada aplicativo.

## Visão Geral do Projeto

O objetivo é replicar a funcionalidade principal do Uber, criando três aplicações distintas que se comunicam através do Firebase:

1.  **App do Usuário (`users_app`):** Permite que passageiros solicitem corridas.
2.  **App do Motorista (`drivers_app`):** Permite que motoristas aceitem e gerenciem corridas.
3.  **Painel Admin (`admin_web`):** Uma aplicação web para administrar a plataforma.

## Estrutura do Monorepo

Este projeto utiliza uma abordagem de monorepo, onde cada aplicativo reside em sua própria pasta dentro do diretório raiz:

```
/clone_uber/
|-- README.md (Você está aqui)
|-- GEMINI.md (Guia mestre para o assistente Gemini)
|-- users_app/
|   `-- TUTORIAL.md (Guia passo a passo para o app do usuário)
|-- drivers_app/
`-- admin_web/
```

**Importante:** Todos os comandos específicos de um aplicativo (como `flutter run` ou `flutter pub add`) devem ser executados **de dentro do diretório correspondente**.

## Pré-requisitos e Ambiente (Linux/Ubuntu)

Este tutorial foi desenvolvido e testado em um ambiente **Linux (Ubuntu)**. Os seguintes pré-requisitos são necessários:

1.  **Flutter SDK:** [Instruções de instalação](https://docs.flutter.dev/get-started/install/linux)
2.  **Visual Studio Code** ou **Android Studio**
3.  **Git** para controle de versão.
4.  **CLI do Firebase** e **FlutterFire:** A configuração será detalhada no tutorial de cada app.

## Tutoriais Passo a Passo

O desenvolvimento de cada aplicativo é detalhado em seu próprio arquivo de tutorial.

*   **Fase 1:** [Tutorial do Aplicativo do Usuário](./users_app/TUTORIAL.md)
*   **Fase 2:** Tutorial do Aplicativo do Motorista (em breve)
*   **Fase 3:** Tutorial do Painel Admin (em breve)
