import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/action_card.dart';
import '../../../../core/widgets/support_map_preview.dart';
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
      SnackBar(content: Text('$feature é uma demonstração visual nesta versão.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.pinkSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_outlined,
                    color: AppColors.pink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rede de Apoio',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Saída rápida',
                  onPressed: () => _showPending('Saída rápida'),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Apoio perto de você',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Encontre serviços e canais de orientação. Você decide cada próximo passo.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Delegacias', 'Acolhimento', 'Jurídico']
                    .map(
                      (filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _filter == filter,
                          selectedColor: AppColors.blueSoft,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 14),
            const SupportMapPreview(),
            const SizedBox(height: 20),
            _EmergencyCard(onTap: () => _showPending('Ligação para 190')),
            const SizedBox(height: 20),
            Text(
              'Outras opções',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            ActionCard(
              icon: Icons.person_outline,
              title: 'Pessoa de confiança',
              description: 'Cadastrar ou revisar um contato escolhido.',
              color: AppColors.pink,
              onTap: () => Navigator.pushNamed(
                context,
                TrustedContactPage.routeName,
              ),
            ),
            ActionCard(
              icon: Icons.support_agent_outlined,
              title: 'Ligue 180',
              description: 'Canal oficial de orientação e denúncia.',
              onTap: () => _showPending('Acesso ao Ligue 180'),
            ),
            ActionCard(
              icon: Icons.menu_book_outlined,
              title: 'Orientações e direitos',
              description: 'Informações iniciais sobre proteção e atendimento.',
              onTap: () => _showPending('Orientações e direitos'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.emergency,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0x33FFFFFF),
                foregroundColor: Colors.white,
                child: Icon(Icons.phone_in_talk_outlined),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergência — 190',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Abrir ligação para a Polícia Militar.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
