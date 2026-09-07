import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/filter_bar.dart';

/// Bu dosyadaki hicbir test aga cikmaz; FilterBar saf gorunum.

Widget _wrap({
  required int count,
  VoidCallback? onOpen,
  VoidCallback? onClear,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: FilterBar(
        selectedCount: count,
        onOpen: onOpen ?? () {},
        onClear: onClear ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('secim yokken yalnizca Filtrele yazar', (tester) async {
    await tester.pumpWidget(_wrap(count: 0));

    expect(find.text('Filtrele'), findsOneWidget);
    expect(find.textContaining('('), findsNothing);
  });

  testWidgets('secim yokken Temizle HIC cizilmez', (tester) async {
    await tester.pumpWidget(_wrap(count: 0));

    // Isleyecek bir sey olmayan dugme gosterilmez.
    expect(find.text('Temizle'), findsNothing);
  });

  testWidgets('secim varsa sayi yazar ve Temizle gorunur', (tester) async {
    await tester.pumpWidget(_wrap(count: 2));

    expect(find.text('Filtrele (2)'), findsOneWidget);
    expect(find.text('Temizle'), findsOneWidget);
  });

  testWidgets('Filtrele basilinca onOpen cagrilir', (tester) async {
    int cagri = 0;
    await tester.pumpWidget(_wrap(count: 0, onOpen: () => cagri++));

    await tester.tap(find.text('Filtrele'));
    await tester.pumpAndSettle();

    expect(cagri, 1);
  });

  testWidgets('Temizle basilinca onClear cagrilir', (tester) async {
    int cagri = 0;
    await tester.pumpWidget(_wrap(count: 3, onClear: () => cagri++));

    await tester.tap(find.text('Temizle'));
    await tester.pumpAndSettle();

    expect(cagri, 1);
  });

  testWidgets('altinda ayirici cizgi var', (tester) async {
    await tester.pumpWidget(_wrap(count: 0));

    expect(find.byType(Divider), findsOneWidget);
  });
}
