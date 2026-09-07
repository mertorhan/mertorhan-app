import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/api/books_api.dart';
import 'package:mertorhan_app/api/paged_response.dart';
import 'package:mertorhan_app/models/book.dart';
import 'package:mertorhan_app/models/book_detail.dart';
import 'package:mertorhan_app/models/filter_option.dart';
import 'package:mertorhan_app/models/filter_options.dart';
import 'package:mertorhan_app/models/filter_selection.dart';
import 'package:mertorhan_app/screens/book_detail_screen.dart';
import 'package:mertorhan_app/screens/book_list_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/filter_bar.dart';
import 'package:mertorhan_app/widgets/media_tile.dart';

/// Sahte uygulama: iki uc de ezilir, gercek istek atilmaz.
///
/// Bu dosyada hicbir test aga cikmaz.
class _FakeBooksApi extends BooksApi {
  _FakeBooksApi({this.page, this.error, this.options, this.optionsError});

  /// fetchFilterOptions ezilmezse uretim govdesi calisir ve test GERCEK
  /// aga cikar; sahte API gercek sinifi extend ediyor.
  final FilterOptions? options;
  final Object? optionsError;

  /// Ekranin fetch'e gecirdigi son secim; "dogru selection ile cagrildi
  /// mi" sorusu ancak boyle cevaplanabilir.
  FilterSelection? sonSecim;
  int cagriSayisi = 0;

  final PagedResponse<Book>? page;
  final Object? error;

  /// Detay ekrani acildiginda kullanilir; boylece gezinme testi de aga
  /// cikmaz.
  BookDetail? detail;

  @override
  Future<PagedResponse<Book>> fetchBooks({
    int page = 1,
    FilterSelection? selection,
  }) async {
    sonSecim = selection;
    cagriSayisi++;
    if (error != null) throw error!;
    return this.page!;
  }

  @override
  Future<FilterOptions> fetchFilterOptions() async {
    if (optionsError != null) throw optionsError!;
    return options ?? const FilterOptions.empty();
  }

  @override
  Future<BookDetail> fetchBook(String slug) async => detail!;
}

Book _book({String title = 'Suç ve Ceza'}) => Book(
  id: 1,
  slug: 'suc-ve-ceza',
  title: title,
  author: 'Dostoyevski',
  translator: '',
  coverImage: null,
  rating: null,
  summary: '',
  publishedAt: DateTime(2026, 8, 13),
  releaseYear: null,
  readAt: null,
  isFeatured: false,
);

PagedResponse<Book> _page(List<Book> items) => PagedResponse<Book>(
  items: items,
  hasNextPage: false,
  totalCount: items.length,
);

BookDetail _detail(Book book) => BookDetail(
  book: book,
  body: 'Düz metin gövde.',
  quotes: const [],
  authors: const [],
  translators: const [],
  genres: const [],
  publisher: null,
);

/// Ekran sekme govdesi: kendi Scaffold'u yok, uretimde onu
/// PublicationsScreen sagliyor. MediaTile'daki InkWell Material atasi
/// istedigi icin test de Scaffold ile sarmaliyor.
Widget _wrap(BooksApi api) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: BookListScreen(api: api)),
);

void main() {
  testWidgets('dolu listede kitap basligi gorunur', (tester) async {
    final api = _FakeBooksApi(page: _page([_book()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Suç ve Ceza'), findsOneWidget);
  });

  testWidgets('oge artik dokunulabilir', (tester) async {
    final api = _FakeBooksApi(page: _page([_book()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    final InkWell inkWell = tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Suç ve Ceza'),
        matching: find.byType(InkWell),
      ),
    );
    expect(inkWell.onTap, isNotNull);
  });

  testWidgets('tile\'a dokununca detay ekrani acilir', (tester) async {
    final book = _book();
    final api = _FakeBooksApi(page: _page([book]));
    api.detail = _detail(book);

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(BookDetailScreen), findsNothing);

    await tester.tap(find.text('Suç ve Ceza'));
    await tester.pumpAndSettle();

    expect(find.byType(BookDetailScreen), findsOneWidget);
    // Detay ekrani listenin sahte uygulamasini kullandi, aga cikilmadi.
    expect(find.text('Düz metin gövde.'), findsOneWidget);
    // Liste ogesi artik ekranda degil.
    expect(find.byType(MediaTile), findsNothing);
  });

  testWidgets('hata durumunda mesaj ve Tekrar dene gorunur', (tester) async {
    final api = _FakeBooksApi(error: const ApiException.network());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text(const ApiException.network().userMessage), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('bos listede bos durum metni gorunur', (tester) async {
    final api = _FakeBooksApi(page: _page([]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Henüz kitap yok'), findsOneWidget);
  });

  // --- KB-112: filtre arayuzu ---

  testWidgets('filtre cubugu listenin ustunde gorunur', (tester) async {
    final api = _FakeBooksApi(page: _page([_book()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(FilterBar), findsOneWidget);
    expect(find.text('Filtrele'), findsOneWidget);
    expect(find.text('Temizle'), findsNothing);
  });

  testWidgets('secim yapinca liste yeni selection ile yeniden cekilir', (
    tester,
  ) async {
    final api = _FakeBooksApi(
      page: _page([_book()]),
      options: const FilterOptions(
        groups: {
          'author': [FilterOption(value: '3', label: 'Dostoyevski', count: 2)],
        },
      ),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();
    expect(api.cagriSayisi, 1);

    await tester.tap(find.text('Filtrele'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yazar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dostoyevski (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uygula'));
    await tester.pumpAndSettle();

    expect(api.cagriSayisi, 2);
    expect(api.sonSecim, const FilterSelection.empty().toggle('author', '3'));
    expect(find.text('Filtrele (1)'), findsOneWidget);
  });

  testWidgets('Temizle secimi sifirlar', (tester) async {
    final api = _FakeBooksApi(
      page: _page([_book()]),
      options: const FilterOptions(
        groups: {
          'author': [FilterOption(value: '3', label: 'Dostoyevski', count: 2)],
        },
      ),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filtrele'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yazar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dostoyevski (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uygula'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Temizle'));
    await tester.pumpAndSettle();

    expect(api.sonSecim, const FilterSelection.empty());
    expect(find.text('Temizle'), findsNothing);
  });

  testWidgets('secim varken bos sonuc farkli mesaj gosterir', (tester) async {
    final api = _FakeBooksApi(
      page: _page([]),
      options: const FilterOptions(
        groups: {
          'author': [FilterOption(value: '3', label: 'Dostoyevski', count: 2)],
        },
      ),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();
    expect(find.text('Henüz kitap yok'), findsOneWidget);

    await tester.tap(find.text('Filtrele'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yazar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dostoyevski (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uygula'));
    await tester.pumpAndSettle();

    expect(find.text('Bu filtreye uyan kitap yok'), findsOneWidget);
  });

  testWidgets('secenek bos donerse panel acilmaz, SnackBar cikar', (
    tester,
  ) async {
    // CANLIDAKI DURUM: /filters/books/ su an {} donduruyor.
    final api = _FakeBooksApi(page: _page([_book()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filtrele'));
    await tester.pumpAndSettle();

    expect(find.text('Şu an filtrelenecek bir şey yok.'), findsOneWidget);
    expect(find.text('Uygula'), findsNothing);
    // Liste calismaya devam ediyor.
    expect(find.text('Suç ve Ceza'), findsOneWidget);
  });

  testWidgets('secenek cekimi hata verirse ekran calismaya devam eder', (
    tester,
  ) async {
    final api = _FakeBooksApi(
      page: _page([_book()]),
      optionsError: const ApiException.timeout(),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filtrele'));
    await tester.pumpAndSettle();

    expect(find.text(const ApiException.timeout().userMessage), findsOneWidget);
    expect(find.text('Suç ve Ceza'), findsOneWidget);
  });
}
