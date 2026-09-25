import '../../../core/config/app_config.dart';

/// Sessão de compartilhamento de localização ao vivo (RPC `location_share_start`).
class LocationShareSession {
  const LocationShareSession({
    required this.id,
    required this.publisherToken,
    required this.viewerToken,
    required this.expiresAt,
  });

  final String id;

  /// SECRETO: só o app usa, para enviar posição e encerrar. Nunca exibir nem enviar.
  final String publisherToken;

  /// Vai no link para a pessoa de confiança. Só permite ver a posição.
  final String viewerToken;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remaining {
    final r = expiresAt.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }

  /// Link para a página de acompanhamento. O token vai após o `#`.
  String viewerUrl([String base = AppConfig.trackingPageUrl]) => '$base#t=$viewerToken';

  factory LocationShareSession.fromJson(Map<String, dynamic> json) => LocationShareSession(
        id: json['share_id'].toString(),
        publisherToken: json['publisher_token'].toString(),
        viewerToken: json['viewer_token'].toString(),
        expiresAt: DateTime.parse(json['expires_at'].toString()).toLocal(),
      );
}

/// Estado do compartilhamento, para a interface reagir.
enum LocationShareStatus {
  /// Nenhum compartilhamento em andamento.
  inativo,

  /// Criando a sessão no servidor.
  iniciando,

  /// Ativo: enviando a posição periodicamente.
  ativo,

  /// Ativo, mas o último envio falhou (sem internet ou sem GPS). Continua tentando.
  instavel,

  /// Terminou (prazo ou encerramento manual).
  encerrado,

  /// Não foi possível iniciar.
  erro,
}
