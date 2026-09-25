import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rede_apoio/core/utils/text_normalizer.dart';
import 'package:rede_apoio/features/support_network/data/support_network_service.dart';
import 'package:rede_apoio/features/support_network/domain/models/support_institution.dart';
import 'package:rede_apoio/features/support_network/presentation/pages/support_network_page.dart';

void main() {
  group('Normalização de texto', () {
    test('remove acentos e deixa minúsculo', () {
      expect(normalizarTexto('Água Verde — São José'), 'agua verde — sao jose');
      expect(normalizarTexto(null), '');
    });

    test('quebra a busca em termos', () {
      expect(termosDeBusca('  Delegacia   CABRAL '), ['delegacia', 'cabral']);
      expect(termosDeBusca(''), isEmpty);
    });
  });

  group('SupportInstitution Model', () {
    test('formata corretamente distâncias em metros e quilômetros', () {
      const instMetros = SupportInstitution(
        id: '1',
        name: 'DEAM Centro',
        category: 'delegacia_mulher',
        address: 'Rua Central, 100',
        city: 'Curitiba',
        state: 'PR',
        distanceKm: 0.45,
      );
      expect(instMetros.formattedDistance, '450 m');

      const instKm = SupportInstitution(
        id: '2',
        name: 'CREAS',
        category: 'creas',
        address: 'Rua XV, 500',
        city: 'Curitiba',
        state: 'PR',
        distanceKm: 2.34,
      );
      expect(instKm.formattedDistance, '2.3 km');
    });

    test('reconhece atendimento 24 horas em todos os dias', () {
      const inst24h = SupportInstitution(
        id: '1',
        name: 'Delegacia 24h',
        category: 'delegacia_mulher',
        address: 'Rua Central',
        city: 'Curitiba',
        state: 'PR',
        openingHours: {'seg': '24h', 'dom': '24h'},
      );
      expect(inst24h.is24Hours, isTrue);
      expect(inst24h.formattedOpeningHours, 'Atendimento 24 horas');
    });

    test('agrupa horários comerciais por faixa de dias', () {
      const inst = SupportInstitution(
        id: '1',
        name: 'CREAS',
        category: 'creas',
        address: 'Rua',
        city: 'Curitiba',
        state: 'PR',
        openingHours: {
          'seg': '08:00-17:00',
          'ter': '08:00-17:00',
          'qua': '08:00-17:00',
          'qui': '08:00-17:00',
          'sex': '08:00-17:00',
          'sab': '08:00-12:00',
        },
      );
      expect(inst.is24Hours, isFalse);
      expect(inst.formattedOpeningHours, 'Seg a Sex: 08:00-17:00 • Sáb: 08:00-12:00');
    });

    test('sem horário cadastrado orienta a ligar antes', () {
      const inst = SupportInstitution(
        id: '1',
        name: 'X',
        category: 'hospital',
        address: 'Rua',
        city: 'Curitiba',
        state: 'PR',
      );
      expect(inst.formattedOpeningHours, contains('ligue antes'));
    });

    test('selo de verificação respeita a validade de 180 dias', () {
      final inst = SupportInstitution(
        id: '1',
        name: 'X',
        category: 'hospital',
        address: 'Rua',
        city: 'Curitiba',
        state: 'PR',
        verifiedAt: DateTime(2026, 9, 24),
      );
      expect(inst.isVerified(DateTime(2026, 10, 1)), isTrue);
      expect(inst.verificationLabel(DateTime(2026, 10, 1)), 'Verificado em 24/09/2026');
      expect(inst.isVerified(DateTime(2027, 6, 1)), isFalse);
      expect(inst.verificationLabel(DateTime(2027, 6, 1)), contains('desatualizado'));

      const semData = SupportInstitution(
        id: '2',
        name: 'Y',
        category: 'hospital',
        address: 'Rua',
        city: 'Curitiba',
        state: 'PR',
      );
      expect(semData.isVerified(), isFalse);
      expect(semData.verificationLabel(), startsWith('Dados a confirmar'));
    });

    test('lê os campos de curadoria vindos do Supabase', () {
      final inst = SupportInstitution.fromSupabase({
        'id': 'abc',
        'external_key': 'cwb-teste',
        'name': 'Teste',
        'category': 'hospital',
        'address': 'Rua A, 1',
        'district': 'Centro',
        'city': 'Curitiba',
        'state': 'PR',
        'phone': '',
        'latitude': -25.4,
        'longitude': '-49.2',
        'services': ['atendimento_violencia_sexual'],
        'target_audience': 'Mulheres a partir de 12 anos',
        'verified_at': '2026-09-24T12:00:00Z',
        'source_name': 'TJPR',
        'source_url': 'https://www.tjpr.jus.br',
        'location_precision': 'aproximada',
        'distance_km': 1.5,
      });
      expect(inst.externalKey, 'cwb-teste');
      expect(inst.district, 'Centro');
      expect(inst.phone, isNull, reason: 'telefone vazio não deve virar botão');
      expect(inst.longitude, -49.2);
      expect(inst.hasApproximateLocation, isTrue);
      expect(inst.servicesLabels, ['Atendimento a violência sexual']);
      expect(inst.sourceUrl, 'https://www.tjpr.jus.br');
    });
  });

  group('Busca offline (mesmas regras do servidor)', () {
    final base = SupportNetworkService.obterInstituicoesContingencia();

    test('lista de contingência é do piloto Curitiba e verificada', () {
      expect(base, isNotEmpty);
      for (final inst in base) {
        expect(inst.city, 'Curitiba');
        expect(inst.verifiedAt, isNotNull, reason: inst.name);
        expect(inst.sourceUrl, isNotNull, reason: inst.name);
        expect(inst.category, isNot('casa_abrigo'));
      }
    });

    test('busca ignora acentos e maiúsculas', () {
      final r = SupportNetworkService.filtrarLocalmente(base, texto: 'AGUA verde');
      expect(r.map((i) => i.externalKey), ['cwb-pequeno-principe']);
    });

    test('todas as palavras precisam aparecer', () {
      final r = SupportNetworkService.filtrarLocalmente(base, texto: 'delegacia cabral');
      expect(r.map((i) => i.externalKey), ['cwb-delegacia-mulher']);
      expect(
        SupportNetworkService.filtrarLocalmente(base, texto: 'delegacia bigorrilho'),
        isEmpty,
      );
    });

    test('encontra por nome legível do serviço', () {
      final r = SupportNetworkService.filtrarLocalmente(base, texto: 'medida protetiva');
      expect(r.map((i) => i.externalKey), contains('cwb-delegacia-mulher'));
    });

    test('filtra por grupo de categorias', () {
      final r = SupportNetworkService.filtrarLocalmente(
        base,
        categorias: const ['hospital', 'upa'],
      );
      expect(r, isNotEmpty);
      expect(r.every((i) => i.category == 'hospital'), isTrue);
    });

    test('com localização, ordena pelo mais próximo', () {
      // Ponto ao lado da Casa da Mulher Brasileira (Cabral).
      final r = SupportNetworkService.filtrarLocalmente(base, lat: -25.4047, lng: -49.2502);
      expect(r.first.city, 'Curitiba');
      expect(r.first.distanceKm, lessThan(0.1));
      for (var i = 1; i < r.length; i++) {
        expect(r[i].distanceKm!, greaterThanOrEqualTo(r[i - 1].distanceKm!));
      }
    });
  });

  group('Raio de busca (offline)', () {
    test('com posição, mostra só o que está dentro do raio', () async {
      // Ao lado da Casa da Mulher Brasileira (Cabral).
      final r = await SupportNetworkService.buscarInstituicoes(
        lat: -25.4047, lng: -49.2502, raioKm: 1);
      expect(r.offline, isTrue);
      expect(r.foraDoRaio, isFalse);
      expect(r.instituicoes.map((i) => i.externalKey),
          unorderedEquals(['cwb-casa-mulher-brasileira', 'cwb-delegacia-mulher']));
    });

    test('sem nada no raio, mostra os mais próximos e avisa', () async {
      // São Paulo: nada de Curitiba a menos de 20 km.
      final r = await SupportNetworkService.buscarInstituicoes(
        lat: -23.55, lng: -46.63, raioKm: 20);
      expect(r.foraDoRaio, isTrue);
      expect(r.instituicoes, isNotEmpty);
    });
  });

  group('SupportNetworkPage Widget', () {
    testWidgets('renderiza títulos, busca e categorias', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SupportNetworkPage(buscarLocalizacaoAoIniciar: false),
        ),
      );

      expect(find.text('Rede de Apoio'), findsOneWidget);
      expect(find.text('Pontos de atendimento e proteção'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      for (final cat in SupportNetworkPage.categoriasFiltro) {
        expect(find.text(cat.label), findsOneWidget);
      }

      await tester.pumpAndSettle();
    });

    testWidgets('sem Supabase, mostra a lista offline e filtra pela busca', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SupportNetworkPage(buscarLocalizacaoAoIniciar: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Sem conexão'), findsOneWidget);
      expect(find.text('Casa da Mulher Brasileira de Curitiba'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'agua verde');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Hospital Pequeno Príncipe'), findsOneWidget);
      expect(find.text('Casa da Mulher Brasileira de Curitiba'), findsNothing);
    });

    testWidgets('abre já filtrada pela categoria escolhida', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SupportNetworkPage(
            categoriaInicial: 'delegacias',
            buscarLocalizacaoAoIniciar: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delegacia da Mulher de Curitiba'), findsOneWidget);
      expect(find.text('Hospital Pequeno Príncipe'), findsNothing);
    });
  });
}
