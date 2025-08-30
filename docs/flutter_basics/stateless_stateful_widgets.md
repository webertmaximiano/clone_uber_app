# StatelessWidget vs. StatefulWidget

No Flutter, tudo é um widget, mas eles se dividem em duas categorias principais:

#### `StatelessWidget` (Widget Sem Estado)

- **O que é?** Um widget que **não pode mudar** sua aparência ou os dados que exibe depois de ser construído. Ele é "burro" e apenas exibe as informações que recebe.
- **Quando usar?** Para qualquer parte da interface que é estática. Pense em ícones, textos fixos, botões que sempre têm a mesma aparência, ou qualquer widget que apenas recebe dados e os exibe sem interagir com eles.
- **Exemplo:** Uma tela de "Sobre", um cartão de informações, o título de uma página.

#### `StatefulWidget` (Widget Com Estado)

- **O que é?** Um widget que **pode mudar** dinamicamente. Ele tem um objeto `State` associado que pode guardar dados (o "estado") e notificar o Flutter para redesenhar a tela quando esses dados mudam (usando o método `setState()`).
- **Quando usar?** Sempre que a interface precisar ser atualizada em resposta a uma interação do usuário ou a dados que chegam (de uma API, por exemplo).
- **Exemplo:**
    - **Formulários:** Como nas nossas telas de Login e Cadastro, onde precisamos armazenar o que o usuário digita.
    - **Animações:** O estado da animação (progresso, cor, tamanho) muda com o tempo.
    - **Checkboxes e Sliders:** O estado de "marcado" ou o valor do slider precisam ser armazenados.
    - **Qualquer tela que busca dados da internet:** Ela começa em um estado de "carregando" e depois muda para "dados recebidos" ou "erro".

Nós usamos `StatefulWidget` para `LoginScreen` e `SignupScreen` porque os `TextEditingController` e o que o usuário digita neles são um **estado** que precisa ser gerenciado pela tela.
