# Executando um App Flutter na Web

Quando você executa `flutter run` e escolhe `Chrome` como dispositivo, o Flutter compila a versão web do seu aplicativo e a serve localmente.

#### Porta de Execução

- **Porta Automática:** Por padrão, o Flutter procura uma porta de rede que esteja livre no seu computador e a utiliza. É por isso que o número da porta (como em `http://localhost:42321`) pode mudar a cada execução.

- **Especificando uma Porta:** Se você precisar usar uma porta específica (por exemplo, para configurar um proxy ou porque outra parte do seu sistema espera por isso), você pode usar a flag `--web-port`.

```bash
# Executa o app na web na porta 8080
flutter run -d chrome --web-port=8080
```

Isso lhe dá mais controle sobre o ambiente de desenvolvimento local.
