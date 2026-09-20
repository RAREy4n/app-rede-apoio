import 'package:flutter_test/flutter_test.dart';
import 'package:rede_apoio/app/app.dart';

void main() {
  testWidgets('mostra acesso à configuração e à ajuda imediata', (tester) async {
    await tester.pumpWidget(const RedeApoioApp());

    expect(find.text('Configurar aplicativo'), findsOneWidget);
    expect(find.text('Acessar ajuda agora'), findsOneWidget);
    expect(find.text('Em emergência imediata, ligue para 190.'), findsOneWidget);
  });

  testWidgets('abre o cadastro de pessoa de confiança', (tester) async {
    await tester.pumpWidget(const RedeApoioApp());

    await tester.tap(find.text('Configurar aplicativo'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastre uma pessoa de confiança'), findsOneWidget);
    expect(find.text('Nome da pessoa'), findsOneWidget);
  });
}
