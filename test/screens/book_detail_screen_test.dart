import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/api/books_api.dart';
import 'package:mertorhan_app/models/book.dart';
import 'package:mertorhan_app/models/book_detail.dart';
import 'package:mertorhan_app/models/book_quote.dart';
import 'package:mertorhan_app/screens/book_detail_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/quote_box.dart';

/// Sahte uygulama: fetchBook ezilir, gercek istek atilmaz.
///
/// Aga cikan test, internet yavassa veya sunucu kapaliysa kirmizi olur ve
/// kodda hata varmis gibi gorunur. Bu dosyada hicbir test aga cikmaz.
class _FakeBooksApi extends BooksApi {
  _FakeBooksApi({this.detail, this.error, this.completer});

  final BookDetail? detail;
  final Object? error;

  /// Verilirse yanit bu tamamlanana kadar bekletilir.
  final Completer<BookDetail>? completer;

  int cagriSayisi = 0;

  @override
  Future<BookDetail> fetchBook(String slug) async {
    cagriSayisi++;
    if (completer != null) return completer!.future;
    if (error != null) throw error!;
    return detail!;
  }
}

/// coverImage varsayilan null: Image.network kurulmaz, test aga cikmaz.
Book _book({
  String title = 'Suç ve Ceza',
  num? rating,
  int? releaseYear,
  DateTime? readAt,
  String? coverImage,
}) {
  return Book(
    id: 1,
    slug: 'suc-ve-ceza',
    title: title,
    author: 'Dostoyevski',
    translator: 'Ergin Altay',
    coverImage: coverImage,
    rating: rating,
    summary: 'Liste ozeti.',
    publishedAt: DateTime(2026, 8, 13),
    releaseYear: releaseYear,
    readAt: readAt,
    isFeatured: false,
  );
}

BookDetail _detail({
  Book? book,
  String body = 'Kitap hakkında düz metin gövde.',
  List<BookQuote> quotes = const [],
  List<String> authors = const [],
  List<String> translators = const [],
  List<String> genres = const [],
  String? publisher,
}) {
  return BookDetail(
    book: book ?? _book(),
    body: body,
    quotes: quotes,
    authors: authors,
    translators: translators,
    genres: genres,
    publisher: publisher,
  );
}

/// Kunyesi bastan asagi dolu kayit.
BookDetail _kunyeliDetay() => _detail(
  book: _book(releaseYear: 1866, readAt: DateTime(2026, 3, 14)),
  authors: ['Dostoyevski', 'İkinci Yazar'],
  translators: ['Ergin Altay'],
  genres: ['Roman', 'Klasik'],
  publisher: 'İletişim',
);

Widget _wrap(BooksApi api) => MaterialApp(
  theme: AppTheme.light,
  home: BookDetailScreen(slug: 'suc-ve-ceza', api: api),
);

/// Kunye etiketlerinin tamami; "hicbiri yok" kontrolu icin.
const List<String> _kunyeEtiketleri = [
  'YAZAR',
  'ÇEVİRMEN',
  'YAYINEVİ',
  'BASIM YILI',
  'OKUDUĞUM',
  'TÜR',
];

void main() {
  testWidgets('yukleniyor durumunda donen halka gorunur', (tester) async {
    final api = _FakeBooksApi(completer: Completer<BookDetail>());

    await tester.pumpWidget(_wrap(api));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('hata durumunda mesaj ve Tekrar dene gorunur', (tester) async {
    final api = _FakeBooksApi(error: const ApiException.network());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text(const ApiException.network().userMessage), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Tekrar dene yeniden istek atar', (tester) async {
    final api = _FakeBooksApi(error: const ApiException.timeout());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();
    expect(api.cagriSayisi, 1);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(api.cagriSayisi, 2);
  });

  testWidgets('baslik ve govde gorunur', (tester) async {
    final api = _FakeBooksApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Suç ve Ceza'), findsOneWidget);
    expect(find.text('Kitap hakkında düz metin gövde.'), findsOneWidget);
  });

  testWidgets('AppBar basliksiz, yalnizca geri dugmesi var', (tester) async {
    final api = _FakeBooksApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Baslik govdede; AppBar'da ikinci kez kirpilmis halde tekrarlanmiyor.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Suç ve Ceza'),
      ),
      findsNothing,
    );
  });

  testWidgets('ozet detay ekraninda gosterilmez', (tester) async {
    final api = _FakeBooksApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Ozet liste ogesine ait; detayda govde var.
    expect(find.text('Liste ozeti.'), findsNothing);
  });

  testWidgets('puan varsa 1,5 biciminde basilir', (tester) async {
    final api = _FakeBooksApi(detail: _detail(book: _book(rating: 1.5)));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('1,5'), findsOneWidget);
    // Ust satirda yalnizca puan var; yazar kunyeye ait.
    expect(find.text('Dostoyevski · 1,5'), findsNothing);
  });

  testWidgets('puan yoksa ust satir hic cizilmez', (tester) async {
    final api = _FakeBooksApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Bos metinli bir Text hic kurulmamis olmali.
    expect(find.text(''), findsNothing);
  });

  testWidgets('kunye satirlari dolu kitapta sirayla gorunur', (tester) async {
    final api = _FakeBooksApi(detail: _kunyeliDetay());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    for (final String etiket in _kunyeEtiketleri) {
      expect(find.text(etiket), findsOneWidget, reason: '$etiket satiri yok');
    }

    // Coklu degerler ' · ' ile birlesir.
    expect(find.text('Dostoyevski · İkinci Yazar'), findsOneWidget);
    expect(find.text('Roman · Klasik'), findsOneWidget);
    expect(find.text('Ergin Altay'), findsOneWidget);
    expect(find.text('İletişim'), findsOneWidget);
    expect(find.text('1866'), findsOneWidget);
  });

  testWidgets('okudugum ay ve yil olarak basilir, gun yok', (tester) async {
    final api = _FakeBooksApi(detail: _kunyeliDetay());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Mart 2026'), findsOneWidget);
    expect(find.text('14 Mart 2026'), findsNothing);
  });

  testWidgets('kunyesi tamamen bos kitapta kunye blogu hic basilmaz', (
    tester,
  ) async {
    // Canlida su an dort kitabin dordu de boyle.
    final api = _FakeBooksApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    for (final String etiket in _kunyeEtiketleri) {
      expect(find.text(etiket), findsNothing, reason: '$etiket cizilmemeli');
    }
    // Duz metin author/translator kunyeye SIZMAMALI.
    expect(find.text('Dostoyevski'), findsNothing);
    expect(find.text('Ergin Altay'), findsNothing);
    // Govde yine duruyor; kayit gecerli.
    expect(find.text('Kitap hakkında düz metin gövde.'), findsOneWidget);
  });

  testWidgets('kunyenin yalniz dolu alanlari basilir', (tester) async {
    final api = _FakeBooksApi(
      detail: _detail(book: _book(releaseYear: 1866), genres: ['Roman']),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('BASIM YILI'), findsOneWidget);
    expect(find.text('TÜR'), findsOneWidget);
    // Bos kalanlar hic cizilmez.
    expect(find.text('YAZAR'), findsNothing);
    expect(find.text('ÇEVİRMEN'), findsNothing);
    expect(find.text('YAYINEVİ'), findsNothing);
    expect(find.text('OKUDUĞUM'), findsNothing);
  });

  testWidgets('alintilar cizilir, bos sayfa satiri basilmaz', (tester) async {
    final api = _FakeBooksApi(
      detail: _detail(
        quotes: const [
          BookQuote(order: 1, text: 'Birinci alıntı.', page: ''),
          BookQuote(order: 2, text: 'İkinci alıntı.', page: '42'),
        ],
      ),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Birinci alıntı.'), findsOneWidget);
    expect(find.text('İkinci alıntı.'), findsOneWidget);
    // Dolu sayfa ham haliyle; onek eklenmiyor.
    expect(find.text('42'), findsOneWidget);
    expect(find.text('s. 42'), findsNothing);
  });

  testWidgets('alintisi olmayan kitapta alinti kutusu cizilmez', (
    tester,
  ) async {
    final api = _FakeBooksApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(QuoteBox), findsNothing);
  });

  testWidgets('her alinti icin bir kutu cizilir', (tester) async {
    final api = _FakeBooksApi(
      detail: _detail(
        quotes: const [
          BookQuote(order: 1, text: 'Bir.', page: ''),
          BookQuote(order: 2, text: 'İki.', page: ''),
        ],
      ),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(QuoteBox), findsNWidgets(2));
  });

  testWidgets('kapak yoksa gorsel hic kurulmaz', (tester) async {
    final api = _FakeBooksApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('yukleme surerken ekran kaldirilirsa hata cikmaz', (
    tester,
  ) async {
    final completer = Completer<BookDetail>();
    final api = _FakeBooksApi(completer: completer);

    await tester.pumpWidget(_wrap(api));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Ekran agactan silinir, istek hala ucusuyor.
    await tester.pumpWidget(const SizedBox.shrink());

    completer.complete(_detail());
    await tester.pumpAndSettle();

    // mounted kontrolu olmasaydi olu State uzerinde setState cagrilirdi.
    expect(tester.takeException(), isNull);
  });

  testWidgets('ekran kaldirildiktan sonra gelen hata da sessiz kalir', (
    tester,
  ) async {
    final completer = Completer<BookDetail>();
    final api = _FakeBooksApi(completer: completer);

    await tester.pumpWidget(_wrap(api));
    await tester.pumpWidget(const SizedBox.shrink());

    completer.completeError(const ApiException.network());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
