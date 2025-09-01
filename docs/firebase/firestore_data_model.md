# Firebase Firestore: Entendendo o Modelo de Dados

O Cloud Firestore é um banco de dados NoSQL baseado em documentos, otimizado para o desenvolvimento de aplicativos móveis e web. Diferente dos bancos de dados relacionais (SQL) que usam tabelas, linhas e colunas, o Firestore organiza os dados em coleções e documentos.

## Conceitos Fundamentais

### 1. Documentos (Documents)

*   Um **documento** é a unidade básica de armazenamento no Firestore.
*   Ele é uma coleção de pares chave-valor, semelhante a um objeto JSON.
*   Os documentos podem conter diversos tipos de dados, como strings, números, booleanos, arrays, mapas (objetos aninhados) e até mesmo referências a outros documentos.
*   Cada documento possui um ID único. Você pode deixar o Firestore gerar um ID automaticamente ou especificar um ID personalizado.

**Exemplo de Documento (usuário):**

```json
// Documento com ID: "user_abc123"
{
  "name": "João Silva",
  "email": "joao.silva@example.com",
  "phone": "+5511987654321",
  "address": {
    "street": "Rua Exemplo",
    "number": "123",
    "city": "São Paulo"
  },
  "createdAt": "2025-08-31T10:00:00Z"
}
```

### 2. Coleções (Collections)

*   Uma **coleção** é um contêiner para documentos.
*   Todos os documentos em uma coleção devem ter uma estrutura lógica semelhante, embora o Firestore não imponha um esquema rígido (schema-less).
*   Coleções não podem conter diretamente outros documentos; elas contêm apenas documentos.
*   Você pode ter várias coleções em seu banco de dados.

**Exemplo de Coleções no nosso Projeto Uber:**

*   `users`: Coleção para armazenar documentos de usuários.
*   `drivers`: Coleção para armazenar documentos de motoristas.
*   `rides`: Coleção para armazenar documentos de corridas.

### 3. Subcoleções (Subcollections)

*   Dentro de um documento, você pode ter **subcoleções**.
*   Isso permite organizar dados hierarquicamente. Uma subcoleção é uma coleção aninhada dentro de um documento.
*   É uma forma poderosa de modelar relacionamentos "um para muitos" ou dados relacionados a um documento específico.

**Exemplo de Subcoleção (histórico de corridas de um usuário):**

```
/users/{user_id}/rides_history/{ride_id}
```

Neste exemplo:
*   `users` é uma coleção.
*   `{user_id}` é um documento dentro da coleção `users`.
*   `rides_history` é uma **subcoleção** dentro do documento `{user_id}`.
*   `{ride_id}` é um documento dentro da subcoleção `rides_history`.

## Como o Firebase Funciona (com foco no Firestore)

O Firebase é uma plataforma de desenvolvimento de aplicativos que oferece diversos serviços backend. O Firestore é um desses serviços, atuando como o banco de dados principal para a maioria dos aplicativos Firebase.

1.  **SDKs Cliente:** O Firebase fornece SDKs (kits de desenvolvimento de software) para diversas plataformas (Flutter/Dart, Android/Kotlin, iOS/Swift, Web/JavaScript, etc.). Esses SDKs permitem que seu aplicativo cliente se conecte diretamente ao Firestore sem a necessidade de um servidor intermediário.

2.  **Sincronização em Tempo Real:** Uma das características mais poderosas do Firestore é a sincronização em tempo real. Quando você "escuta" uma coleção ou documento, o Firestore envia automaticamente atualizações para o seu aplicativo sempre que os dados mudam no servidor. Isso é ideal para aplicativos como o nosso clone do Uber, onde a localização de motoristas e o status da corrida precisam ser atualizados instantaneamente.

3.  **Consultas (Queries):** Você pode consultar documentos em coleções com base em campos específicos, ordenar resultados, limitar o número de documentos e muito mais.

4.  **Regras de Segurança:** Como vimos, as regras de segurança do Firestore são executadas no servidor e garantem que apenas operações autorizadas sejam realizadas no seu banco de dados. Elas são essenciais para proteger seus dados.

5.  **Offline Support:** O Firestore armazena em cache os dados que seu aplicativo está usando. Isso significa que seu aplicativo pode ler, gravar, consultar e até mesmo ouvir dados enquanto estiver offline. Quando a conexão é restabelecida, o Firestore sincroniza automaticamente as alterações pendentes.

## Estrutura de Coleções Iniciais para o Nosso Projeto

Para o nosso projeto, as coleções iniciais que precisaremos criar (ou que serão criadas automaticamente quando o primeiro documento for adicionado) são:

*   **`drivers`**: Para armazenar informações sobre os motoristas, incluindo sua localização atual.
    *   Exemplo de documento:
        ```json
        // drivers/{driver_id}
        {
          "name": "Motorista Exemplo",
          "email": "motorista@example.com",
          "latitude": -23.550520,
          "longitude": -46.633308,
          "isOnline": true,
          "carDetails": {
            "model": "Fiat Uno",
            "plate": "ABC-1234"
          }
        }
        ```
*   **`rides`**: Para armazenar informações sobre as corridas solicitadas pelos usuários.
    *   Exemplo de documento:
        ```json
        // rides/{ride_id}
        {
          "userId": "user_abc123",
          "driverId": "driver_xyz789",
          "pickupLocation": {
            "latitude": -23.550520,
            "longitude": -46.633308,
            "address": "Av. Paulista, 1000"
          },
          "destinationLocation": {
            "latitude": -23.561356,
            "longitude": -46.656058,
            "address": "Rua da Consolação, 2000"
          },
          "status": "pending", // pending, accepted, in_progress, completed, cancelled
          "fare": 25.50,
          "timestamp": "2025-08-31T10:30:00Z"
        }
        ```

Compreender essa estrutura é fundamental para interagir com o Firestore de forma eficiente e segura em seu aplicativo.
