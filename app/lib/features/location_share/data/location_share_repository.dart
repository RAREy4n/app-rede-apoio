import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../domain/location_share_session.dart';

/// Erro de compartilhamento com mensagem pronta para a usuária.
class LocationShareException implements Exception {
  const LocationShareException(this.codigo, this.mensagem);

  /// 'offline' | 'duracao_invalida' | 'limite_de_sessoes' | 'sessao_inexistente'
  /// | 'coordenada_invalida' | 'pagina_nao_configurada' | 'desconhecido'
  final String codigo;
  final String mensagem;

  @override
  String toString() => 'LocationShareException($codigo): $mensagem';
}

/// Chamadas às RPCs `location_share_*` do Supabase.
///
/// Para a interface, prefira o [LocationShareController], que já cuida do
/// GPS, do envio periódico e do encerramento.
class LocationShareRepository {
  const LocationShareRepository();

  static const instance = LocationShareRepository();

  SupabaseClient get _client {
    final c = SupabaseConfig.client;
    if (c == null) {
      throw const LocationShareException(
        'offline',
        'Sem conexão. Envie sua localização atual pelo WhatsApp ou SMS.',
      );
    }
    return c;
  }

  /// Cria a sessão. [durationMin] entre 5 e 60.
  /// [label] aparece na página de acompanhamento (ex.: "Ana"); evite nome completo.
  Future<LocationShareSession> iniciar({required int durationMin, String? label}) async {
    try {
      final resposta = await _client.rpc(
        'location_share_start',
        params: {'duration_min': durationMin, 'label': label},
      ).timeout(const Duration(seconds: 10));
      final linha = (resposta as List).first as Map;
      return LocationShareSession.fromJson(Map<String, dynamic>.from(linha));
    } catch (e) {
      throw _traduzir(e);
    }
  }

  /// Envia a posição atual. Retorna `false` quando a sessão já terminou
  /// (prazo ou encerrada): nesse caso o app deve parar de enviar.
  Future<bool> enviarPosicao({
    required LocationShareSession sessao,
    required double latitude,
    required double longitude,
    double? precisaoMetros,
  }) async {
    try {
      final resposta = await _client.rpc(
        'location_share_update',
        params: {
          'publisher_token': sessao.publisherToken,
          'lat': latitude,
          'lng': longitude,
          'accuracy_m': precisaoMetros,
        },
      ).timeout(const Duration(seconds: 10));
      final linha = (resposta as List).first as Map;
      return linha['active'] == true;
    } catch (e) {
      throw _traduzir(e);
    }
  }

  /// Encerra na hora e apaga a posição do servidor. Seguro chamar mais de uma vez.
  Future<void> encerrar(LocationShareSession sessao) async {
    try {
      await _client.rpc(
        'location_share_stop',
        params: {'publisher_token': sessao.publisherToken},
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw _traduzir(e);
    }
  }

  LocationShareException _traduzir(Object e) {
    if (e is LocationShareException) return e;
    final texto = e is PostgrestException ? e.message : e.toString();
    if (texto.contains('limite_de_sessoes')) {
      return const LocationShareException(
        'limite_de_sessoes',
        'Muitos compartilhamentos em pouco tempo. Tente de novo mais tarde ou envie sua localização atual.',
      );
    }
    if (texto.contains('duracao_invalida')) {
      return const LocationShareException('duracao_invalida', 'Escolha uma duração entre 5 e 60 minutos.');
    }
    if (texto.contains('sessao_inexistente')) {
      return const LocationShareException('sessao_inexistente', 'Este compartilhamento não existe mais.');
    }
    if (texto.contains('coordenada_invalida')) {
      return const LocationShareException('coordenada_invalida', 'Localização inválida recebida do GPS.');
    }
    if (e is! PostgrestException) {
      return const LocationShareException(
        'offline',
        'Sem conexão. Envie sua localização atual pelo WhatsApp ou SMS.',
      );
    }
    return LocationShareException('desconhecido', 'Não foi possível compartilhar agora. ($texto)');
  }
}
