/// Configurações do app que não são segredo.
///
/// Valores que mudam por ambiente vêm de `--dart-define`, por exemplo:
/// `flutter run --dart-define=TRACKING_PAGE_URL=https://seusite.org/acompanhar`
class AppConfig {
  const AppConfig._();

  /// Localidade do piloto. Usada para pedir canais e guias da cidade.
  static const estadoPadrao = 'PR';
  static const cidadePadrao = 'Curitiba';

  /// Endereço da página web em que a pessoa de confiança acompanha a
  /// localização. O token vai depois do `#`, para não aparecer em logs:
  /// `https://seusite.org/acompanhar#t=<viewer_token>`.
  ///
  /// Enquanto estiver vazio, o compartilhamento ao vivo fica desativado
  /// (o app não pode enviar um link que não abre).
  static const trackingPageUrl = String.fromEnvironment('TRACKING_PAGE_URL');

  static bool get compartilhamentoAoVivoDisponivel => trackingPageUrl.isNotEmpty;

  /// Intervalo entre envios de posição durante o compartilhamento ao vivo.
  static const intervaloEnvioLocalizacao = Duration(seconds: 15);

  /// Durações oferecidas à usuária (minutos). O servidor aceita de 5 a 60.
  static const duracoesCompartilhamento = [15, 30, 60];
}
