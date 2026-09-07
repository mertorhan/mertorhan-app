import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/models/filter_option.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/filter_chips.dart';

/// Bu dosyadaki hicbir test aga cikmaz; hap sirasi saf gorunum.

const List<FilterOption> _secenekler = [
  FilterOption(value: '5', label: 'Ürün Yönetimi', count: 1),
  FilterOption(value: '3', label: 'Ekonomi', count: 4),
];

Widget _wrap({
  String? selected,
  required void Function(String?) onSelected,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: FilterChipRow(
        options: _secenekler,
        selectedValue: selected,
        onSelected: onSelected,
      ),
    ),
  );
}

void main() {
  testWidgets('Tumu ve secenekler etiket ve sayiyla gorunur', (tester) async {
    await tester.pumpWidget(_wrap(onSelected: (_) {}));

    expect(find.text('Tümü'), findsOneWidget);
    expect(find.text('Ürün Yönetimi (1)'), findsOneWidget);
    expect(find.text('Ekonomi (4)'), findsOneWidget);
  });

  testWidgets('baslangicta Tumu secili, tekrar basmak etkisiz', (tester) async {
    await tester.pumpWidget(_wrap(onSelected: (_) {}));

    final InkWell tumu = tester.widget<InkWell>(
      find.ancestor(of: find.text('Tümü'), matching: find.byType(InkWell)),
    );
    // Zaten "Tumu" seciliyken tekrar basmak bir sey degistirmemeli.
    expect(tumu.onTap, isNull);
  });

  testWidgets('bir hapa basinca degeri dondurur', (tester) async {
    String? secilen;
    bool cagrildi = false;
    await tester.pumpWidget(
      _wrap(
        onSelected: (String? v) {
          secilen = v;
          cagrildi = true;
        },
      ),
    );

    await tester.tap(find.text('Ekonomi (4)'));
    await tester.pumpAndSettle();

    expect(cagrildi, isTrue);
    expect(secilen, '3');
  });

  testWidgets('secili hapa tekrar basinca null doner', (tester) async {
    String? secilen = 'baslangic';
    bool cagrildi = false;
    await tester.pumpWidget(
      _wrap(
        selected: '3',
        onSelected: (String? v) {
          secilen = v;
          cagrildi = true;
        },
      ),
    );

    await tester.tap(find.text('Ekonomi (4)'));
    await tester.pumpAndSettle();

    // "Tumu"ye doner.
    expect(cagrildi, isTrue);
    expect(secilen, isNull);
  });

  testWidgets('secili degilken Tumu ye basinca null doner', (tester) async {
    String? secilen = 'baslangic';
    await tester.pumpWidget(
      _wrap(selected: '5', onSelected: (String? v) => secilen = v),
    );

    await tester.tap(find.text('Tümü'));
    await tester.pumpAndSettle();

    expect(secilen, isNull);
  });

  testWidgets('secili hap vurgu zeminli, digerleri degil', (tester) async {
    await tester.pumpWidget(_wrap(selected: '3', onSelected: (_) {}));

    Material zemin(String etiket) => tester.widget<Material>(
      find.ancestor(of: find.text(etiket), matching: find.byType(Material)).first,
    );

    expect(zemin('Ekonomi (4)').color, isNot(zemin('Ürün Yönetimi (1)').color));
  });

  testWidgets('secenek yoksa yalnizca Tumu kalir', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: FilterChipRow(
            options: const [],
            selectedValue: null,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Tümü'), findsOneWidget);
    expect(find.textContaining('('), findsNothing);
  });
}
