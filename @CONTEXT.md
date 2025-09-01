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

### Fase 3: Gerenciamento de Corridas e Motoristas (App do Usuário)

*   **Objetivo:** Implementar a funcionalidade principal de solicitação de corridas, exibição de motoristas no mapa e gerenciamento de estados de corrida.
*   **Foco:**
    *   **Exibição de Motoristas:** Mostrar a localização de motoristas próximos no mapa em tempo real.
    *   **Solicitação de Corrida:** Permitir que o usuário solicite uma corrida, definindo origem e destino.
    *   **Comunicação em Tempo Real:** Utilizar o Cloud Firestore para atualizações de localização de motoristas e estados de corrida.
    *   **UI de Solicitação:** Desenvolver a interface para o usuário interagir com o processo de solicitação de corrida.
    *   **Autocompletar de Endereços:** Implementar busca com autocompletar para campos de origem/destino.
*   **Conquistas:**
    *   **Documentação:** Criado 'docs/firebase/firestore_data_model.md' explicando o modelo de dados do Firestore.
    *   **UI de Solicitação de Corrida:** Adicionados campos de entrada para origem e destino na `HomeScreen`.
    *   **Geocoding:** Integrada a API de Geocoding para converter endereços em coordenadas.
    *   **Autocompletar de Endereços:** Implementada a funcionalidade de autocompletar para campos de origem/destino usando a API do Google Places.
    *   **Serviço de Corrida:** Criado o `RideService` e implementada a lógica inicial para criar novas solicitações de corrida no Firestore.
    *   **Escuta de Status de Corrida:** Implementada a escuta em tempo real do status da corrida no Firestore para o usuário.
    *   **Integração da UI de Solicitação:** Atualizada a `HomeScreen` para exibir diferentes UIs com base no status da solicitação de corrida (inicial, solicitando, etc.).
    *   **Separação de Serviços:** Garantido que `DriverService` e `RideService` estão bem separados, seguindo o princípio de responsabilidade única.

### Fase 4: App do Motorista (Próxima Fase)

*   **Objetivo:** Desenvolver o aplicativo dedicado para motoristas, permitindo que eles aceitem corridas, naveguem e atualizem seu status.

## Próximos Passos (Gerenciados por `action_plan.md`)

As tarefas detalhadas para a Fase 3 serão gerenciadas no `action_plan.md`.
