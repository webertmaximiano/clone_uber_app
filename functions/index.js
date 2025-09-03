require("dotenv").config();

const functions = require("firebase-functions");
const axios = require("axios");
const cors = require("cors")({origin: true});

// Acessa a variável de ambiente de forma segura a partir do process.env
const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY;

exports.placesAutocomplete = functions.https.onRequest((request, response) => {
  // Habilita o CORS para permitir chamadas do app web.
  cors(request, response, async () => {
    // Pega o texto de busca dos parâmetros da query (ex: ?input=hospital)
    const input = request.query.input;
    const lat = request.query.lat;
    const lng = request.query.lng;

    if (!input) {
      functions.logger.warn("O parâmetro 'input' não foi fornecido.");
      response.status(400).send("O parâmetro 'input' é obrigatório.");
      return;
    }

    const url = `https://maps.googleapis.com/maps/api/place/autocomplete/json`;

    const params = {
      input: input,
      key: GOOGLE_API_KEY,
      language: "pt_BR",
      components: "country:br",
    };

    // Adiciona o location bias se as coordenadas forem fornecidas
    if (lat && lng) {
      params.location = `${lat},${lng}`;
      params.radius = 10000; // 10km de raio
    }

    try {
      const res = await axios.get(url, {params: params});
      functions.logger.info("Resposta da API do Google recebida com sucesso.");
      response.status(200).send(res.data);
    } catch (error) {
      functions.logger.error("Erro ao chamar a API do Google Places:", error);
      if (error.response) {
        // A requisição foi feita e o servidor respondeu com um erro
        response.status(error.response.status).send(error.response.data);
      } else if (error.request) {
        // A requisição foi feita mas nenhuma resposta foi recebida
        response.status(500).send("Nenhuma resposta da API do Google.");
      } else {
        // Erro na configuração da requisição
        response.status(500).send("Erro ao configurar a requisição.");
      }
    }
  });
});
