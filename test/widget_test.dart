import 'package:flutter_test/flutter_test.dart';
import 'package:camilo_verde/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CamiloVerdeApp());
    expect(find.byType(CamiloVerdeApp), findsOneWidget);
  });
}
