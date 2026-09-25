/// Pessoa de confiança cadastrada pela usuária.
///
/// Fica salva SOMENTE no aparelho (criptografada). Nunca é enviada ao servidor.
class TrustedContact {
  const TrustedContact({required this.name, required this.phone});

  /// Como a usuária chama a pessoa (ex.: "Mãe"). Não precisa ser o nome completo.
  final String name;

  /// Telefone só com dígitos, no formato internacional (ex.: '5541999998888').
  final String phone;

  /// Cria a partir do que a usuária digitou. Retorna `null` se o telefone
  /// não for um número brasileiro válido (DDD + 8 ou 9 dígitos).
  static TrustedContact? fromInput({required String name, required String phone}) {
    final nome = name.trim();
    final numero = normalizarTelefoneBr(phone);
    if (nome.length < 2 || numero == null) return null;
    return TrustedContact(name: nome, phone: numero);
  }

  /// Converte "(41) 99999-8888", "041999998888" ou "+55 41 99999-8888"
  /// em "5541999998888". Retorna `null` se não for um número válido.
  static String? normalizarTelefoneBr(String entrada) {
    var digitos = entrada.replaceAll(RegExp(r'\D'), '');
    if (digitos.startsWith('55') && (digitos.length == 12 || digitos.length == 13)) {
      digitos = digitos.substring(2);
    }
    if (digitos.startsWith('0')) digitos = digitos.substring(1);
    if (digitos.length != 10 && digitos.length != 11) return null;
    if (digitos.startsWith('0') || digitos[2] == '0') return null;
    return '55$digitos';
  }

  /// Número para o link do WhatsApp (wa.me/<numero>).
  String get whatsappNumber => phone;

  /// Número para SMS/discador, com '+'.
  String get dialNumber => '+$phone';

  /// Exibição amigável: "(41) 99999-8888".
  String get formattedPhone {
    final local = phone.startsWith('55') ? phone.substring(2) : phone;
    final ddd = local.substring(0, 2);
    final resto = local.substring(2);
    final corte = resto.length - 4;
    return '($ddd) ${resto.substring(0, corte)}-${resto.substring(corte)}';
  }

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};

  factory TrustedContact.fromJson(Map<String, dynamic> json) =>
      TrustedContact(name: json['name'].toString(), phone: json['phone'].toString());
}
