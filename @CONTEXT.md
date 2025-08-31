# Contexto do Projeto: Clone Uber com Flutter e Firebase

Este arquivo reflete o estado atual do nosso projeto e o progresso no tutorial.

## Visão Geral do Projeto

Estamos desenvolvendo um ecossistema de aplicativos (usuário, motorista e painel admin) com Flutter e Firebase. O foco atual é o `users_app`.

## Progresso do `users_app` (Aplicativo do Usuário)

### Fase 1: Configuração e Autenticação (Concluída)

*   **Objetivo:** Configurar o projeto Firebase e implementar o fluxo de autenticação de usuários.
*   **Conquistas:**
    *   Configuração inicial do Firebase e dependências essenciais.
    *   Estrutura de telas de autenticação (`splash`, `login`, `signup`).
    *   Fluxo de navegação entre telas de autenticação e `HomeScreen`.
    *   Lógica de autenticação com e-mail/senha e Google (refatorada para usar `AuthService` com `signInWithPopup` para web e `signInWithProvider` para mobile).
    *   Remoção da dependência `google_sign_in`.
    *   Documentação atualizada para refletir a nova arquitetura de autenticação.
    *   **Segurança:** Chaves de API do Google Cloud (Firebase Web e Google Maps) devidamente restritas.

### Fase 2: Mapa e Localização (Concluída)

*   **Objetivo:** Integrar o Google Maps e obter a localização do usuário.
*   **Conquistas:**
    *   Adição das dependências `google_maps_flutter` e `geolocator`.
    *   Configuração das chaves de API do Google Maps para Android e Web (`AndroidManifest.xml` e `index.html`).
    *   Implementação da `HomeScreen` com um mapa interativo.
    *   Criação do `LocationService` para gerenciar permissões e obter a localização atual.
    *   Integração do `LocationService` com a `HomeScreen` para centrar o mapa e adicionar um marcador na localização do usuário.
    *   Tratamento de erros para permissões de localização negadas.

### Fase 3: Gerenciamento de Corridas e Motoristas (Próxima Fase)

*   **Objetivo:** Implementar a funcionalidade principal de solicitação de corridas, exibição de motoristas no mapa e gerenciamento de estados de corrida.
*   **Foco:**
    *   **Exibição de Motoristas:** Mostrar a localização de motoristas próximos no mapa em tempo real.
    *   **Solicitação de Corrida:** Permitir que o usuário solicite uma corrida, definindo origem e destino.
    *   **Comunicação em Tempo Real:** Utilizar o Cloud Firestore para atualizações de localização de motoristas e estados de corrida.
    *   **UI de Solicitação:** Desenvolver a interface para o usuário interagir com o processo de solicitação de corrida.

## Próximos Passos (Gerenciados por `action_plan.md`)

As tarefas detalhadas para a Fase 3 serão gerenciadas no `action_plan.md`.
