import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/place_suggestion.dart';

class PlacesService {
  final String _cloudFunctionUrl =
      'https://placesautocomplete-hkl3mleujq-uc.a.run.app';

  Future<List<PlaceSuggestion>> getAutocompleteSuggestions(
      String input, Position? position) async {
    if (input.trim().isEmpty) {
      return [];
    }

    String urlString = '$_cloudFunctionUrl?input=$input';
    if (position != null) {
      urlString += '&lat=${position.latitude}&lng=${position.longitude}';
    }
    final url = Uri.parse(urlString);

    if (kDebugMode) print('DEBUG: Chamando a Cloud Function com a URL: $url');

    try {
      final response = await http.get(url);

      if (kDebugMode) {
        print('DEBUG: Resposta da Cloud Function - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final List predictions = data['predictions'];
          final suggestions = predictions
              .map((p) => PlaceSuggestion(p['place_id'], p['description']))
              .toList();
          if (kDebugMode) {
            print('DEBUG: ${suggestions.length} sugestões encontradas.');
          }
          return suggestions;
        } else {
          if (kDebugMode) {
            print('Erro da API Places (via Cloud Function): ${data['error_message']}');
          }
          return [];
        }
      } else {
        if (kDebugMode) {
          print(
              'Erro ao chamar a Cloud Function. Status: ${response.statusCode}, Body: ${response.body}');
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Exceção ao chamar a Cloud Function: $e');
      return [];
    }
  }
}
