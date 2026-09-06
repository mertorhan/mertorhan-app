import 'package:flutter_test/flutter_test.dart';

import 'package:mertorhan_app/main.dart';

void main() {
  testWidgets('Yer tutucu ekran acilir ve marka adini gosterir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MertorhanApp());

    expect(find.text('Mert Orhan'), findsOneWidget);
  });
}
