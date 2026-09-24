import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/support_network_service.dart';
import '../../domain/models/support_institution.dart';

class SupportNetworkPage extends StatefulWidget {
  const SupportNetworkPage({super.key});

  static const routeName = '/rede-apoio';

  @override
  State<SupportNetworkPage> createState() => _SupportNetworkPageState();
}

class _SupportNetworkPageState extends State<SupportNetworkPage> {
  List<SupportInstitution> _todasInstituicoes = [];
  List<SupportInstitution> _instituicoesFiltradas = [];

  bool _carregando = true;
  String? _erroLocalizacao;
  Position? _posicaoAtual;
  String _filtroCategoria = 'todos';
  final TextEditingController _buscaController = TextEditingController();

  final List<({String id, String label, IconData icon})> _categorias = [
    (id: 'todos', label: 'Todos', icon: Icons.grid_view_rounded),
    (id: 'delegacia_mulher', label: 'Delegacias', icon: Icons.local_police_rounded),
    (id: 'creas', label: 'Acolhimento', icon: Icons.favorite_rounded),
    (id: 'defensoria', label: 'Defensoria', icon: Icons.gavel_rounded),
    (id: 'hospital', label: 'Saúde', icon: Icons.local_hospital_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _buscaController.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados({bool forcarGps = false}) async {
    setState(() {
      _carregando = true;
      _erroLocalizacao = null;
    });

    // 1. Tentar obter localização se disponível (com timeout de 3s)
    Position? pos = _posicaoAtual;
    if (pos == null || forcarGps) {
      try {
        pos = await LocationService.obterPosicaoAtual().timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );
        _posicaoAtual = pos;
      } catch (_) {
        pos = null;
      }
    }

    if (pos == null) {
      _erroLocalizacao = 'Localização desativada. Mostrando serviços gerais.';
    }

    // 2. Buscar instituições via PostGIS no Supabase
    List<SupportInstitution> resultados = [];
    try {
      resultados = await SupportNetworkService.buscarInstituicoes(
        lat: pos?.latitude,
        lng: pos?.longitude,
      );
    } catch (_) {
      resultados = [];
    }

    // Se a consulta remota vier vazia, garante que os pontos cadastrados sejam exibidos
    if (resultados.isEmpty) {
      resultados = SupportNetworkService.obterInstituicoesContingencia();
    }

    if (!mounted) return;

    setState(() {
      _todasInstituicoes = resultados;
      _carregando = false;
      _aplicarFiltros();
    });
  }

  void _aplicarFiltros() {
    final query = _buscaController.text.trim().toLowerCase();
    setState(() {
      _instituicoesFiltradas = _todasInstituicoes.where((inst) {
        // Filtro de categoria
        if (_filtroCategoria != 'todos') {
          if (_filtroCategoria == 'creas') {
            final match = inst.category == 'creas' ||
                inst.category == 'cras' ||
                inst.category == 'centro_referencia';
            if (!match) return false;
          } else if (_filtroCategoria == 'defensoria') {
            final match = inst.category == 'defensoria' ||
                inst.category == 'ministerio_publico';
            if (!match) return false;
          } else if (inst.category != _filtroCategoria) {
            return false;
          }
        }

        // Filtro de busca textual
        if (query.isNotEmpty) {
          final nome = inst.name.toLowerCase();
          final endereco = inst.address.toLowerCase();
          final servicos = inst.services.join(' ').toLowerCase();
          if (!nome.contains(query) && !endereco.contains(query) && !servicos.contains(query)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _abrirDetalhes(SupportInstitution inst) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DetalhesInstituicaoSheet(instituicao: inst),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Voltar',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rede de Apoio',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          'Pontos de atendimento e proteção',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _carregarDados(forcarGps: true),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Atualizar locais',
                  ),
                ],
              ),
            ),

            // ── Barra de Busca ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _buscaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, bairro ou serviço...',
                    hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _buscaController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () => _buscaController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // ── Chips de Categorias ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _categorias.map((cat) {
                    final selecionado = _filtroCategoria == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: cat.label,
                        icon: cat.icon,
                        selected: selecionado,
                        onTap: () {
                          setState(() {
                            _filtroCategoria = cat.id;
                            _aplicarFiltros();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Banner de Localização ──────────────────────────────────
            if (_erroLocalizacao != null)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE0B2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFE65100)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _erroLocalizacao!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFE65100)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _carregarDados(forcarGps: true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Ativar GPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            else if (_posicaoAtual != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ordenado pelos locais mais próximos de você',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

            // ── Lista de Locais ────────────────────────────────────────
            Expanded(
              child: _carregando
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2.5),
                          SizedBox(height: 16),
                          Text(
                            'Buscando rede de apoio próxima...',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : _instituicoesFiltradas.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_off_rounded, size: 56, color: AppColors.textSecondary),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum local encontrado',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tente alterar os termos da busca ou selecionar outra categoria.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _buscaController.clear();
                                    setState(() => _filtroCategoria = 'todos');
                                    _carregarDados();
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: const Text('Ver todas as instituições'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: _instituicoesFiltradas.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final inst = _instituicoesFiltradas[index];
                            return _InstituicaoCard(
                              instituicao: inst,
                              onTap: () => _abrirDetalhes(inst),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget: Card de Instituição ──────────────────────────────────────────────

class _InstituicaoCard extends StatelessWidget {
  const _InstituicaoCard({
    required this.instituicao,
    required this.onTap,
  });

  final SupportInstitution instituicao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topo do card: Categoria, Ícone e Distância
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: instituicao.softThemeColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      instituicao.icon,
                      color: instituicao.themeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instituicao.categoryLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: instituicao.themeColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          instituicao.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (instituicao.formattedDistance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blueSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        instituicao.formattedDistance!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Endereço
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${instituicao.address} — ${instituicao.city}, ${instituicao.state}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Horário
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: instituicao.is24Hours ? const Color(0xFF2E7D32) : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    instituicao.formattedOpeningHours,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: instituicao.is24Hours ? FontWeight.w700 : FontWeight.w500,
                      color: instituicao.is24Hours ? const Color(0xFF2E7D32) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Botões de Ação rápida
              Row(
                children: [
                  if (instituicao.phone != null && instituicao.phone!.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => SupportNetworkService.ligar(instituicao.phone!),
                        icon: const Icon(Icons.phone_rounded, size: 16),
                        label: Text(
                          instituicao.phone!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  if (instituicao.phone != null && instituicao.phone!.isNotEmpty)
                    const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => SupportNetworkService.abrirNoMapa(
                        latitude: instituicao.latitude,
                        longitude: instituicao.longitude,
                        endereco: '${instituicao.name}, ${instituicao.address}, ${instituicao.city}',
                      ),
                      icon: const Icon(Icons.directions_rounded, size: 16),
                      label: const Text('Como chegar', style: TextStyle(fontSize: 12)),
                      style: FilledButton.styleFrom(
                        backgroundColor: instituicao.themeColor,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BottomSheet: Detalhes da Instituição ─────────────────────────────────────

class _DetalhesInstituicaoSheet extends StatelessWidget {
  const _DetalhesInstituicaoSheet({required this.instituicao});

  final SupportInstitution instituicao;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de puxar
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Cabeçalho
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: instituicao.softThemeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(instituicao.icon, color: instituicao.themeColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instituicao.categoryLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: instituicao.themeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instituicao.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Informações de Endereço
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_rounded, color: AppColors.primary),
            title: const Text('Endereço', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            subtitle: Text(
              '${instituicao.address}\n${instituicao.city} - ${instituicao.state}${instituicao.zipCode != null ? ' • CEP: ${instituicao.zipCode}' : ''}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),

          // Horário
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_rounded, color: AppColors.primary),
            title: const Text('Horário de Atendimento', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            subtitle: Text(
              instituicao.formattedOpeningHours,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: instituicao.is24Hours ? const Color(0xFF2E7D32) : AppColors.textPrimary,
              ),
            ),
          ),

          // Serviços Oferecidos
          if (instituicao.services.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Serviços disponíveis:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: instituicao.services.map((servico) {
                final label = servico.replaceAll('_', ' ').toUpperCase();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),

          // Ações principais
          Row(
            children: [
              if (instituicao.phone != null && instituicao.phone!.isNotEmpty) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => SupportNetworkService.ligar(instituicao.phone!),
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text('Ligar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => SupportNetworkService.abrirNoMapa(
                    latitude: instituicao.latitude,
                    longitude: instituicao.longitude,
                    endereco: '${instituicao.name}, ${instituicao.address}, ${instituicao.city}',
                  ),
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('Como chegar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: instituicao.themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widget: Chip de Categoria Personalizado ──────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.2,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
