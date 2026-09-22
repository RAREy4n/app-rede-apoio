import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Card de ação reutilizável para navegação e canais de apoio.
///
/// Exibe ícone, título, descrição e seta de navegação.
/// Suporta cor de acento para o ícone e fundo do avatar.
class ActionCard extends StatelessWidget {
  const ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.accentColor,
    this.iconBackgroundColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  /// Cor do ícone e do texto do título. Padrão: azul principal.
  final Color? accentColor;

  /// Cor de fundo do avatar. Padrão: versão suave da [accentColor].
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.primary;
    final effectiveBg = iconBackgroundColor ?? effectiveAccent.withValues(alpha: 0.12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: effectiveBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: effectiveAccent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.border,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
