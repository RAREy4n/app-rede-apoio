/// Normalização de texto para busca: minúsculas e sem acentos.
///
/// Espelha a função `public.f_normalize` do Supabase, para que a busca
/// offline (lista de contingência) se comporte igual à busca no servidor.
library;

const _acentos = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

/// Converte para minúsculas e remove acentos. Ex.: "Água Verde" -> "agua verde".
String normalizarTexto(String? texto) {
  if (texto == null || texto.isEmpty) return '';
  final minusculo = texto.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in minusculo.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_acentos[char] ?? char);
  }
  return buffer.toString();
}

/// Quebra a busca em termos normalizados, ignorando espaços extras.
List<String> termosDeBusca(String? texto) {
  return normalizarTexto(texto)
      .trim()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
}
