# Entendendo CORS e o Padrão de Proxy com Cloud Functions

Este documento explica um dos conceitos de segurança mais importantes e comuns no desenvolvimento web: CORS (Cross-Origin Resource Sharing) e como resolvê-lo de forma profissional usando um servidor proxy, como uma Cloud Function do Firebase.

## O que é CORS?

**CORS** é um mecanismo de segurança implementado pelos navegadores web. Para entendê-lo, primeiro precisamos entender a **Política de Mesma Origem (Same-Origin Policy)**.

Por padrão, o navegador proíbe que uma página web carregada de uma **origem** (um domínio, como `http://meusite.com`) faça requisições (chamadas de API) para uma outra origem (como `https://api.google.com`). Isso é uma medida de segurança fundamental para proteger os usuários de scripts maliciosos.

O CORS é o mecanismo que permite que o servidor da segunda origem (ex: `api.google.com`) "relaxe" essa política, enviando cabeçalhos HTTP especiais (como `Access-Control-Allow-Origin: *`) que dizem ao navegador: "Ei, navegador, está tudo bem. Eu autorizo que outros sites façam requisições para mim."

### O Erro no Nosso Aplicativo

O erro que vimos, `blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present`, significa exatamente isso:
1.  Nosso app em `http://localhost` tentou fazer uma chamada para `https://maps.googleapis.com`.
2.  O servidor do Google **não** respondeu com o cabeçalho `Access-Control-Allow-Origin`.
3.  O **navegador**, ao ver a ausência desse cabeçalho, bloqueou a resposta e nos deu o erro de CORS, mesmo que a chamada à API pudesse ter sido válida.

Para algumas de suas APIs (como a Places API), o Google intencionalmente não envia o cabeçalho CORS para forçar os desenvolvedores a não chamá-las diretamente de código de cliente, o que seria inseguro para a chave de API.

## A Solução: O Padrão de Proxy

Se o cliente (navegador) não pode falar diretamente com o serviço de terceiro, nós criamos um intermediário seguro que pode. Esse intermediário é um **servidor proxy**.

O fluxo de comunicação muda para:

```
[App Flutter (Web)] ---> [Nosso Servidor Proxy] ---> [API do Google]
                                     <---                   <---
```

### Por que isso funciona?

1.  **O CORS não é um problema:** A chamada do nosso App Flutter agora é para o nosso próprio servidor proxy. Como (geralmente) eles estão na mesma origem ou em uma origem configurada para permitir a comunicação, o navegador não bloqueia a chamada.
2.  **A Segurança é Máxima:** A chamada do nosso proxy para a API do Google é uma comunicação de **servidor-para-servidor**. A política de CORS do navegador não se aplica aqui. Mais importante, nossa chave de API secreta fica guardada em segurança no nosso servidor e **nunca, jamais é enviada para o navegador do cliente**.

### Usando Cloud Functions como Nosso Proxy

Para projetos que já usam Firebase, as **Cloud Functions** são a maneira perfeita de implementar um proxy sem a necessidade de gerenciar um servidor completo.

Nós vamos criar uma **Função HTTP**, que é basicamente um pequeno pedaço de código (em JavaScript/TypeScript) que vive na nuvem do Google e tem uma URL pública. Quando nosso app Flutter chamar essa URL, a função executará nosso código:
1.  Receberá a busca do nosso app (ex: "hospital").
2.  Fará a chamada para a API do Google Places, adicionando a chave de API secreta (que fica armazenada de forma segura no ambiente da função).
3.  Retornará a resposta do Google de volta para o nosso app.

Esta abordagem não só resolve o problema do CORS, mas também implementa a arquitetura mais segura e profissional para lidar com chaves de API secretas.