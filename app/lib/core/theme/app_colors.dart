import 'package:flutter/material.dart';

abstract final class AppColors {
  // Cores principais
  static const pink = Color(0xFFCA3B75);
  static const primary = Color(0xFF1A4DAD);

  // Cores suaves
  static const pinkSoft = Color(0xFFFAE3ED);
  static const blueSoft = Color(0xFFE3F0FF);

  // Fundo e superfície
  static const background = Color(0xFFFFF9FB);
  static const surface = Colors.white;

  // Texto
  static const textPrimary = Color(0xFF1F2433);
  static const textSecondary = Color(0xFF545C6D);
  static const textHint = Color(0xFF9BA3B0);

  // Borda
  static const border = Color(0xFFE0E0E8);

  // Emergência
  static const emergency = Color(0xFFC62828);

  // Sombra
  static const shadow = Color(0x0F1F2433);
  static const shadowMedium = Color(0x1A1F2433);

  // Legado (compatibilidade)
  static const primaryDark = Color(0xFF123879);
}
