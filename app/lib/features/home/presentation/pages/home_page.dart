import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/emergency_service.dart';
import '../../../../core/services/share_location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/action_card.dart';
import '../../../../core/widgets/support_map_preview.dart';
import '../../../support_network/presentation/pages/support_network_page.dart';
import '../../../trusted_contact/presentation/pages/trusted_contact_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/inicio';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _filter = 'Todos';

  void _showPending(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature é uma demonstração visual nesta versão.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _enviarLocalizacao() async {
    // Mostrar indicação de carregamento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Obtendo localização…'),
          ],
        ),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final resultado = await ShareLocationService.enviarParaQualquerContato();

    if (!mounted) return;

    // Limpar snackbar de carregamento
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    switch (resultado) {
      case ShareResult.sucesso:
        // WhatsApp aberto com sucesso — nada mais a fazer
        break;
      case ShareResult.semLocalizacao:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Não foi possível obter sua localização. '
              'Verifique se o GPS está ativo e se a permissão foi concedida.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      case ShareResult.whatsappIndisponivel:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'WhatsApp não encontrado. Verifique se está instalado.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      case ShareResult.falhaGeral:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Não foi possível compartilhar a localização neste momento.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // ── Cabeçalho ────────────────────────────────────────────
              Row(
                children: [
                  // Logo / ícone do app
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.pinkSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      color: AppColors.pink,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rede de Apoio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                    ),
                  ),
                  // Botão de saída rápida
                  Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _showPending('Saída rápida'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Título da seção ───────────────────────────────────────
              Text(
                'Apoio perto de você',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Encontre serviços e canais de orientação. Você decide cada próximo passo.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),

              // ── Filtros ───────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todos', 'Delegacias', 'Acolhimento', 'Jurídico']
                      .map(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: filter,
                            selected: _filter == filter,
                            onSelected: () =>
                                setState(() => _filter = filter),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              // ── Mapa demonstrativo ────────────────────────────────────
              SupportMapPreview(
                onTap: () => Navigator.pushNamed(
                  context,
                  SupportNetworkPage.routeName,
                ),
              ),

              const SizedBox(height: 16),

              // ── Card de Emergência 190 ────────────────────────────────
              _EmergencyCard(
                onTap: () => EmergencyService.confirmarELigar190(context),
              ),

              const SizedBox(height: 24),

              // ── Outras opções ─────────────────────────────────────────
              Text(
                'Outras opções',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 12),

              ActionCard(
                icon: Icons.people_alt_rounded,
                title: 'Pessoa de confiança',
                description: 'Cadastrar ou revisar um contato escolhido.',
                accentColor: AppColors.pink,
                iconBackgroundColor: AppColors.pinkSoft,
                onTap: () => Navigator.pushNamed(
                  context,
                  TrustedContactPage.routeName,
                ),
              ),
              ActionCard(
                icon: Icons.location_on_rounded,
                title: 'Enviar localização',
                description: 'Compartilhar sua posição atual via WhatsApp.',
                accentColor: const Color(0xFF2E7D32),
                iconBackgroundColor: const Color(0xFFE8F5E9),
                onTap: () => _enviarLocalizacao(),
              ),
              ActionCard(
                icon: Icons.support_agent_rounded,
                title: 'Ligue 180',
                description: 'Canal oficial de orientação e denúncia.',
                accentColor: AppColors.primary,
                iconBackgroundColor: AppColors.blueSoft,
                onTap: () => EmergencyService.confirmarELigar180(context),
              ),
              ActionCard(
                icon: Icons.menu_book_rounded,
                title: 'Orientações e direitos',
                description: 'Informações sobre proteção e atendimento.',
                onTap: () => _showPending('Orientações e direitos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widget: Chip de filtro ──────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Widget: Card de Emergência ──────────────────────────────────────────────

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.emergency,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: Colors.white.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: [
              // Ícone com fundo semi-transparente
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergência — 190',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Abrir ligação para a Polícia Militar.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
