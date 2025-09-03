# Context the Project: Clone Uber com Flutter e Firebase

I. O Que Vamos Produzir (O Produto Final)
O nosso objetivo é criar uma Aplicação Flutter para o Passageiro com os seguintes módulos principais:

Módulo de Autenticação:

Ecrã de boas-vindas com opções de login/registo.

Fluxo de registo com E-mail e Senha.

Fluxo de login com E-mail e Senha.

Integração com "Sign in with Google" para um login rápido e fácil.

Gestão de perfil do utilizador (nome, foto, etc.).

Módulo Principal / Mapa:

Ecrã principal com um mapa interativo.

Visualização da localização atual do utilizador em tempo real (ponto de origem).

Campo de pesquisa para o destino.

Funcionalidade de "autocomplete" na busca de destinos, que sugere lugares à medida que o utilizador digita.

Desenho da rota no mapa entre a origem e o destino.

Módulo de Pedido e Cálculo da Corrida:

Estimação do preço e da duração da viagem com base na rota.

Seleção do método de pagamento.

Botão para confirmar o pedido da corrida.

Módulo de Pagamento:

Sistema de "carteira" ou créditos dentro da app.

Integração com o Mercado Pago para adicionar créditos à carteira usando cartão de crédito.

Lógica para fazer a pré-autorização do pagamento no momento do pedido.

Módulo de Acompanhamento da Corrida:

Ecrã de espera enquanto procura um motorista.

Lógica para lidar com o aceite do motorista.

Lógica de cancelamento da corrida pelo passageiro, com estorno do valor pré-autorizado.

II. O Que Vamos Precisar (Recursos e Ferramentas)
Tecnologias Base:

Flutter & Dart: Para construir a aplicação para Android e iOS com uma única base de código.

Visual Studio Code: O nosso ambiente de desenvolvimento.

Git & GitHub: Para controlo de versão do nosso código.

Backend (A "Nuvem"):

Uma aplicação como esta precisa obrigatoriamente de um backend. Ele será o cérebro que guarda os dados dos utilizadores, informações das corridas, etc.

Recomendação forte: Firebase (da Google). É perfeito para começar, pois oferece:

Firebase Authentication: Para cuidar de todo o login (e-mail/senha e Google) de forma segura.

Cloud Firestore: Uma base de dados em tempo real para guardar informações de utilizadores e corridas.

Cloud Functions: Para executar lógica segura no servidor (ex: calcular o preço da corrida, processar pagamentos).

Pacotes Flutter Essenciais (Plugins):

Maps_flutter: Para exibir os mapas.

geolocator ou location: Para obter a localização GPS do utilizador.

firebase_core, firebase_auth, cloud_firestore: Para integrar com o Firebase.

google_sign_in: Para o login com Google.

http ou dio: Para fazer chamadas a APIs (como a do Mercado Pago).

mercado_pago_sdk (ou similar): Para a integração de pagamentos.

provider ou flutter_bloc: Para gestão de estado, essencial para manter a app organizada.

III. APIs Essenciais que Precisamos Adquirir
Terás de criar contas de programador nestas plataformas. A maioria tem um nível gratuito generoso.

Google Maps Platform: É o coração da nossa aplicação. Precisarás de ativar as seguintes APIs na Google Cloud Console:

Maps SDK for Android e Maps SDK for iOS: Para mostrar o mapa na app.

Places API: A API mais importante para a "busca inteligente". Ela fornece o autocomplete de locais.

Directions API: Para traçar a rota no mapa do ponto A ao B.

Distance Matrix API: Para obter a distância e o tempo estimado de viagem, que são cruciais para calcular o preço.

Firebase: Como mencionado, será o nosso backend. A criação de um projeto é gratuita.

Mercado Pago API: Precisarás de criar uma conta de programador no Mercado Pago para obter as tuas credenciais de API e processar os pagamentos.

IV. Como Reduzir Gastos Desnecessários com APIs (Ponto Crítico!)
Esta é uma preocupação muito inteligente e importante. Os custos com APIs, especialmente a do Google Maps, podem escalar rapidamente se não forem geridos.

Estratégias para Google Maps:

Debouncing na Busca: Esta é a técnica mais importante! Não chames a Places API a cada tecla que o utilizador digita. Espera que ele faça uma pequena pausa (ex: 300 milissegundos) antes de fazer a chamada. Isto reduz o número de chamadas de 20 para 2 ou 3 por busca.

Uso de Session Tokens: A Places API Autocomplete cobra por sessão, não por chamada, se usares "session tokens". Basicamente, tu dizes à Google: "todas estas chamadas de autocomplete fazem parte da mesma busca do utilizador". No final, quando o utilizador escolhe um local, fazes uma chamada final de "Place Details" com o mesmo token. Isto reduz drasticamente o custo da busca.

Otimizar Chamadas de "Place Details": Quando fores buscar os detalhes de um local (como as coordenadas), especifica na chamada da API apenas os campos que precisas (geometry/location). Não peças fotos, reviews, etc., pois isso custa mais caro.

Limitar a Frequência de Atualização do GPS: Não precisas de atualizar a posição do utilizador no mapa 10 vezes por segundo. Uma vez a cada poucos segundos é mais do que suficiente e economiza bateria e dados.

Estratégias para Firebase:

Aproveitar o Nível Gratuito: O Firebase tem um nível gratuito muito generoso. Podes desenvolver e até lançar a aplicação para um número limitado de utilizadores sem pagar nada.

Otimizar Leituras da Base de Dados: O Firestore cobra principalmente por leituras e escritas. Estrutura os teus dados e as tuas consultas para ler apenas o mínimo necessário. Evita carregar listas enormes de dados de uma só vez.

Estratégia Geral:

Criar Alertas de Orçamento: Tanto na Google Cloud Platform como no Firebase, configura alertas de orçamento. P

## Visão Geral do Projeto

Estamos desenvolvendo um ecossistema de aplicativos (usuário, motorista e painel admin) com Flutter e Firebase. O foco atual é o `users_app`.

## Progresso do `users_app` (Aplicativo do Usuário)

### Fase 1: Configuração e Autenticação (COMPLETA)

*   **Configuração Inicial do Firebase:**
    *   Projeto Firebase criado (`clone-uber-app-c21a1`).
    *   CLI do FlutterFire instalada e configurada (`flutterfire configure`).
    *   Dependências essenciais do Firebase adicionadas (`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`).
    *   Firebase inicializado em `main.dart` e conectado ao emulador de autenticação (condicionalmente para web).
*   **Estrutura de Telas de Autenticação:**
    *   Diretórios `lib/screens/authentication/` e `lib/screens/` criados.
    *   `splash_screen.dart`, `login_screen.dart`, `signup_screen.dart` criados.
    *   `home_screen.dart` (placeholder) criado.
*   **Fluxo de Navegação:**
    *   `SplashScreen` redireciona para `LoginScreen` ou `HomeScreen` com base no estado de autenticação (`authStateChanges`), com correção para widget desmontado.
    *   Navegação entre `LoginScreen` e `SignupScreen` implementada.
    *   Redirecionamento para `HomeScreen` após login/cadastro bem-sucedido.
*   **Lógica de Autenticação:**
    *   Validação de formulário implementada em `SignupScreen` e `LoginScreen`.
    *   Cadastro de usuário com e-mail/senha (`createUserWithEmailAndPassword`) implementado em `SignupScreen`.
    *   Login de usuário com e-mail/senha (`signInWithEmailAndPassword`) implementado em `LoginScreen`.
    *   Login com Google (`signInWithGoogle`) implementado em `LoginScreen` (com `clientId` e ajuste para não usar emulador na web).
    *   Logout implementado na `HomeScreen`.
    *   Dados do usuário (nome) armazenados no Cloud Firestore após o cadastro.
*   **Assets:**
    *   Diretório `assets/images/` criado e configurado em `pubspec.yaml`.
    *   `google_logo.png` colocado manualmente pelo usuário em `users_app/assets/images/`.
*   **Testes de Autenticação:**
    *   Cadastro com e-mail/senha testado e funcionando.
    *   Login com e-mail/senha testado e funcionando.
    *   Login com Google testado e funcionando.
    *   Redirecionamento da `SplashScreen` para `LoginScreen` ou `HomeScreen` verificado e funcionando.
*   **Correções Adicionais:**
    *   Meta tag deprecated em `index.html` corrigida.

## Documentação Adicional (NOVA ESTRUTURA)

*   `README.md` (raiz do projeto) criado e atualizado.
*   `users_app/TUTORIAL.md` atualizado para apontar para a nova estrutura `docs/`.
*   **Nova estrutura `docs/` criada e populada com conteúdo migrado:**
    *   `docs/project_structure/project_structure.md`
    *   `docs/flutter_basics/stateless_stateful_widgets.md`
    *   `docs/navigation/navigation_basics.md`
    *   `docs/development_environment/web_run.md`
    *   `docs/forms/form_validation.md`
    *   `docs/async_programming/async_await_futures.md`
    *   `docs/firebase/authentication.md`
    *   `docs/assets/asset_management.md`
    *   `docs/login/login_flow.md`
    *   `docs/signup/signup_flow.md`
    *   `docs/user_stories/` (diretório criado, aguardando conteúdo)

## Próximos Passos (Gerenciados por `action_plan.md`)

A partir de agora, as tarefas detalhadas serão gerenciadas no `action_plan.md`. criando um historico com checklist

Aqui vamos manter apenas o contexto atualizado 