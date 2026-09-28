# Plano de Ação — O que falta para concluir os apps

> **Atualizado em 2026-09-28** a partir de uma auditoria do código no commit `68cb75e`. Substitui o checklist antigo da Fase 3 (disponível no histórico do git).
>
> Os documentos de status da raiz (`FINAL_STATUS.md`, `CONCLUSAO.md`, `LISTA_COMPLETA_ENTREGAVEIS.md` etc.) dizem que o projeto está pronto. **O código mostra que não está.** Este arquivo é a referência do que falta.
>
> As referências de arquivo e linha valem para o commit `68cb75e`; reconfira antes de editar. Os erros de compilação foram encontrados lendo o código, porque o Flutter não estava disponível no ambiente da auditoria. Itens marcados **(confirmado)** foram verificados diretamente.

## Resumo
- **Nenhum dos três apps compila** como está no repositório.
- **As Cloud Functions não sobem:** o `index.js` usa a API v1 com `firebase-functions` 6.4.0, cujo import padrão é a v2.
- **Os apps usam nomes de campo diferentes para a mesma corrida.** Por isso o motorista nunca vê as corridas criadas pelo passageiro.
- **Não há regras do Firestore no repositório**, e qualquer conta Firebase entra no painel admin.

## Como usar
Siga as fases em ordem (0 → 5) e marque `[x]` ao concluir cada item. Antes de começar uma fase, resolva as decisões em aberto relacionadas a ela.

## Decisões em aberto
- Functions: trocar para `require("firebase-functions/v1")` (rápido) ou migrar para a API v2 (`onDocumentCreated`, `onSchedule`, `onCall`)? (Fase 0)
- Modelos compartilhados: pacote Dart local `packages/shared_models` via path dependency, ou monorepo com melos? (Fase 1)
- Máquina de estados da corrida: adicionar `arrived` (motorista chegou)? `accepted` ou `assigned`? (Fase 1)
- Preço: calcular no cliente ou numa Function (recomendado)? Moeda em centavos (`int`)? (Fases 1 e 2)
- Gateway de pagamento: Mercado Pago, Stripe ou Pagar.me (PIX + cartão), ou só dinheiro/mock no MVP? (Fase 5)
- `applicationId`/bundle id definitivos (hoje `com.example.*`).
- Destino dos ~30 `.md` da raiz (consolidar ou apagar).

## Fase 0 — Fazer compilar e publicar

### Passageiro (`apps/users_app`)
- [ ] `lib/services/ride_service.dart:15-17`: usa `rideRequest.origin/.originLat/.originLng`, que não existem no modelo. Trocar por `originAddress/originLatitude/originLongitude` **(confirmado)**.
- [ ] `ride_service.dart:114`: passa `Map?` para um parâmetro não-nulo.
- [ ] `home_screen.dart:355`: passa `LatLng` onde `places_service.dart:12` espera `Position?`.
- [ ] pubspec: adicionar `firebase_messaging`, `flutter_local_notifications`, `intl` e `uuid` (importados, mas não declarados). Remover `google_places_api_flutter` (declarado, sem uso).
- [ ] `notification_service.dart:92`: `DarwinInitializationSettings.onDidReceiveLocalNotification` foi removido nas versões novas do plugin.
- [ ] O `.env` é declarado como asset (`pubspec.yaml:83`), mas não existe no repo. Criar `.env.example`. Obs.: `.env` como asset embute a chave no APK/web. `location_service.dart:9` usa `dotenv.env[...]!` e quebra se a chave faltar.
- [ ] `web/index.html:33`: placeholder `%%GOOGLE_MAPS_WEB_API_KEY%%` não substituído.
- [ ] Android: permissão POST_NOTIFICATIONS, core library desugaring (flutter_local_notifications), `applicationId com.example.users_app`, release assinado com a chave de debug (`build.gradle:57`). A Maps key vem do `local.properties` (`build.gradle:50`).
- [ ] `test/widget_test.dart` é o teste padrão do contador e falha. Apagar ou substituir.

### Motorista (`apps/drivers_app`)
- [ ] `lib/services/available_rides_service.dart:92-95`: bloco `catch` duplicado depois do fim de `acceptRide`, que é erro de sintaxe **(confirmado)**.
- [ ] Não existem as pastas `android/`, `ios/` nem `web/` **(confirmado)**. Rodar `flutter create .` com a org correta e configurar o AndroidManifest (localização fina e em background, foreground service, notificações, Maps key).
- [ ] `lib/firebase_options.dart`: `currentPlatform` sempre devolve `web`, e `appId`/`messagingSenderId` são placeholders (`1:123456789:...`) **(confirmado)**. Regenerar com `flutterfire configure`.
- [ ] pubspec: adicionar `firebase_messaging` e `flutter_local_notifications` **(confirmado)**. `firebase_storage ^11.8.0` provavelmente é incompatível com `firebase_core ^4.0.0`.
- [ ] pubspec, dependências sem uso: `location`, `http`, `dio`, `material_design_icons_flutter`, `provider`, `shared_preferences`, `flutter_secure_storage`, `intl`, `cached_network_image`, `google_maps_flutter_platform_interface`, `latlong2`, `flutter_dotenv` e `connectivity_plus`. Manter `image_picker`/`firebase_storage` se forem usados no upload de documentos (Fase 4).
- [ ] `pubspec.yaml:68-70` declara `assets/images/` e `.env`, que não existem.
- [ ] `driver_dashboard.dart:166`: `Switch(inactiveColor:)` não é um parâmetro válido.
- [ ] `driver_notification_service.dart:91`: `onDidReceiveLocalNotification` foi removido. O som custom `'alert'` não existe. `dart:io` é importado sem uso (`:5`).
- [ ] `analysis_options.yaml` lista regras de lint inexistentes (ex.: `size_limits_sem_web`).
- [ ] Criar a pasta `test/`.

### Admin (`apps/admin_web_panel`)
- [ ] O pubspec declara `assets/images/` e `.env`, que não existem num clone limpo. `main.dart:15` carrega o `.env` no start.
- [ ] `lib/firebase_options.dart:74`: o bundle id iOS `com.example.usersApp` foi copiado do passageiro.
- [ ] Imports sem uso: `dashboard_screen.dart:3,5`, `splash_screen.dart:5-6` e `login_screen.dart:3`. Remover os 27 `print`. Remover `http` (e `mocktail`, se não houver testes).

### Cloud Functions (`functions/`)
- [ ] `firebase-functions` 6.4.0 exporta a API v2 na raiz, onde `functions.firestore.document` e `functions.pubsub.schedule` não existem **(confirmado)**. O `index.js` quebra ao carregar e **nenhuma** função é publicada, nem o `placesAutocomplete`.
- [ ] Versionar `firebase.json` e `.firebaserc` (tirar do `.gitignore`), e criar `firestore.rules`, `firestore.indexes.json` e `storage.rules` (nenhum existe no repo) **(confirmado)**.
- [ ] Criar `functions/.env.example` (`GOOGLE_API_KEY`).
- [ ] Rodar `npm run lint` nas functions.

## Fase 1 — Contrato de dados único

### Divergências na coleção `rides` (confirmado)
| Dado | Passageiro grava | Motorista lê | Admin lê |
|---|---|---|---|
| Destino | `destinationLatitude/Longitude` | `destinationLat/Lng`: descarta toda corrida sem esse campo, então **o motorista nunca vê as corridas do passageiro** | `destinationLatitude` ok |
| Origem | `originAddress`, `originLatitude/Longitude` | `origin`, `originLat/Lng` | `originAddress` ok |
| Preço | `estimatedFare` | `estimatedFare` ok | `fare` (mostra 0) |
| Distância | `estimatedDistance` | `estimatedDistance` ok | `distance` |
| Duração | `estimatedDurationMinutes` | — | `estimatedDuration` / `actualDuration` |
| Datas | `DateTime` (vira Timestamp) | `DateTime.now()` do cliente | `DateTime.parse(String)`, que dá TypeError |
| ID | campo `id` com um UUID diferente do doc ID (`ride_request_screen.dart:83,104`) | `doc.id` | `doc.id` |

As Functions leem `originLat/originLng` em `ride_notifications` e comparam `createdAt < Date` (esperam Timestamp).

### Divergências em `drivers/{uid}`
- **Posição:**
  - O cadastro grava `currentLatitude/currentLongitude`, e `available_rides_service.dart:189-193` grava `latitude/longitude`, só durante a ActiveRide.
  - O passageiro e as Functions leem `latitude/longitude`; o admin lê `currentLatitude/currentLongitude`.
  - O `updateLocation()` que grava os campos `current*` nunca é chamado.
- **`vehicleType`:** o motorista grava strings em PT (`'Carro Popular'|'Carro Confortável'|'SUV'|'Executivo'`), enquanto as corridas usam `economy|comfort|executive`.
- **Admin:** `totalEarnings` é tipado como `int` (`models/driver.dart:12,73`) e quebra com double.
- **Functions:** leem `uid`, mas o documento do motorista tem `id`.
- **Modelo morto:** o `models/driver.dart` do motorista usa nomes que não batem com o Firestore (`vehiclePlate`, `latitude`) e não é usado.

### `users/{uid}`
Nenhum app cria esse documento **(confirmado)**. Consequências:
- O `.update()` de `fcmToken` e de `walletBalance` falha.
- A lista de usuários do admin fica vazia.
- A `sendRideStatusNotification` nunca encontra o token.

### Status da corrida
- O passageiro usa `pending`, `assigned`, `in_progress`, `completed` e `cancelled`.
- O motorista grava `assigned`, `in_progress` e `completed`.
- O admin usa `pending`, `in_progress`, `completed` e `cancelled`. A consulta de corridas ativas exclui `assigned`, e `accepted` aparece só num comentário.
- Nenhum app tem `arrived`.

### Tarefas
- [ ] Criar modelos compartilhados (`Ride`, `Driver`, `AppUser`, `Payment`, `Rating` e o enum `RideStatus`) usados pelos três apps, com `fromFirestore`/`toFirestore` únicos.
- [ ] Datas: usar sempre `FieldValue.serverTimestamp()`/`Timestamp`.
- [ ] Posição do motorista num campo único: `GeoPoint` + geohash (ex.: `geoflutterfire_plus`).
- [ ] Valores em dinheiro com tipo consistente (de preferência centavos em `int`).
- [ ] Usar o doc ID como ID da corrida e remover o UUID.
- [ ] Criar `users/{uid}` no cadastro (e-mail e Google) com `name`, `phone`, `role` e `createdAt`.
- [ ] Mapear `vehicleType` ↔ `rideType`.
- [ ] Reescrever `docs/firebase/firestore_data_model.md` com o schema final.
- [ ] Criar os índices compostos em `firestore.indexes.json`:
  - `rides(userId, status, createdAt desc)`
  - `rides(status, createdAt)` para o admin
  - `rides(driverId, status)`
  - `ride_notifications(processed, createdAt desc)`
  - `notifications(sent, createdAt)`

## Fase 2 — Fluxo principal de ponta a ponta

### Passageiro
- [ ] Destino real: converter o `placeId` em coordenadas (Place Details). Hoje o destino é fixo em São Paulo, -23.5505,-46.6333 (`home_screen.dart:368-385`) **(confirmado)**.
- [ ] Autocomplete: aplicar URL-encode no texto digitado. A URL da Function está hardcoded (`places_service.dart:9,17`).
- [ ] Rota/polyline (Directions API), com distância e duração reais.
- [ ] Tarifa por tipo de carro. Hoje é `(5 + km*2.5) * {1.0|1.5|2.0}`, mas todos os cards mostram o mesmo preço (`ride_request_screen.dart:62-72, 234-235`).
- [ ] Motoristas no mapa:
  - usar um `MarkerId` por motorista (hoje todos usam `'currentLocation'`, `home_screen.dart:164-178`);
  - filtrar por online e proximidade (hoje o app faz stream da coleção `drivers` inteira, `driver_service.dart:13`).
- [ ] Tela do motorista atribuído: nome, foto, carro, placa, nota e tempo de chegada.
- [ ] Rastreamento ao vivo do motorista no mapa.
- [ ] Incluir `completed`/`cancelled` no stream da corrida:
  - hoje `ride_service.dart:66` exclui esses status e a tela congela **(confirmado)**;
  - ao concluir, abrir a RatingScreen, hoje inacessível (o `push` em `home_screen.dart:398` não é awaited e o resultado é ignorado).
- [ ] Cancelamento com `cancelledAt`, motivo e quem cancelou, usando o doc ID (`ride_tracking_screen.dart:240`).
- [ ] Avaliação: passar o `driverId` correto. A média do motorista deve ser calculada no servidor (hoje o cliente escreve em `drivers/{id}.rating`, `rating_service.dart:38-40`).
- [ ] Salvar o nome informado no cadastro (`signup_screen.dart:54`).
- [ ] O emulador de Auth é forçado em debug fora da web (`main.dart:24`). Tornar isso configurável.
- [ ] `_openPaymentAndRequestRide` nunca abre a tela de pagamento.

### Motorista
- [ ] O toggle online/offline deve ler o estado do Firestore (hoje `_isOnline` sempre começa `false`). Online liga o envio periódico de localização (com throttle) e a escuta de corridas; offline desliga tudo.
- [ ] Localização em background (foreground service no Android). Hoje só existe na ActiveRide, via `getPositionStream(distanceFilter: 10)` sem throttle (`active_ride_screen.dart:42-52`).
- [ ] Permissões de localização: `checkPermission`, `requestPermission` e `isLocationServiceEnabled` não aparecem em nenhum lugar.
- [ ] Remover o `driverId: 'motorista'` hardcoded (`main.dart:57-62`) e só iniciar o listener de `ride_notifications` após login e com o motorista online.
- [ ] O motorista não deve marcar `processed:true` (`ride_listener_service.dart:20-51`): isso consome a notificação para todos os motoristas.
- [ ] Aceitar a corrida numa **transação** com a pré-condição `status == 'pending' && driverId == null`. Hoje é um `update` simples, e dois motoristas podem aceitar a mesma corrida (`available_rides_service.dart:58-76`).
- [ ] Incrementar `totalRides` ao finalizar a corrida, não ao aceitar.
- [ ] A consulta de corridas disponíveis usa `where('driverId', isNull: true)`, que não encontra documentos sem esse campo.
- [ ] Depois de aceitar, ir para a ActiveRide. Hoje o app volta para a lista (`accept_ride_details_screen.dart:70`).
- [ ] Recusar corrida: `declineRide` está vazio (`available_rides_service.dart:200-207`).
- [ ] Navegação até o passageiro e o destino: polyline + botão para abrir Google Maps ou Waze.
- [ ] Status `arrived` antes de `in_progress`.
- [ ] Ao finalizar: calcular a tarifa final, atualizar `totalEarnings` e criar o registro em `payments`.
- [ ] Reagir ao cancelamento pelo passageiro. `DriverRideStatusListenerService` existe, mas não é usado.
- [ ] Permitir que o motorista cancele a corrida.
- [ ] Dashboard com ganhos, número de corridas e nota reais (hoje `'0'`, `'R$ 0,00'` e `'5.0'` hardcoded, `driver_dashboard.dart:134,191-214`) e histórico.
- [ ] Avaliar o passageiro.
- [ ] Onboarding após login com Google (hoje cria o motorista sem dados do veículo, `driver_auth_service.dart:115-133`).
- [ ] Perfil editável.
- [ ] Google Maps API key (não existe em lugar nenhum).
- [ ] O `GoogleMap` só aparece na ActiveRide, e `_mapController` nunca é usado.

### Notificações (passageiro e motorista)
- [ ] Salvar o token FCM depois do login. O motorista só salva no start, antes do login (`driver_notification_service.dart:118-121`); no passageiro falha porque `users/{uid}` não existe.
- [ ] Criar o background handler e implementar os handlers, que hoje são só comentários (`users_app notification_service.dart:199-252`, `drivers_app driver_notification_service.dart:223-239`).
- [ ] Apagar o token no logout.
- [ ] Criar uma Function para notificar o motorista: a `sendRideStatusNotification` só busca o token em `users`.
- [ ] Eliminar a duplicidade: o motorista escuta `ride_notifications` no cliente, e a Function `notifyNearbyDrivers` processa a mesma coleção.
- [ ] `notifyNearbyDrivers` depende de `latitude/longitude`, que o motorista parado nunca publica, e lê 100 motoristas para filtrar em memória. Trocar por uma consulta com geohash.
- [ ] Timeout de "nenhum motorista encontrado": Function agendada que cancela ou reoferece a corrida.

## Fase 3 — Segurança
- [ ] `firestore.rules`:
  - cada usuário só lê e escreve os próprios dados;
  - o motorista só atualiza a corrida atribuída a ele, e apenas nos campos e transições de status permitidos;
  - o cliente nunca altera `walletBalance`, `rating` nem `totalEarnings`;
  - o admin é identificado por custom claim.
- [ ] `storage.rules` para os documentos do motorista.
- [ ] Admin: custom claim `admin`, definida por Function ou script, checada no login e nas rules, com guard na rota `/dashboard` (`main.dart:53`). Hoje **qualquer conta Firebase entra**, inclusive a de um passageiro (`admin_auth_service.dart`, `splash_screen.dart:47-55`) **(confirmado)**.
- [ ] `placesAutocomplete` é um endpoint HTTP aberto e sem autenticação que gasta a cota da chave Google. Trocar por uma callable com autenticação, App Check e rate limit, e buscar os detalhes do lugar também no servidor.
- [ ] App Check nos três apps.
- [ ] Carteira e pagamentos só pelo servidor. Hoje o botão "Adicionar Saldo" incrementa `walletBalance` direto do cliente.
- [ ] Não mostrar exceções cruas na UI (ex.: `login_screen.dart:66` do admin).
- [ ] Revisar as restrições das API keys. As chaves do Firebase estão nos `firebase_options.dart`, o que é normal desde que restritas; a Maps key vai embutida no app via `.env` asset.

## Fase 4 — Admin completo
- [ ] Aprovar, rejeitar e bloquear motoristas. Os campos `documentVerified` e `isActive` são gravados no cadastro, mas nunca lidos. Motorista não aprovado não pode ficar online (checar no app e nas rules).
- [ ] Upload de CNH, CRLV e foto no app do motorista (`image_picker` + `firebase_storage`) e visualização no admin.
- [ ] Bloquear usuário (hoje só existe excluir). A exclusão de usuário ou motorista remove só o documento: a conta no Auth continua e as corridas ficam órfãs. Fazer isso por uma Function de admin.
- [ ] Filtro de status de usuários quebrado: o widget emite `'active'`/`'inactive'` (`advanced_filter_widget.dart:109,113`), mas a tela compara com `'Active'`/`'Inactive'` (`users_management_screen.dart:88-89`) **(confirmado)**.
- [ ] Monitor de corridas: os filtros "concluídas" e "canceladas" sempre voltam vazios, porque usam o stream das corridas ativas (`rides_monitoring_screen.dart:75-77`). A consulta de ativas deve incluir `assigned` (`ride_service.dart:71,125`).
- [ ] Mapa ao vivo de motoristas e corridas. Hoje é um stub "Funcionalidade em desenvolvimento" (`rides_monitoring_screen.dart:191-195`), e `getOnlineDriversStream` não é usado.
- [ ] Gráfico real de receita dos últimos 7 dias. Hoje só aparece um texto (`dashboard_screen.dart:301-327`). Além disso, `get7DayRevenue` (`ride_service.dart:172-182`) trata `createdAt` como Timestamp, enquanto o modelo Payment espera String.
- [ ] Os gráficos de pizza leem a coleção inteira e ignoram alguns status. Com total 0, mostram NaN% (`status_pie_chart.dart:78`).
- [ ] Paginação no servidor (`limit`/`startAfter`). Problemas atuais:
  - carrega as coleções inteiras;
  - o `sublist` dá RangeError em payments, na busca de motoristas (`:55-57`) e nos filtros de corridas (`:62-64`), porque a página não é resetada;
  - o botão "Próximo" de Payments está fixo em `_currentPage < 5` (`payments_management_screen.dart:278`);
  - os controles leem `_cachedFiltered*`, que fica desatualizado.
- [ ] Streams e futures criados dentro de `build()` (ex.: `drivers_management_screen.dart:65`, `dashboard_screen.dart:179-197`).
- [ ] Os filtros de nota e de data do advanced filter nunca são aplicados.
- [ ] Configuração de tarifas (base, por km, por minuto, multiplicador por tipo), usada no cálculo do preço.
- [ ] Reembolsos, exportação CSV e relatórios.
- [ ] Scaffold/AppBar duplicado nas telas de gestão.
- [ ] Os diálogos de exclusão checam o `mounted` do State, não o do contexto do diálogo.
- [ ] Código morto: usar ou apagar `widgets/pagination_widget.dart`, `bar_chart_widget.dart`, `revenue_line_chart.dart` e `models/admin_user.dart`. `web/dashboard-demo.html` e `web/dashboard-real.html` são páginas estáticas com números fixos.

## Fase 5 — Pagamento, histórico e qualidade
- [ ] Gateway de pagamento real (ver decisões em aberto), com webhook numa Function. Hoje o cartão é fixo (`'XXXX XXXX XXXX 1234'`, `payment_method_screen.dart:102`), o método escolhido é ignorado e `recordPayment` nunca é chamado.
- [ ] Histórico de corridas. No passageiro, hoje aparece só um SnackBar "Em desenvolvimento" (`home_screen.dart:288-290`), e `getUserRideHistory` não é usado. No motorista, não existe.
- [ ] Perfil do passageiro.
- [ ] Qualidade em todos os apps:
  - guardar e cancelar os `StreamSubscription` (não há nenhum `cancel()`, e a ActiveRide nem tem `dispose`);
  - checar `mounted` depois de cada `await` (há vários pontos nos três apps);
  - tirar streams de dentro de `build()` (`home_screen.dart:157`, `ride_tracking_screen.dart:68`, `payment_method_screen.dart:128`, `available_rides_screen.dart:97` e `active_ride_screen.dart:169`);
  - corrigir casts `as double?`, que quebram quando o valor vem como `int`;
  - trocar os `print` por logging;
  - apagar serviços e métodos mortos (`RideStatusListenerService`, `DriverRideStatusListenerService`, os `stopListening()` vazios, `updateDriverLocation`, `sendNotificationToUser` que só faz print, entre outros).
- [ ] Testes: unitários dos services (fake_cloud_firestore, mocktail), widget tests das telas principais e integração com o Firebase Emulator. Meta: 80% de cobertura.
- [ ] CI no GitHub Actions: `flutter analyze` e `flutter test` nos três apps, e `npm run lint` nas functions.
- [ ] Consolidar os `.md` da raiz e atualizar o `@CONTEXT.md` com o estado real.
