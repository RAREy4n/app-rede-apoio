import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rede_apoio/features/support_network/domain/models/support_institution.dart';
import 'package:rede_apoio/features/support_network/presentation/pages/support_network_page.dart';

void main() {
  group('SupportInstitution Model', () {
    test('formata corretamente distâncias em metros e quilômetros', () {
      const instMetros = SupportInstitution(
        id: '1',
        name: 'DEAM Centro',
        category: 'delegacia_mulher',
        address: 'Rua Central, 100',
        city: 'São Paulo',
        state: 'SP',
        distanceKm: 0.45,
      );
      expect(instMetros.formattedDistance, '450 m');

      const instKm = SupportInstitution(
        id: '2',
        name: 'CREAS',
        category: 'creas',
        address: 'Av Paulista, 500',
        city: 'São Paulo',
        state: 'SP',
        distanceKm: 2.34,
      );
      expect(instKm.formattedDistance, '2.3 km');
    });

    test('reconhece atendimento 24 horas', () {
      const inst24h = SupportInstitution(
        id: '1',
        name: 'DEAM 24h',
        category: 'delegacia_mulher',
        address: 'Rua Central',
        city: 'SP',
        state: 'SP',
        openingHours: {'seg': '24h', 'dom': '24h'},
      );
      expect(inst24h.is24Hours, isTrue);
      expect(inst24h.formattedOpeningHours, 'Atendimento 24 horas');
    });
  });

  group('SupportNetworkPage Widget', () {
    testWidgets('renderiza títulos, busca e categorias', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SupportNetworkPage(),
        ),
      );

      expect(find.text('Rede de Apoio'), findsOneWidget);
      expect(find.text('Pontos de atendimento e proteção'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Delegacias'), findsOneWidget);
      expect(find.text('Acolhimento'), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
