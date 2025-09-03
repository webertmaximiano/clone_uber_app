# Plano de Ação - Fase 3: Gerenciamento de Corridas e Motoristas (App do Usuário)

O objetivo desta fase é implementar a funcionalidade principal de solicitação de corridas, exibição de motoristas no mapa e gerenciamento de estados de corrida para o aplicativo do usuário.

## Checklist da Fase 3:

- [x] **Configuração do Firestore:**
  - [x] Revisar e configurar as regras de segurança do Firestore para permitir leitura/escrita de dados de localização e corrida.
  - [x] Criar coleções iniciais no Firestore (ex: `drivers`, `rides`).

- [x] **Melhorias e Otimizações:**
  - [x] **[CONCLUÍDO]** Atualizar `google_maps_flutter` para usar `AdvancedMarkerElement` e resolver o aviso de depreciação do `Marker`.
  - [x] Otimizar o carregamento da API JavaScript do Google Maps no `index.html` com `loading=async`.

- [x] **Exibição de Motoristas no Mapa:**
  - [x] Criar um `DriverService` para gerenciar a obtenção de dados de motoristas do Firestore.
  - [x] Implementar a escuta em tempo real de motoristas próximos no Firestore.
  - [x] **Integração do `StreamBuilder` na `HomeScreen`:**
    - [x] Importar e instanciar o `DriverService` na `HomeScreen`.
    - [x] Envolver o `GoogleMap` com um widget `StreamBuilder`.
    - [x] Conectar o `stream` do `StreamBuilder` ao `driverService.getDriversStream()`.
  - [x] **Processamento e Exibição dos Marcadores:**
    - [x] No `builder` do `StreamBuilder`, iterar sobre os documentos de motoristas recebidos.
    - [x] Para cada motorista, extrair os dados de localização (latitude, longitude).
    - [x] Criar um `Marker` customizado para cada motorista.
    - [x] Atualizar o conjunto de marcadores (`_markers`) e redesenhar o mapa.

- [ ] **UI de Solicitação de Corrida:**
  - [x] Adicionar campos de entrada para origem e destino na `HomeScreen` ou em uma nova tela.
  - [x] Integrar a API de Geocoding (se não estiver já no `LocationService`) para converter endereços em coordenadas.
  - [ ] Adicionar um botão para "Solicitar Corrida".
  - [ ] Implementar autocompletar para campos de endereço (Google Places API).

- [ ] **Lógica de Solicitação de Corrida:**
  - [ ] Criar um `RideService` para gerenciar a criação e o estado das corridas no Firestore.
  - [ ] Implementar a lógica para criar um novo documento de corrida no Firestore com origem, destino, usuário e status.
  - [ ] Implementar a escuta em tempo real do status da corrida para o usuário.

- [ ] **Integração com a UI:**
  - [ ] Atualizar a `HomeScreen` para exibir a UI de solicitação de corrida.
  - [ ] Atualizar a UI com base no status da corrida (ex: "Procurando motorista", "Motorista a caminho").

- [ ] **Refatoração e Limpeza:**
  - [ ] Garantir que os novos serviços (`DriverService`, `RideService`) estejam bem separados.
  - [ ] Adicionar tratamento de erros robusto para operações do Firestore e de rede.