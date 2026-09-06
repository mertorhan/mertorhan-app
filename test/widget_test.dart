import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mertorhan_app/main.dart';

/// Sekme adi ayni anda navigasyon cubugunda, AppBar'da ve govdede gecer.
/// Duz find.text uc eslesme dondurur; AppBar'a daraltmak hangi ekranin acik
/// oldugunu kesin sekilde soyler.
Finder _appBarTitle(String title) => find.descendant(
  of: find.byType(AppBar),
  matching: find.text(title),
);

void main() {
  testWidgets('Acilista Yayinlar sekmesi gorunur', (WidgetTester tester) async {
    await tester.pumpWidget(const MertorhanApp());

    expect(_appBarTitle('Yayınlar'), findsOneWidget);
  });

  testWidgets('Profil sekmesine dokununca Profil ekrani gelir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MertorhanApp());

    // Ikon yalnizca navigasyon cubugunda var, tek eslesme.
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(_appBarTitle('Profil'), findsOneWidget);
    expect(_appBarTitle('Yayınlar'), findsNothing);
  });
}
