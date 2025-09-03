# Boas Práticas de Gerenciamento de Chaves de API no Google Cloud

Este documento descreve as melhores práticas para gerenciar chaves de API em seus projetos do Google Cloud, focando em segurança, organização e controle de custos.

## O Princípio do Menor Privilégio

A regra mais importante no gerenciamento de chaves de API é o **Princípio do Menor Privilégio**. Isso significa que qualquer chave de API deve ter apenas o conjunto mínimo de permissões necessárias para executar sua tarefa específica, e nada mais.

Evite a todo custo criar uma "chave mestra" com acesso a dezenas de APIs e poucas restrições. Se essa chave for comprometida, o dano potencial (financeiro e de dados) é imenso.

## Estratégia Recomendada

Siga esta estratégia para garantir que suas chaves sejam seguras e gerenciáveis.

### 1. Uma Chave, Uma Finalidade

Crie chaves de API separadas para diferentes partes da sua aplicação que tenham requisitos de segurança distintos.

*   **Exemplo Prático (Nosso App):**
    *   **Chave para o Frontend (Web):** Uma chave para ser usada no lado do cliente, como no nosso arquivo `index.html` para carregar o mapa JavaScript. A restrição dela será de **Referenciador HTTP**.
    *   **Chave para o Backend (Serviços):** Uma chave separada para ser usada em chamadas de servidor para servidor, como nosso código Dart chamando a API de Geocoding. A restrição dela **não** será de Referenciador HTTP, mas sim por API.

### 2. Restrinja por API

Sempre restrinja uma chave para que ela só possa ser usada com as APIs para as quais foi designada.

*   **Como fazer no Google Cloud:**
    1.  Vá para "APIs e Serviços" > "Credenciais".
    2.  Clique para editar a chave de API desejada.
    3.  Na seção "Restrições de API", selecione "Restringir chave".
    4.  Na caixa de seleção, escolha apenas as APIs que esta chave precisa acessar (ex: "Geocoding API").
    5.  Salve.

### 3. Restrinja por Aplicativo

Esta é a restrição mais importante para prevenir o uso não autorizado.

*   **Como fazer no Google Cloud:**
    1.  Na mesma tela de edição da chave, vá para "Restrições de aplicativo".
    2.  Escolha o tipo de restrição correto para a finalidade da chave:
        *   **Referenciadores HTTP:** Use para chaves de frontend (lado do cliente/navegador). Adicione os domínios do seu site (ex: `seusite.com/*`, `localhost`).
        *   **Endereços IP:** Use para chaves de backend (lado do servidor). Adicione os endereços IP dos seus servidores de produção. Para desenvolvimento local, esta opção geralmente não é usada.
        *   **Apps Android/iOS:** Use para chaves que serão embutidas diretamente em aplicativos móveis nativos.
        *   **Nenhum:** Use esta opção com muito cuidado. É o que usamos para nossa chave de Geocoding em desenvolvimento local, mas a segurança é garantida pela **restrição de API**.

### 4. Use Nomes Descritivos

Nomear suas chaves de forma clara economiza muito tempo e evita confusão.

*   **Exemplo Ruim:** `API key 1`, `API key 2`
*   **Exemplo Bom:** `WebApp-MapsJS-Key-Prod`, `Backend-Geocoding-Key-Dev`

### 5. Monitore o Uso

O Google Cloud permite que você visualize o uso de cada chave de API. Verifique regularmente para identificar qualquer atividade inesperada que possa indicar um vazamento ou abuso da chave.

Seguindo essas práticas, você cria um ambiente muito mais seguro e profissional para seus projetos.