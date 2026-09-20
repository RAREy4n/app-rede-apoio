import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';

class TrustedContactPage extends StatefulWidget {
  const TrustedContactPage({super.key});

  static const routeName = '/pessoa-de-confianca';

  @override
  State<TrustedContactPage> createState() => _TrustedContactPageState();
}

class _TrustedContactPageState extends State<TrustedContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _continueToHome() {
    Navigator.pushReplacementNamed(context, HomePage.routeName);
  }

  void _saveContact() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contato salvo apenas nesta demonstração local.'),
      ),
    );
    _continueToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.pinkSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  color: AppColors.pink,
                  size: 30,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Cadastre uma pessoa de confiança',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Escolha alguém que você gostaria de avisar no futuro. '
                'Nenhuma localização ou mensagem será enviada agora.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome da pessoa',
                  hintText: 'Ex.: Maria Silva',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Informe um nome para continuar.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(00) 00000-0000',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (digits.length < 10) {
                    return 'Informe um telefone válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Você terá controle antes de qualquer compartilhamento. '
                        'Esta versão ainda não envia localização, SMS ou WhatsApp.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saveContact,
                child: const Text('Salvar contato'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _continueToHome,
                child: const Text('Pular por agora'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
