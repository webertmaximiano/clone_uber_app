# Otimizando a Busca de Endereços com a Places API

A funcionalidade de autocompletar endereços é essencial para uma boa experiência do usuário, mas uma implementação básica pode trazer resultados irrelevantes e custos desnecessários. Este documento detalha técnicas para otimizar as chamadas à API do Google Places, focando em relevância e economia.

## 1. Busca Relevante: Priorizando a Localização do Usuário

Por padrão, uma busca na Places API pode retornar resultados de qualquer lugar do mundo (ou do país, se restringido). Para um app de transporte, os resultados mais relevantes são sempre os que estão próximos ao usuário.

**Técnica: Location Biasing (Tendência de Localização)**

A API de Autocomplete permite que você forneça a localização atual do usuário (latitude e longitude) e um raio (em metros) para "influenciar" os resultados, sem restringi-los completamente. Lugares dentro dessa área terão maior prioridade.

**Implementação:**

1.  **App Cliente (Flutter):** Ao chamar a sua Cloud Function de busca, envie a localização atual do usuário (obtida pelo `geolocator`) como parâmetros na URL.
    ```dart
    // Exemplo em places_service.dart
    final lat = position.latitude;
    final lng = position.longitude;
    final url = '$_cloudFunctionUrl?input=$input&lat=$lat&lng=$lng';
    ```

2.  **Backend (Cloud Function):** Sua função deve receber os parâmetros `lat` e `lng` e adicioná-los à chamada para a API do Google.
    ```javascript
    // Exemplo em functions/index.js
    const lat = request.query.lat;
    const lng = request.query.lng;

    const params = {
      input: input,
      key: GOOGLE_API_KEY,
      language: "pt_BR",
      components: "country:br",
    };

    // Adiciona o location bias se as coordenadas forem fornecidas
    if (lat && lng) {
      params.location = `${lat},${lng}`;
      params.radius = 50000; // 50km de raio, por exemplo
    }
    ```

Isso garante que um "hospital" pesquisado em Lisboa retorne hospitais em Lisboa, e não no Porto.

## 2. Economia de Custos: Técnicas Essenciais

Conforme discutido no planejamento inicial, gerenciar os custos da API é crucial.

### Debouncing na Busca

*   **O que é:** Evita fazer uma chamada à API a cada tecla digitada. Em vez disso, aguarda uma pequena pausa do usuário (ex: 300-500ms) antes de enviar a requisição.
*   **Impacto:** Reduz drasticamente o número de chamadas. Uma busca por "Avenida da Liberdade" pode gerar 20 chamadas sem debounce e apenas 1 ou 2 com debounce.

### Session Tokens

*   **O que é:** A Google cobra o Autocomplete "por sessão". Uma sessão começa quando o usuário começa a digitar e termina quando ele seleciona um lugar. Ao usar `session tokens`, você agrupa várias chamadas de autocomplete em uma única sessão faturável.
*   **Implementação:**
    1.  Gere um `session token` (uma string aleatória, ex: UUID) no seu app Flutter quando o campo de busca ganhar foco.
    2.  Envie este mesmo token em todas as chamadas de autocomplete para a Cloud Function.
    3.  A Cloud Function repassa o token para a API do Google.
    4.  Quando o usuário seleciona um local, você faz uma chamada final para a API `Place Details` para obter as coordenadas, usando o mesmo `session token`. Isso "fecha" a sessão.
*   **Impacto:** Reduz significativamente os custos. Em vez de pagar por cada sugestão, você paga pela sessão de busca completa.

### Otimizar Chamadas de "Place Details"

*   **O que é:** A chamada para `Place Details` (para obter as coordenadas de um local selecionado) pode retornar dezenas de campos de dados (fotos, avaliações, horário de funcionamento, etc.). Cada grupo de dados tem um custo.
*   **Técnica:** Especifique **apenas** os campos que você precisa. Para traçar uma rota, você só precisa das coordenadas.
*   **Implementação:** Na chamada de `Place Details`, use o parâmetro `fields`.
    ```
    // Exemplo de chamada otimizada
    https://maps.googleapis.com/maps/api/place/details/json?place_id=...&key=...&sessiontoken=...&fields=geometry/location
    ```
*   **Impacto:** Custo muito menor por chamada de detalhes do local.

Ao combinar essas três técnicas, você garante uma busca de locais rápida, relevante e com o menor custo possível.
