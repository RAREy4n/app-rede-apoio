import 'package:flutter_test/flutter_test.dart';
import 'package:rede_apoio/app/app.dart';

void main() {
  testWidgets('mostra acesso à configuração e à ajuda imediata', (tester) async {
    await tester.pumpWidget(const RedeApoioApp());

    expect(find.text('Configurar aplicativo'), findsOneWidget);
    expect(find.text('Acessar ajuda agora'), findsOneWidget);
    expect(find.text('Em emergência imediata, ligue para 190.'), findsOneWidget);
  });
}
