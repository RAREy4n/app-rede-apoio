import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'location_service.dart';

/// Serviço para compartilhar localização via WhatsApp ou SMS.
///
/// O app prepara a mensagem com link do Google Maps e abre o WhatsApp
/// ou SMS. O envio final é confirmado pela usuária no próprio app de
/// mensagens — o Rede de Apoio não controla o envio.
class ShareLocationService {
  const ShareLocationService._();

  /// Envia a localização atual via WhatsApp para o número informado.
  ///
  /// [telefone] deve estar no formato internacional sem '+' (ex: '5511999998888').
  /// [nomeContato] é usado apenas para personalizar a mensagem.
  ///
  /// Retorna um [ShareResult] indicando o resultado da operação.
  static Future<ShareResult> enviarViaWhatsApp({
    required String telefone,
    String? nomeContato,
    required BuildContext context,
  }) async {
    final posicao = await LocationService.obterPosicaoAtual();

    if (posicao == null) {
      return ShareResult.semLocalizacao;
    }

    final linkMaps = LocationService.gerarLinkMaps(
      posicao.latitude,
      posicao.longitude,
    );

    final mensagem = _montarMensagem(linkMaps);
    final mensagemCodificada = Uri.encodeComponent(mensagem);

    // Tentar abrir WhatsApp com número específico
    final whatsappUri = Uri.parse(
      'https://wa.me/$telefone?text=$mensagemCodificada',
    );

    try {
      if (await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
        return ShareResult.sucesso;
      }
    } catch (_) {
      // WhatsApp não disponível, tentar fallback
    }

    return ShareResult.whatsappIndisponivel;
  }

  /// Envia a localização atual via SMS para o número informado.
  ///
  /// Usado como fallback quando o WhatsApp não está disponível.
  static Future<ShareResult> enviarViaSMS({
    required String telefone,
  }) async {
    final posicao = await LocationService.obterPosicaoAtual();

    if (posicao == null) {
      return ShareResult.semLocalizacao;
    }

    final linkMaps = LocationService.gerarLinkMaps(
      posicao.latitude,
      posicao.longitude,
    );

    final mensagem = _montarMensagem(linkMaps);
    final mensagemCodificada = Uri.encodeComponent(mensagem);

    final smsUri = Uri.parse('sms:$telefone?body=$mensagemCodificada');

    try {
      if (await launchUrl(smsUri)) {
        return ShareResult.sucesso;
      }
    } catch (_) {
      // SMS não disponível
    }

    return ShareResult.falhaGeral;
  }

  /// Tenta enviar via WhatsApp; se indisponível, tenta SMS.
  static Future<ShareResult> enviarComFallback({
    required String telefone,
    String? nomeContato,
    required BuildContext context,
  }) async {
    final resultado = await enviarViaWhatsApp(
      telefone: telefone,
      nomeContato: nomeContato,
      context: context,
    );

    if (resultado == ShareResult.whatsappIndisponivel) {
      return enviarViaSMS(telefone: telefone);
    }

    return resultado;
  }

  /// Abre o WhatsApp sem número definido (seletor de contatos).
  ///
  /// Útil quando não há contato de confiança cadastrado.
  static Future<ShareResult> enviarParaQualquerContato() async {
    final posicao = await LocationService.obterPosicaoAtual();

    if (posicao == null) {
      return ShareResult.semLocalizacao;
    }

    final linkMaps = LocationService.gerarLinkMaps(
      posicao.latitude,
      posicao.longitude,
    );

    final mensagem = _montarMensagem(linkMaps);
    final mensagemCodificada = Uri.encodeComponent(mensagem);

    final whatsappUri = Uri.parse(
      'https://wa.me/?text=$mensagemCodificada',
    );

    try {
      if (await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
        return ShareResult.sucesso;
      }
    } catch (_) {
      // WhatsApp não disponível
    }

    return ShareResult.whatsappIndisponivel;
  }

  static String _montarMensagem(String linkMaps) {
    return 'Preciso de ajuda. Minha localização atual:\n$linkMaps';
  }
}

/// Resultado da tentativa de compartilhamento.
enum ShareResult {
  /// Mensagem preparada e app de envio foi aberto.
  sucesso,

  /// Não foi possível obter a localização (GPS, permissão ou timeout).
  semLocalizacao,

  /// WhatsApp não instalado ou não pode ser aberto.
  whatsappIndisponivel,

  /// Nenhum meio de envio disponível.
  falhaGeral,
}
