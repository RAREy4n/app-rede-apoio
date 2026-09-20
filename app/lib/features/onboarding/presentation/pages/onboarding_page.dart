import 'package:flutter/material.dart';

import '../../../home/presentation/pages/home_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(
                Icons.shield_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Uma rede de apoio mais perto de você',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Encontre serviços, cadastre uma pessoa de confiança e acesse canais oficiais.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  // O cadastro do contato será implementado na próxima etapa.
                  Navigator.pushReplacementNamed(context, HomePage.routeName);
                },
                child: const Text('Configurar aplicativo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, HomePage.routeName);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Acessar ajuda agora'),
              ),
              const SizedBox(height: 16),
              Text(
                'Em emergência imediata, ligue para 190.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
