import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  // Lê a chave de API do arquivo .env
  // O `!` garante que o valor não é nulo (nós o carregamos no main.dart).
  final String _googleApiKey = dotenv.env['GOOGLE_GEOCODING_API_KEY']!;

  /// Verifica e solicita permissões de localização.
  /// Retorna true se as permissões forem concedidas, false caso contrário.
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Testar se os serviços de localização estão habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Serviços de localização desabilitados. Por favor, habilite-os.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permissão de localização negada. Não é possível obter a localização.');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print('Permissão de localização negada permanentemente. Por favor, habilite-a nas configurações do aplicativo.');
      return false;
    }

    return true;
  }

  /// Obtém a localização atual do usuário.
  /// Retorna um objeto Position se a localização for obtida com sucesso, ou null em caso de erro.
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print('Erro ao obter a localização: $e');
      return null;
    }
  }

  /// Converte coordenadas (lat/lng) em um endereço de texto usando a API de Geocoding do Google.
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_googleApiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          // Retorna o primeiro e mais relevante endereço formatado.
          return data['results'][0]['formatted_address'];
        } else {
          print('Erro de Geocoding: ${data['status']} - ${data['error_message']}');
          return null;
        }
      } else {
        print('Erro na chamada HTTP para Geocoding: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exceção na chamada de Geocoding: $e');
      return null;
    }
  }
}
