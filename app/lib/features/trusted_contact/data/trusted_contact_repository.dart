import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/trusted_contact.dart';

/// Guarda a pessoa de confiança no armazenamento seguro do aparelho
/// (Keystore no Android, Keychain no iOS). Nada vai para o servidor.
///
/// Uso no front:
/// ```dart
/// final repo = TrustedContactRepository.instance;
/// final contato = TrustedContact.fromInput(name: nome, phone: telefone);
/// if (contato == null) { /* mostrar erro de validação */ }
/// await repo.salvar(contato!);
/// final salvo = await repo.carregar(); // null se não houver
/// await repo.remover();
/// ```
class TrustedContactRepository {
  TrustedContactRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static final instance = TrustedContactRepository();

  static const _chave = 'trusted_contact_v1';

  final FlutterSecureStorage _storage;

  Future<TrustedContact?> carregar() async {
    try {
      final texto = await _storage.read(key: _chave);
      if (texto == null) return null;
      return TrustedContact.fromJson(Map<String, dynamic>.from(jsonDecode(texto) as Map));
    } catch (e) {
      debugPrint('Não foi possível ler a pessoa de confiança: $e');
      return null;
    }
  }

  Future<void> salvar(TrustedContact contato) =>
      _storage.write(key: _chave, value: jsonEncode(contato.toJson()));

  Future<void> remover() => _storage.delete(key: _chave);
}
