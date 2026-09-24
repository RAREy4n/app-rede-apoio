import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/supabase_config.dart';
import '../domain/models/support_institution.dart';

/// Serviço responsável pela busca de pontos de apoio no Supabase e ações de contato.
class SupportNetworkService {
  const SupportNetworkService._();

  /// Busca instituições próximas no Supabase.
  ///
  /// Se coordenadas forem fornecidas, executa a busca geoespacial via RPC `nearby_institutions`.
  /// Se estiver offline ou ocorrer falha de rede, retorna pontos de apoio de contingência.
  static Future<List<SupportInstitution>> buscarInstituicoes({
    double? lat,
    double? lng,
    String? category,
    int radiusMeters = 20000,
  }) async {
    final client = SupabaseConfig.client;

    if (client != null) {
      try {
        if (lat != null && lng != null) {
          // Busca geoespacial com PostGIS via RPC
          var response = await client.rpc(
            'nearby_institutions',
            params: {
              'lat': lat,
              'lng': lng,
              'radius_meters': radiusMeters,
              if (category != null && category.isNotEmpty) 'filter_category': category,
              'max_results': 30,
            },
          );

          // Se não houver instituições dentro do raio próximo (ex: usuária testando de outra cidade),
          // busca os pontos cadastrados ordenados pela menor distância real
          if (response is List && response.isEmpty) {
            response = await client.rpc(
              'nearby_institutions',
              params: {
                'lat': lat,
                'lng': lng,
                'radius_meters': 0,
                if (category != null && category.isNotEmpty) 'filter_category': category,
                'max_results': 30,
              },
            );
          }

          if (response is List && response.isNotEmpty) {
            return response
                .map((item) => SupportInstitution.fromSupabase(Map<String, dynamic>.from(item as Map)))
                .toList();
          }
        } else {
          // Busca sem localização precisa (lista geral ativa)
          var query = client.from('institutions').select().eq('is_active', true);
          if (category != null && category.isNotEmpty) {
            query = query.eq('category', category);
          }
          final response = await query.order('name');
          return response
              .map((item) => SupportInstitution.fromSupabase(item))
              .toList();
        }
      } catch (e) {
        debugPrint('Erro ao buscar instituições no Supabase: $e. Usando contingência local.');
      }
    }

    // Fallback offline garantido (Regra 1 e Regra 5: segurança sem internet)
    return obterInstituicoesContingencia(category);
  }

  /// Inicia discagem para o telefone da instituição.
  static Future<bool> ligar(String telefone) async {
    final sanitizado = telefone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: sanitizado);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Abre o aplicativo de mapas (Google Maps ou padrão) com a rota traçada.
  static Future<bool> abrirNoMapa({
    double? latitude,
    double? longitude,
    required String endereco,
  }) async {
    Uri uri;
    if (latitude != null && longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
      );
    } else {
      final query = Uri.encodeComponent(endereco);
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Pontos essenciais offline caso o usuário esteja sem conexão com a internet.
  static List<SupportInstitution> obterInstituicoesContingencia([String? categoryFilter]) {
    const lista = [
      SupportInstitution(
        id: 'deam-centro-offline',
        name: 'DEAM Centro — Delegacia da Mulher',
        category: 'delegacia_mulher',
        address: 'Rua Dr. Falcão Filho, 100 - Centro',
        city: 'São Paulo',
        state: 'SP',
        phone: '(11) 3101-1234',
        services: ['boletim_ocorrencia', 'medida_protetiva', 'acolhimento'],
        openingHours: {'seg': '24h', 'dom': '24h'},
      ),
      SupportInstitution(
        id: 'creas-centro-offline',
        name: 'CREAS Centro',
        category: 'creas',
        address: 'Rua Libero Badaró, 600 - Centro',
        city: 'São Paulo',
        state: 'SP',
        phone: '(11) 3104-5678',
        services: ['acolhimento', 'orientacao_juridica', 'atendimento_psicologico'],
        openingHours: {'seg': '08:00-17:00'},
      ),
      SupportInstitution(
        id: 'defensoria-offline',
        name: 'Defensoria Pública — Núcleo de Promoção e Defesa dos Direitos das Mulheres',
        category: 'defensoria',
        address: 'Rua Boa Vista, 200 - Centro',
        city: 'São Paulo',
        state: 'SP',
        phone: '(11) 3105-1234',
        services: ['orientacao_juridica', 'medida_protetiva'],
        openingHours: {'seg': '09:00-17:00'},
      ),
      SupportInstitution(
        id: 'crm-eliane-offline',
        name: 'Centro de Referência da Mulher — Casa Eliane de Grammont',
        category: 'centro_referencia',
        address: 'Rua Dr. Bittencourt Rodrigues, 200 - Sé',
        city: 'São Paulo',
        state: 'SP',
        phone: '(11) 3106-1234',
        services: ['atendimento_psicologico', 'orientacao_juridica'],
        openingHours: {'seg': '08:00-17:00'},
      ),
      SupportInstitution(
        id: 'hospital-carminio-offline',
        name: 'Hospital Municipal Dr. Cármino Caricchio',
        category: 'hospital',
        address: 'Av. Celso Garcia, 4815 - Tatuapé',
        city: 'São Paulo',
        state: 'SP',
        phone: '(11) 2799-0000',
        services: ['urgencia', 'atendimento_vitimas_violencia'],
        openingHours: {'seg': '24h', 'dom': '24h'},
      ),
    ];

    if (categoryFilter == null || categoryFilter.isEmpty) {
      return lista;
    }
    return lista.where((i) => i.category.toLowerCase() == categoryFilter.toLowerCase()).toList();
  }
}
