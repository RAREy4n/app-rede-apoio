import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Representa um ponto de atendimento da rede de apoio (Delegacia, CRAS, CREAS, etc.).
class SupportInstitution {
  const SupportInstitution({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.address,
    required this.city,
    required this.state,
    this.zipCode,
    this.phone,
    this.phone2,
    this.email,
    this.website,
    this.openingHours,
    this.latitude,
    this.longitude,
    this.services = const [],
    this.verifiedAt,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final String address;
  final String city;
  final String state;
  final String? zipCode;
  final String? phone;
  final String? phone2;
  final String? email;
  final String? website;
  final Map<String, dynamic>? openingHours;
  final double? latitude;
  final double? longitude;
  final List<String> services;
  final DateTime? verifiedAt;
  final double? distanceKm;

  /// Nome amigável da categoria para exibição no aplicativo.
  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'delegacia_mulher':
      case 'delegacia':
        return 'Delegacia Especializada (DDM/DEAM)';
      case 'creas':
        return 'CREAS (Atendimento Especializado)';
      case 'cras':
        return 'CRAS (Assistência Social)';
      case 'defensoria':
      case 'defensoria_publica':
        return 'Defensoria Pública';
      case 'centro_referencia':
        return 'Centro de Referência da Mulher';
      case 'hospital':
      case 'upa':
        return 'Saúde / Emergência Médica';
      case 'ministerio_publico':
        return 'Ministério Público';
      default:
        return 'Rede de Proteção';
    }
  }

  /// Cor temática do tipo de instituição.
  Color get themeColor {
    switch (category.toLowerCase()) {
      case 'delegacia_mulher':
      case 'delegacia':
        return AppColors.pink;
      case 'defensoria':
      case 'defensoria_publica':
      case 'ministerio_publico':
        return AppColors.primary;
      case 'creas':
      case 'cras':
      case 'centro_referencia':
        return const Color(0xFF2E7D32); // Verde acolhimento
      case 'hospital':
      case 'upa':
        return AppColors.emergency;
      default:
        return AppColors.primary;
    }
  }

  /// Cor suave para fundos de ícone ou badges.
  Color get softThemeColor {
    switch (category.toLowerCase()) {
      case 'delegacia_mulher':
      case 'delegacia':
        return AppColors.pinkSoft;
      case 'defensoria':
      case 'defensoria_publica':
      case 'ministerio_publico':
        return AppColors.blueSoft;
      case 'creas':
      case 'cras':
      case 'centro_referencia':
        return const Color(0xFFE8F5E9);
      case 'hospital':
      case 'upa':
        return const Color(0xFFFFEBEE);
      default:
        return AppColors.blueSoft;
    }
  }

  /// Ícone representativo da instituição.
  IconData get icon {
    switch (category.toLowerCase()) {
      case 'delegacia_mulher':
      case 'delegacia':
        return Icons.local_police_rounded;
      case 'defensoria':
      case 'defensoria_publica':
      case 'ministerio_publico':
        return Icons.gavel_rounded;
      case 'creas':
      case 'cras':
      case 'centro_referencia':
        return Icons.favorite_rounded;
      case 'hospital':
      case 'upa':
        return Icons.local_hospital_rounded;
      default:
        return Icons.business_rounded;
    }
  }

  /// Indica se a instituição funciona 24 horas.
  bool get is24Hours {
    if (openingHours == null) return false;
    final seg = openingHours!['seg']?.toString().toLowerCase() ?? '';
    final dom = openingHours!['dom']?.toString().toLowerCase() ?? '';
    return seg.contains('24h') || dom.contains('24h');
  }

  /// Resumo legível do horário de funcionamento.
  String get formattedOpeningHours {
    if (is24Hours) return 'Atendimento 24 horas';
    if (openingHours != null && openingHours!.isNotEmpty) {
      final seg = openingHours!['seg']?.toString() ?? 'Consulte';
      return 'Seg a Sex: $seg';
    }
    return 'Horário comercial';
  }

  /// Formata a distância para exibição (ex: "450 m" ou "2.3 km").
  String? get formattedDistance {
    if (distanceKm == null) return null;
    if (distanceKm! < 1.0) {
      final metros = (distanceKm! * 1000).round();
      return '$metros m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  factory SupportInstitution.fromSupabase(Map<String, dynamic> json) {
    List<String> parsedServices = [];
    if (json['services'] != null) {
      if (json['services'] is List) {
        parsedServices = (json['services'] as List).map((e) => e.toString()).toList();
      }
    }

    Map<String, dynamic>? parsedHours;
    if (json['opening_hours'] != null && json['opening_hours'] is Map) {
      parsedHours = Map<String, dynamic>.from(json['opening_hours'] as Map);
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return SupportInstitution(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subcategory: json['subcategory']?.toString(),
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipCode: json['zip_code']?.toString(),
      phone: json['phone']?.toString(),
      phone2: json['phone2']?.toString(),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      openingHours: parsedHours,
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      services: parsedServices,
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at'].toString()) : null,
      distanceKm: parseDouble(json['distance_km']),
    );
  }
}
