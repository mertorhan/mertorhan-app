import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/models/filter_option.dart';
import 'package:mertorhan_app/models/filter_options.dart';
import 'package:mertorhan_app/models/filter_selection.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/utils/filter_labels.dart';
import 'package:mertorhan_app/widgets/filter_sheet.dart';

/// Bu dosyadaki hicbir test aga cikmaz; panel yalnizca verilen
/// seceneklerle calisir.

FilterOptions _options() => const FilterOptions(
  groups: {
    'genre': [
      FilterOption(value: '1', label: 'Comedy', count: 1),
      FilterOption(value: '2', label: 'Action', count: 3),
    ],
    'year': [FilterOption(value: '2011', label: '2011', count: 1)],
  },
);

FilterSelection _secim(List<(String, String)> ciftler) {
  FilterSelection s = const FilterSelection.empty();
  for (final (String key, String value) in ciftler) {
    s = s.toggle(key, value);
  }
  return s;
}

/// Paneli acan sarmalayici: donen degeri [sonuc]'a yazar.
///
/// Panel bir Future dondurdugu icin dogrudan pumpWidget ile test
/// edilemiyor; once "Ac" dugmesine basiliyor.
class _Sahne extends StatefulWidget {
  const _Sahne({
    required this.options,
    required this.current,
    required this.groups,
  });

  final FilterOptions options;
  final FilterSelection current;
  final FilterGroups groups;

  @override
  State<_Sahne> createState() => _SahneState();
}

class _SahneState extends State<_Sahne> {
  /// Panel kapandiginda dolan sonuc. Hic kapanmadiysa [acildi] false.
  FilterSelection? sonuc;
  bool kapandi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final FilterSelection? donen = await showFilterSheet(
              context: context,
              options: widget.options,
              current: widget.current,
              groups: widget.groups,
            );
            setState(() {
              sonuc = donen;
              kapandi = true;
            });
          },
          child: const Text('Ac'),
        ),
      ),
    );
  }
}

Future<_SahneState> _paneliAc(
  WidgetTester tester, {
  FilterOptions? options,
  FilterSelection current = const FilterSelection.empty(),
  FilterGroups groups = movieFilterGroups,
}) async {
  final Widget sahne = _Sahne(
    options: options ?? _options(),
    current: current,
    groups: groups,
  );

  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: sahne));
  await tester.tap(find.text('Ac'));
  await tester.pumpAndSettle();

  return tester.state<_SahneState>(find.byType(_Sahne));
}

void main() {
  testWidgets('panel acilir, grup basliklari sirayla gorunur', (tester) async {
    await _paneliAc(tester);

    // movieFilterGroups sirasi: content_type, year, watched_year,
    // director, screenwriter, actor, genre, rating.
    expect(find.text('Filtrele'), findsOneWidget);
    expect(find.text('Yapım yılı'), findsOneWidget);
    expect(find.text('Tür'), findsOneWidget);
  });

  testWidgets('secenegi olmayan grup HIC cizilmez', (tester) async {
    await _paneliAc(tester);

    // _options yalnizca genre ve year iceriyor; digerleri cizilmemeli.
    expect(find.text('Yönetmen'), findsNothing);
    expect(find.text('Senarist'), findsNothing);
    expect(find.text('Oyuncular'), findsNothing);
    expect(find.text('Puan'), findsNothing);
    expect(find.text('Film / dizi'), findsNothing);
  });

  testWidgets('grup acilinca secenekler etiket ve sayiyla gorunur', (
    tester,
  ) async {
    await _paneliAc(tester);

    await tester.tap(find.text('Tür'));
    await tester.pumpAndSettle();

    expect(find.text('Comedy (1)'), findsOneWidget);
    expect(find.text('Action (3)'), findsOneWidget);
  });

  testWidgets('Uygula secimi dondurur', (tester) async {
    final _SahneState sahne = await _paneliAc(tester);

    await tester.tap(find.text('Tür'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comedy (1)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Uygula'));
    await tester.pumpAndSettle();

    expect(sahne.kapandi, isTrue);
    expect(sahne.sonuc, _secim([('genre', '1')]));
  });

  testWidgets('kapatma dugmesi null dondurur, secim yok sayilir', (
    tester,
  ) async {
    final _SahneState sahne = await _paneliAc(tester);

    await tester.tap(find.text('Tür'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comedy (1)'));
    await tester.pumpAndSettle();

    // Isaretledi ama Uygula'ya basmadan kapatti.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(sahne.kapandi, isTrue);
    expect(sahne.sonuc, isNull);
  });

  testWidgets('gelen secim panelde isaretli baslar', (tester) async {
    await _paneliAc(tester, current: _secim([('genre', '2')]));

    // Baslikta sayi gorunur.
    expect(find.text('Filtrele (1)'), findsOneWidget);

    await tester.tap(find.text('Tür'));
    await tester.pumpAndSettle();

    final CheckboxListTile kutu = tester.widget<CheckboxListTile>(
      find.ancestor(
        of: find.text('Action (3)'),
        matching: find.byType(CheckboxListTile),
      ),
    );
    expect(kutu.value, isTrue);
  });

  testWidgets('secili grupta kac secili oldugu yazar', (tester) async {
    await _paneliAc(tester, current: _secim([('genre', '1'), ('genre', '2')]));

    expect(find.text('2 seçili'), findsOneWidget);
  });

  testWidgets('Temizle gecici secimi bosaltir ama paneli KAPATMAZ', (
    tester,
  ) async {
    final _SahneState sahne = await _paneliAc(
      tester,
      current: _secim([('genre', '1')]),
    );

    expect(find.text('Filtrele (1)'), findsOneWidget);

    await tester.tap(find.text('Temizle'));
    await tester.pumpAndSettle();

    // Panel hala acik.
    expect(sahne.kapandi, isFalse);
    expect(find.text('Uygula'), findsOneWidget);
    // Sayi dustu.
    expect(find.text('Filtrele'), findsOneWidget);
    expect(find.text('Filtrele (1)'), findsNothing);
  });

  testWidgets('Temizle secim yokken etkisiz', (tester) async {
    await _paneliAc(tester);

    final TextButton temizle = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('Temizle'),
        matching: find.byType(TextButton),
      ),
    );
    expect(temizle.onPressed, isNull);
  });

  testWidgets('ayni secimle Uygula esit nesne dondurur', (tester) async {
    final FilterSelection baslangic = _secim([('genre', '1')]);
    final _SahneState sahne = await _paneliAc(tester, current: baslangic);

    await tester.tap(find.text('Uygula'));
    await tester.pumpAndSettle();

    // Cagiran taraf bunu karsilastirip gereksiz istek atmayacak.
    expect(sahne.sonuc, equals(baslangic));
  });
}
