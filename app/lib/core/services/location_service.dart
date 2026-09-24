import 'package:geolocator/geolocator.dart';

/// Serviço de localização responsável por obter coordenadas GPS.
///
/// Gerencia permissões, verifica disponibilidade do serviço de localização
/// e trata erros de GPS, bateria e permissões conforme exigido pelo projeto.
class LocationService {
  const LocationService._();

  /// Verifica se o serviço de localização está ativo e se as permissões
  /// foram concedidas. Retorna uma mensagem de erro ou `null` se tudo OK.
  static Future<String?> verificarPermissoes() async {
    try {
      // Verificar se o serviço de localização está ativo
      final servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) {
        return 'O serviço de localização está desligado. '
            'Ative-o nas configurações do dispositivo.';
      }

      // Verificar permissão
      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) {
          return 'A permissão de localização foi negada. '
              'Você pode permitir nas configurações.';
        }
      }

      if (permissao == LocationPermission.deniedForever) {
        return 'A permissão de localização foi bloqueada permanentemente. '
            'Acesse as configurações do aparelho para permitir.';
      }

      return null; // Tudo OK
    } catch (_) {
      return 'Serviço de localização indisponível.';
    }
  }

  /// Obtém a posição atual do dispositivo.
  ///
  /// Retorna `null` se não for possível obter a localização.
  /// Trata timeout e erros silenciosamente (o chamador deve oferecer
  /// alternativa à usuária).
  static Future<Position?> obterPosicaoAtual() async {
    final erro = await verificarPermissoes();
    if (erro != null) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      // Timeout, GPS indisponível, etc.
      return null;
    }
  }

  /// Gera a URL do Google Maps com as coordenadas fornecidas.
  static String gerarLinkMaps(double latitude, double longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }
}
