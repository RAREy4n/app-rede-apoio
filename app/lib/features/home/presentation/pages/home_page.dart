import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/action_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = '/inicio';

  void _showPending(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature será implementado na próxima etapa.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rede de Apoio'),
        actions: [
          IconButton(
            tooltip: 'Saída rápida',
            onPressed: () => _showPending(context, 'Saída rápida'),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Como podemos ajudar?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text('Escolha uma opção. Você mantém o controle de cada ação.'),
          const SizedBox(height: 20),
          ActionCard(
            icon: Icons.local_police_outlined,
            title: 'Emergência — 190',
            description: 'Abrir a ligação para a Polícia Militar.',
            color: AppColors.emergency,
            onTap: () => _showPending(context, 'Ligação para 190'),
          ),
          ActionCard(
            icon: Icons.support_agent,
            title: 'Orientação — Ligue 180',
            description: 'Acessar o canal oficial de orientação e denúncia.',
            onTap: () => _showPending(context, 'Acesso ao Ligue 180'),
          ),
          ActionCard(
            icon: Icons.person_outline,
            title: 'Pessoa de confiança',
            description: 'Cadastrar ou avisar um contato escolhido.',
            onTap: () => _showPending(context, 'Pessoa de confiança'),
          ),
          ActionCard(
            icon: Icons.location_on_outlined,
            title: 'Encontrar apoio',
            description: 'Localizar serviços e instituições próximas.',
            onTap: () => _showPending(context, 'Mapa da rede de apoio'),
          ),
          ActionCard(
            icon: Icons.menu_book_outlined,
            title: 'Entender meus direitos',
            description: 'Informações sobre BO, denúncia e medida protetiva.',
            onTap: () => _showPending(context, 'Orientações'),
          ),
        ],
      ),
    );
  }
}
