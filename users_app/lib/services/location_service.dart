import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Verifica e solicita permissões de localização.
  /// Retorna true se as permissões forem concedidas, false caso contrário.
  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Testar se os serviços de localização estão habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Serviços de localização desabilitados. Por favor, habilite-os.');
      // Opcional: Abrir configurações de localização para o usuário
      // Geolocator.openLocationSettings();
      return false;
    }

    // Verificar o status da permissão.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Se a permissão for negada, solicitar ao usuário.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permissão de localização negada. Não é possível obter a localização.');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print('Permissão de localização negada permanentemente. Por favor, habilite-a nas configurações do aplicativo.');
      // Opcional: Abrir configurações do aplicativo para o usuário
      // Geolocator.openAppSettings();
      return false;
    }

    // Permissão concedida.
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
}
