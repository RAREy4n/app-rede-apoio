/// Modelos do conteúdo que o app recebe da RPC `get_app_bootstrap`:
/// canais de emergência, categorias de instituições e guias de direitos.
library;

DateTime? _data(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

String? _texto(dynamic v) {
  final t = v?.toString().trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// Telefone oficial de emergência ou orientação (190, 180, 192, 153...).
class EmergencyChannel {
  const EmergencyChannel({
    required this.id,
    required this.name,
    required this.description,
    this.phone,
    this.whatsapp,
    this.whenToUse,
    this.kind = 'orientacao',
    this.scope = 'nacional',
    this.state,
    this.city,
    this.is24h = false,
    this.sortOrder = 100,
    this.sourceName,
    this.sourceUrl,
    this.verifiedAt,
  });

  final String id;
  final String name;
  final String description;

  /// Número para abrir no discador (ex.: '190').
  final String? phone;

  /// Número de WhatsApp só com dígitos e DDI (ex.: '556196100180').
  final String? whatsapp;
  final String? whenToUse;

  /// 'emergencia' | 'orientacao' | 'saude' | 'protecao'.
  final String kind;

  /// 'nacional' | 'estadual' | 'municipal'.
  final String scope;
  final String? state;
  final String? city;
  final bool is24h;
  final int sortOrder;
  final String? sourceName;
  final String? sourceUrl;
  final DateTime? verifiedAt;

  bool get isEmergency => kind == 'emergencia';

  factory EmergencyChannel.fromJson(Map<String, dynamic> json) => EmergencyChannel(
        id: json['id'].toString(),
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        phone: _texto(json['phone']),
        whatsapp: _texto(json['whatsapp']),
        whenToUse: _texto(json['when_to_use']),
        kind: json['kind']?.toString() ?? 'orientacao',
        scope: json['scope']?.toString() ?? 'nacional',
        state: _texto(json['state']),
        city: _texto(json['city']),
        is24h: json['is_24h'] == true,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 100,
        sourceName: _texto(json['source_name']),
        sourceUrl: _texto(json['source_url']),
        verifiedAt: _data(json['verified_at']),
      );
}

/// Categoria de instituição e o chip de filtro a que pertence.
class InstitutionCategory {
  const InstitutionCategory({
    required this.id,
    required this.label,
    required this.filterGroup,
    required this.filterGroupLabel,
    required this.iconKey,
    this.description,
    this.sortOrder = 100,
  });

  /// Igual a `SupportInstitution.category` (ex.: 'delegacia_mulher').
  final String id;
  final String label;
  final String? description;

  /// Grupo do chip de filtro (ex.: 'delegacias', 'acolhimento', 'juridico', 'saude').
  final String filterGroup;
  final String filterGroupLabel;

  /// Nome lógico do ícone: 'police' | 'heart' | 'law' | 'health'.
  final String iconKey;
  final int sortOrder;

  factory InstitutionCategory.fromJson(Map<String, dynamic> json) => InstitutionCategory(
        id: json['id'].toString(),
        label: json['label']?.toString() ?? '',
        description: _texto(json['description']),
        filterGroup: json['filter_group']?.toString() ?? '',
        filterGroupLabel: json['filter_group_label']?.toString() ?? '',
        iconKey: json['icon_key']?.toString() ?? '',
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 100,
      );
}

/// Guia de orientação e direitos. `content` está em Markdown.
class Guide {
  const Guide({
    required this.slug,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    this.icon,
    this.priority = 0,
    this.sourceName,
    this.sourceUrl,
    this.reviewedAt,
    this.updatedAt,
  });

  final String slug;
  final String title;
  final String summary;
  final String content;

  /// 'emergencia' | 'direitos' | 'seguranca' | 'financeiro' | ...
  final String category;
  final String? icon;
  final int priority;
  final String? sourceName;
  final String? sourceUrl;

  /// Data da revisão por profissional da rede. `null` = aguardando revisão.
  final DateTime? reviewedAt;
  final DateTime? updatedAt;

  bool get isReviewed => reviewedAt != null;

  factory Guide.fromJson(Map<String, dynamic> json) => Guide(
        slug: json['slug'].toString(),
        title: json['title']?.toString() ?? '',
        summary: json['summary']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        icon: _texto(json['icon']),
        priority: (json['priority'] as num?)?.toInt() ?? 0,
        sourceName: _texto(json['source_name']),
        sourceUrl: _texto(json['source_url']),
        reviewedAt: _data(json['reviewed_at']),
        updatedAt: _data(json['updated_at']),
      );
}

/// De onde veio o conteúdo carregado.
enum ContentOrigin {
  /// Baixado agora do Supabase.
  servidor,

  /// Última versão baixada, salva no aparelho.
  cache,

  /// Versão embutida no app (assets/offline), usada no primeiro uso sem internet.
  embutido,
}

/// Pacote completo retornado por `get_app_bootstrap`.
class AppContent {
  const AppContent({
    required this.contentVersion,
    required this.emergencyChannels,
    required this.institutionCategories,
    required this.guides,
    required this.origin,
  });

  final String contentVersion;
  final List<EmergencyChannel> emergencyChannels;
  final List<InstitutionCategory> institutionCategories;
  final List<Guide> guides;
  final ContentOrigin origin;

  /// Canal de emergência principal (190), se existir.
  EmergencyChannel? get primaryEmergency {
    for (final c in emergencyChannels) {
      if (c.isEmergency) return c;
    }
    return null;
  }

  Guide? guideBySlug(String slug) {
    for (final g in guides) {
      if (g.slug == slug) return g;
    }
    return null;
  }

  /// Chips de filtro na ordem certa: id do grupo -> rótulo.
  Map<String, String> get filterGroups {
    final grupos = <String, String>{};
    for (final c in institutionCategories) {
      grupos.putIfAbsent(c.filterGroup, () => c.filterGroupLabel);
    }
    return grupos;
  }

  /// Categorias do banco que pertencem a um chip de filtro.
  List<String> categoriesOfGroup(String group) =>
      institutionCategories.where((c) => c.filterGroup == group).map((c) => c.id).toList();

  factory AppContent.fromJson(Map<String, dynamic> json, ContentOrigin origin) {
    List<T> lista<T>(String chave, T Function(Map<String, dynamic>) conv) {
      final bruto = json[chave];
      if (bruto is! List) return <T>[];
      return bruto.map((e) => conv(Map<String, dynamic>.from(e as Map))).toList();
    }

    return AppContent(
      contentVersion: json['content_version']?.toString() ?? '',
      emergencyChannels: lista('emergency_channels', EmergencyChannel.fromJson)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      institutionCategories: lista('institution_categories', InstitutionCategory.fromJson)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      guides: lista('guides', Guide.fromJson)
        ..sort((a, b) => b.priority.compareTo(a.priority)),
      origin: origin,
    );
  }
}
