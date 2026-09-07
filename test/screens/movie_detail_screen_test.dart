import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/api/movies_api.dart';
import 'package:mertorhan_app/models/review.dart';
import 'package:mertorhan_app/models/review_detail.dart';
import 'package:mertorhan_app/screens/movie_detail_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';

/// Sahte uygulama: fetchReview ezilir, gercek istek atilmaz.
///
/// Aga cikan test, internet yavassa veya sunucu kapaliysa kirmizi olur ve
/// kodda hata varmis gibi gorunur. Bu dosyada hicbir test aga cikmaz.
class _FakeMoviesApi extends MoviesApi {
  _FakeMoviesApi({this.detail, this.error, this.completer});

  final ReviewDetail? detail;
  final Object? error;

  /// Verilirse yanit bu tamamlanana kadar bekletilir.
  final Completer<ReviewDetail>? completer;

  int cagriSayisi = 0;

  @override
  Future<ReviewDetail> fetchReview(String slug) async {
    cagriSayisi++;
    if (completer != null) return completer!.future;
    if (error != null) throw error!;
    return detail!;
  }
}

/// coverImage varsayilan null: Image.network kurulmaz, test aga cikmaz.
Review _review({
  String title = 'Crazy, Stupid, Love.',
  ContentKind? contentKind = ContentKind.film,
  num? rating,
  int? releaseYear,
  DateTime? watchedAt,
  String? coverImage,
}) {
  return Review(
    id: 1,
    slug: 'crazy-stupid-love',
    title: title,
    contentKind: contentKind,
    coverImage: coverImage,
    releaseYear: releaseYear,
    rating: rating,
    summary: 'Liste ozeti.',
    publishedAt: DateTime(2026, 8, 16),
    watchedAt: watchedAt,
    isFeatured: false,
  );
}

ReviewDetail _detail({
  Review? review,
  String body = 'Film hakkında düz metin gövde.',
  List<String> directors = const [],
  List<String> screenwriters = const [],
  List<String> actors = const [],
  List<String> genres = const [],
}) {
  return ReviewDetail(
    review: review ?? _review(),
    body: body,
    directors: directors,
    screenwriters: screenwriters,
    actors: actors,
    genres: genres,
  );
}

/// Kunyesi bastan asagi dolu kayit (canli crazy-stupid-love).
ReviewDetail _kunyeliDetay() => _detail(
  review: _review(
    rating: 1.5,
    releaseYear: 2011,
    watchedAt: DateTime(2026, 3, 14),
  ),
  directors: ['Glenn Ficarra', 'John Requa'],
  screenwriters: ['Dan Fogelman'],
  actors: ['Julianne Moore', 'Ryan Gosling', 'Steve Carell'],
  genres: ['Comedy'],
);

Widget _wrap(MoviesApi api) => MaterialApp(
  theme: AppTheme.light,
  home: MovieDetailScreen(slug: 'crazy-stupid-love', api: api),
);

/// Kunye etiketlerinin tamami; "hicbiri yok" kontrolu icin.
const List<String> _kunyeEtiketleri = [
  'YÖNETMEN',
  'SENARİST',
  'OYUNCULAR',
  'YAPIM YILI',
  'İZLEDİĞİM',
  'TÜR',
];

void main() {
  testWidgets('yukleniyor durumunda donen halka gorunur', (tester) async {
    final api = _FakeMoviesApi(completer: Completer<ReviewDetail>());

    await tester.pumpWidget(_wrap(api));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('hata durumunda mesaj ve Tekrar dene gorunur', (tester) async {
    final api = _FakeMoviesApi(error: const ApiException.network());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text(const ApiException.network().userMessage), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Tekrar dene yeniden istek atar', (tester) async {
    final api = _FakeMoviesApi(error: const ApiException.timeout());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();
    expect(api.cagriSayisi, 1);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(api.cagriSayisi, 2);
  });

  testWidgets('baslik ve govde gorunur', (tester) async {
    final api = _FakeMoviesApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Crazy, Stupid, Love.'), findsOneWidget);
    expect(find.text('Film hakkında düz metin gövde.'), findsOneWidget);
  });

  testWidgets('AppBar basliksiz, yalnizca geri dugmesi var', (tester) async {
    final api = _FakeMoviesApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Baslik govdede; AppBar'da ikinci kez kirpilmis halde tekrarlanmiyor.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Crazy, Stupid, Love.'),
      ),
      findsNothing,
    );
  });

  testWidgets('ozet detay ekraninda gosterilmez', (tester) async {
    final api = _FakeMoviesApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Ozet liste ogesine ait; detayda govde var.
    expect(find.text('Liste ozeti.'), findsNothing);
  });

  testWidgets('ust satir tur ve puan; yapim yili TEKRARLANMAZ', (tester) async {
    final api = _FakeMoviesApi(detail: _kunyeliDetay());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Film · 1,5'), findsOneWidget);
    // Liste ust satiri "Film · 2011 · 1,5"; detayda yil kunyeye ait.
    expect(find.text('Film · 2011 · 1,5'), findsNothing);
    // Yil yalnizca kunyede, tek kez.
    expect(find.text('2011'), findsOneWidget);
  });

  testWidgets('puan yoksa ust satirda yalniz tur kalir', (tester) async {
    final api = _FakeMoviesApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Film'), findsOneWidget);
  });

  testWidgets('dizi turu Dizi diye etiketlenir', (tester) async {
    final api = _FakeMoviesApi(
      detail: _detail(review: _review(contentKind: ContentKind.dizi)),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Dizi'), findsOneWidget);
    expect(find.text('Film'), findsNothing);
  });

  testWidgets('taninmayan tur ve puan yoksa ust satir hic cizilmez', (
    tester,
  ) async {
    final api = _FakeMoviesApi(
      detail: _detail(review: _review(contentKind: null)),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Bos metinli bir Text hic kurulmamis olmali.
    expect(find.text(''), findsNothing);
  });

  testWidgets('kunye satirlari dolu filmde sirayla gorunur', (tester) async {
    final api = _FakeMoviesApi(detail: _kunyeliDetay());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    for (final String etiket in _kunyeEtiketleri) {
      expect(find.text(etiket), findsOneWidget, reason: '$etiket satiri yok');
    }

    // Coklu degerler ' · ' ile birlesir.
    expect(find.text('Glenn Ficarra · John Requa'), findsOneWidget);
    expect(find.text('Dan Fogelman'), findsOneWidget);
    expect(
      find.text('Julianne Moore · Ryan Gosling · Steve Carell'),
      findsOneWidget,
    );
    expect(find.text('Comedy'), findsOneWidget);
  });

  testWidgets('oyuncu satiri BASROL degil OYUNCULAR diye etiketlenir', (
    tester,
  ) async {
    final api = _FakeMoviesApi(detail: _kunyeliDetay());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Sunucu alfabetik donduruyor, basrol sirasi korunmuyor; etiket bunu
    // ima etmemeli.
    expect(find.text('OYUNCULAR'), findsOneWidget);
    expect(find.text('BAŞROL'), findsNothing);
  });

  testWidgets('izledigim ay ve yil olarak basilir, gun yok', (tester) async {
    final api = _FakeMoviesApi(detail: _kunyeliDetay());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Mart 2026'), findsOneWidget);
    expect(find.text('14 Mart 2026'), findsNothing);
  });

  testWidgets('kunyesi tamamen bos filmde kunye blogu hic basilmaz', (
    tester,
  ) async {
    final api = _FakeMoviesApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    for (final String etiket in _kunyeEtiketleri) {
      expect(find.text(etiket), findsNothing, reason: '$etiket cizilmemeli');
    }
    // Govde yine duruyor; kayit gecerli.
    expect(find.text('Film hakkında düz metin gövde.'), findsOneWidget);
  });

  testWidgets('kunyenin yalniz dolu alanlari basilir', (tester) async {
    // Canli glass-onion kaydi: dort liste bos, yalnizca yil dolu.
    final api = _FakeMoviesApi(
      detail: _detail(review: _review(releaseYear: 2022)),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('YAPIM YILI'), findsOneWidget);
    expect(find.text('2022'), findsOneWidget);
    // Bos kalanlar hic cizilmez.
    expect(find.text('YÖNETMEN'), findsNothing);
    expect(find.text('SENARİST'), findsNothing);
    expect(find.text('OYUNCULAR'), findsNothing);
    expect(find.text('İZLEDİĞİM'), findsNothing);
    expect(find.text('TÜR'), findsNothing);
  });

  testWidgets('kapak yoksa gorsel hic kurulmaz', (tester) async {
    final api = _FakeMoviesApi(detail: _detail());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('yukleme surerken ekran kaldirilirsa hata cikmaz', (
    tester,
  ) async {
    final completer = Completer<ReviewDetail>();
    final api = _FakeMoviesApi(completer: completer);

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
    final completer = Completer<ReviewDetail>();
    final api = _FakeMoviesApi(completer: completer);

    await tester.pumpWidget(_wrap(api));
    await tester.pumpWidget(const SizedBox.shrink());

    completer.completeError(const ApiException.network());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
