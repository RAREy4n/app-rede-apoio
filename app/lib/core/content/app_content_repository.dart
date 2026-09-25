import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import 'app_content.dart';

/// Carrega canais de emergência, categorias e guias (RPC `get_app_bootstrap`).
///
/// Estratégia para funcionar sem internet:
/// 1. tenta o servidor e, se der certo, salva no aparelho;
/// 2. sem servidor, usa a última versão salva;
/// 3. no primeiro uso sem internet, usa a versão embutida em
///    `assets/offline/bootstrap_curitiba.json`.
///
/// Uso no front:
/// ```dart
/// final conteudo = await AppContentRepository.instance.carregar();
/// conteudo.emergencyChannels; conteudo.guides; conteudo.filterGroups;
/// ```
class AppContentRepository {
  AppContentRepository._();

  static final instance = AppContentRepository._();

  static const assetEmbutido = 'assets/offline/bootstrap_curitiba.json';
  static const _chaveCache = 'app_content_cache_v1';

  AppContent? _emMemoria;

  /// Último conteúdo carregado nesta execução (útil para telas que não
  /// querem esperar a rede). `null` se [carregar] ainda não rodou.
  AppContent? get atual => _emMemoria;

  Future<AppContent> carregar({
    String estado = AppConfig.estadoPadrao,
    String cidade = AppConfig.cidadePadrao,
  }) async {
    final remoto = await _doServidor(estado, cidade);
    if (remoto != null) return _emMemoria = remoto;

    final salvo = await _doCache();
    if (salvo != null) return _emMemoria = salvo;

    return _emMemoria = await carregarEmbutido();
  }

  /// Versão embutida no app. Sempre funciona (não depende de rede).
  Future<AppContent> carregarEmbutido() async {
    final texto = await rootBundle.loadString(assetEmbutido);
    return AppContent.fromJson(
      Map<String, dynamic>.from(jsonDecode(texto) as Map),
      ContentOrigin.embutido,
    );
  }

  Future<AppContent?> _doServidor(String estado, String cidade) async {
    final client = SupabaseConfig.client;
    if (client == null) return null;
    try {
      final resposta = await client.rpc(
        'get_app_bootstrap',
        params: {'p_state': estado, 'p_city': cidade},
      ).timeout(const Duration(seconds: 8));
      if (resposta is! Map) return null;
      final json = Map<String, dynamic>.from(resposta);
      await _salvarCache(json);
      return AppContent.fromJson(json, ContentOrigin.servidor);
    } catch (e) {
      debugPrint('get_app_bootstrap falhou: $e');
      return null;
    }
  }

  Future<AppContent?> _doCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final texto = prefs.getString(_chaveCache);
      if (texto == null) return null;
      return AppContent.fromJson(
        Map<String, dynamic>.from(jsonDecode(texto) as Map),
        ContentOrigin.cache,
      );
    } catch (e) {
      debugPrint('Cache de conteúdo inválido: $e');
      return null;
    }
  }

  Future<void> _salvarCache(Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chaveCache, jsonEncode(json));
    } catch (e) {
      debugPrint('Não foi possível salvar o cache de conteúdo: $e');
    }
  }
}
