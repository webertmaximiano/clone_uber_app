# Tutorial: Admin Web Panel

Este documento detalha o passo a passo para o desenvolvimento do painel de administração do Clone Uber.

## Pré-requisitos

Antes de começar, certifique-se de que você configurou seu ambiente de desenvolvimento conforme descrito no [`README.md`](../README.md) principal do projeto.

---

## Fase 1: Estrutura e Configuração Inicial

### Passo 1: Configuração do Firebase

Nesta etapa, conectamos o painel ao Firebase.

*   **Navegue até `admin_web_panel/`:** Execute `cd admin_web_panel` no terminal.
*   **Configure o App com o FlutterFire:** Execute `flutterfire configure --project=clone-uber-app-c21a1`.
*   **Instale as Dependências:** Execute `flutter pub get`.

### Passo 2: Autenticação de Admin

Agora, vamos construir as telas e a lógica para que admins possam fazer login.

*   **Tela de Splash:** Criada em `lib/screens/authentication/splash_screen.dart`
*   **Tela de Login:** Criada em `lib/screens/authentication/login_screen.dart`
*   **Serviço de Autenticação:** Criado em `lib/services/admin_auth_service.dart`

### Passo 3: Dashboard Principal

*   **Dashboard Screen:** Criada em `lib/screens/dashboard/dashboard_screen.dart`
*   **Componentes:**
    - Barra superior (AppBar) com logout
    - Sidebar de navegação
    - Cards de estatísticas

---

## Próximos Passos

1. **Testar o Fluxo de Autenticação:**
   - Executar `flutter run -d chrome`
   - Tentar fazer login com credenciais admin

2. **Implementar Telas de Gerenciamento:**
   - Gerenciamento de Usuários
   - Gerenciamento de Motoristas
   - Monitoramento de Corridas
   - Gerenciamento de Pagamentos

3. **Integração com Firestore:**
   - Buscar dados em tempo real
   - Usar StreamBuilder para atualizações automáticas

4. **Refinement UI/UX:**
   - Design responsivo
   - Tabelas de dados
   - Gráficos de estatísticas

---

## Para Mais Informações

Consulte o `action_plan.md` na raiz do projeto para as próximas tarefas detalhadas.
