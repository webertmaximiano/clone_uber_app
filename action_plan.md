# Plano de Ação - Fase 3: Gerenciamento de Corridas e Motoristas

O objetivo desta fase é implementar a funcionalidade principal de solicitação de corridas, exibição de motoristas no mapa e gerenciamento de estados de corrida.

## Checklist da Fase 3:

- [ ] **Configuração do Firestore:**
  - [ ] Revisar e configurar as regras de segurança do Firestore para permitir leitura/escrita de dados de localização e corrida.
  - [ ] Criar coleções iniciais no Firestore (ex: `drivers`, `rides`).

- [ ] **Exibição de Motoristas no Mapa:**
  - [ ] Criar um `DriverService` para gerenciar a obtenção de dados de motoristas do Firestore.
  - [ ] Implementar a escuta em tempo real de motoristas próximos no Firestore.
  - [ ] Adicionar marcadores para motoristas no mapa, atualizando suas posições em tempo real.

- [ ] **UI de Solicitação de Corrida:**
  - [ ] Adicionar campos de entrada para origem e destino na `HomeScreen` ou em uma nova tela.
  - [ ] Integrar a API de Geocoding (se não estiver já no `LocationService`) para converter endereços em coordenadas.
  - [ ] Adicionar um botão para "Solicitar Corrida".

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