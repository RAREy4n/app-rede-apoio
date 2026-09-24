import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuração centralizada do cliente Supabase.
///
/// Mantém as credenciais públicas (anon key) necessárias para a consulta
/// segura de pontos de apoio e guias informativos com Row Level Security (RLS).
class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = 'https://xozcsujnjzoinqhifgfm.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhvemNzdWpuanpvaW5xaGlmZ2ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAxOTgwNjYsImV4cCI6MjEwNTc3NDA2Nn0.iSqVKY9W0FYoEim4a2vDCsRD-oY4jRk_Ru_yHjwDQK8';

  static bool _initialized = false;

  /// Retorna se o cliente Supabase está inicializado e pronto para uso.
  static bool get isInitialized => _initialized;

  /// Inicializa o Supabase com tratamento de exceções.
  ///
  /// Garante que se o dispositivo estiver offline ou houver falha de rede/configuração,
  /// o aplicativo continue iniciando normalmente com os dados locais de fallback.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
        debug: kDebugMode,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Falha ao inicializar Supabase: $e. Operando em modo offline.');
      _initialized = false;
    }
  }

  /// Retorna a instância do cliente ou null se não inicializado.
  static SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
