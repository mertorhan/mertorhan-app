import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/api/paged_response.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/paged_list_view.dart';

/// Ortak govde: dort durum ve RefreshIndicator burada, tek yerde.
/// Bu dosya bodyBuilder'in o dorde DOKUNMADIGINI sinar.
///
/// Aga cikilmaz: fetch dogrudan sahte bir Future dondurur.

PagedResponse<String> _page(List<String> items) => PagedResponse<String>(
  items: items,
  hasNextPage: false,
  totalCount: items.length,
);

/// Kaydirilabilir govde: bodyBuilder'in dokumandaki sartini karsilar.
/// Kisa icerikte de asagi cekilebilsin diye AlwaysScrollableScrollPhysics.
Widget _izgaraTaklidi(List<String> items) => SingleChildScrollView(
  physics: const AlwaysScrollableScrollPhysics(),
  child: Column(
    children: [for (final String item in items) Text('izgara: $item')],
  ),
);

void main() {
  testWidgets('bodyBuilder VERILMEZSE eski davranis aynen calisir', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PagedListView<String>(
            fetch: () async => _page(<String>['bir', 'iki']),
            emptyMessage: 'Bos',
            itemBuilder: (_, String item) => Text(item),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('bir'), findsOneWidget);
    expect(find.text('iki'), findsOneWidget);
    // Ayracli ListView yolu: iki oge arasinda bir ayrac.
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('bodyBuilder VERILIRSE dolu durumda o cizilir', (tester) async {
    List<String>? gorulen;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PagedListView<String>(
            fetch: () async => _page(<String>['bir', 'iki']),
            emptyMessage: 'Bos',
            bodyBuilder: (_, List<String> items) {
              gorulen = items;
              return _izgaraTaklidi(items);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Govdeyi bodyBuilder kurdu; ListView yolu hic cizilmedi.
    expect(find.text('izgara: bir'), findsOneWidget);
    expect(find.text('izgara: iki'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    // TUM listeyi gordu, tek tek oge degil.
    expect(gorulen, <String>['bir', 'iki']);
  });

  testWidgets('bodyBuilder yolunda ASAGI CEKIP YENILEME calisir', (
    tester,
  ) async {
    // Kural bugune kadar yalnizca dokumanda yaziyordu; doküman kimseyi
    // korumaz. RefreshIndicator ancak kaydirilabilir bir govdeyle calisir.
    int cagriSayisi = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PagedListView<String>(
            fetch: () async {
              cagriSayisi++;
              return _page(<String>['bir', 'iki']);
            },
            emptyMessage: 'Bos',
            bodyBuilder: (_, List<String> items) => _izgaraTaklidi(items),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(cagriSayisi, 1);

    await tester.fling(
      find.text('izgara: bir'),
      const Offset(0, 300),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(cagriSayisi, 2);
  });

  testWidgets('YUKLENIYOR durumunda bodyBuilder cagrilmaz', (tester) async {
    int bodyCagrisi = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PagedListView<String>(
            // Hic tamamlanmayan istek: ekran yukleniyor durumunda kalir.
            fetch: () => Completer<PagedResponse<String>>().future,
            emptyMessage: 'Bos',
            bodyBuilder: (_, List<String> items) {
              bodyCagrisi++;
              return _izgaraTaklidi(items);
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(bodyCagrisi, 0);
  });

  testWidgets('HATA durumunda bodyBuilder cagrilmaz', (tester) async {
    int bodyCagrisi = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PagedListView<String>(
            fetch: () async => throw const ApiException.network(),
            emptyMessage: 'Bos',
            bodyBuilder: (_, List<String> items) {
              bodyCagrisi++;
              return _izgaraTaklidi(items);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(const ApiException.network().userMessage), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(bodyCagrisi, 0);
  });

  testWidgets('BOS durumda bodyBuilder cagrilmaz', (tester) async {
    int bodyCagrisi = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: PagedListView<String>(
            fetch: () async => _page(<String>[]),
            emptyMessage: 'Henüz kayıt yok',
            bodyBuilder: (_, List<String> items) {
              bodyCagrisi++;
              return _izgaraTaklidi(items);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Henüz kayıt yok'), findsOneWidget);
    // Bos liste emptyMessage'a dusuyor; bodyBuilder bos listeyle
    // cagrilmiyor.
    expect(bodyCagrisi, 0);
  });
}
