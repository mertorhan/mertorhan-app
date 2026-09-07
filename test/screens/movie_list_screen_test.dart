import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/api/movies_api.dart';
import 'package:mertorhan_app/api/paged_response.dart';
import 'package:mertorhan_app/models/review.dart';
import 'package:mertorhan_app/models/review_detail.dart';
import 'package:mertorhan_app/screens/movie_detail_screen.dart';
import 'package:mertorhan_app/screens/movie_list_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/media_tile.dart';

/// Sahte uygulama: iki uc de ezilir, gercek istek atilmaz.
///
/// Bu dosyada hicbir test aga cikmaz.
class _FakeMoviesApi extends MoviesApi {
  _FakeMoviesApi({this.page, this.error});

  final PagedResponse<Review>? page;
  final Object? error;

  /// Detay ekrani acildiginda kullanilir; boylece gezinme testi de aga
  /// cikmaz.
  ReviewDetail? detail;

  @override
  Future<PagedResponse<Review>> fetchReviews({int page = 1}) async {
    if (error != null) throw error!;
    return this.page!;
  }

  @override
  Future<ReviewDetail> fetchReview(String slug) async => detail!;
}

Review _review({String title = 'Crazy, Stupid, Love.'}) => Review(
  id: 1,
  slug: 'crazy-stupid-love',
  title: title,
  contentKind: ContentKind.film,
  coverImage: null,
  releaseYear: 2011,
  rating: 1.5,
  summary: '',
  publishedAt: DateTime(2026, 8, 16),
  watchedAt: null,
  isFeatured: false,
);

PagedResponse<Review> _page(List<Review> items) => PagedResponse<Review>(
  items: items,
  hasNextPage: false,
  totalCount: items.length,
);

ReviewDetail _detail(Review review) => ReviewDetail(
  review: review,
  body: 'Düz metin gövde.',
  directors: const [],
  screenwriters: const [],
  actors: const [],
  genres: const [],
);

/// Ekran sekme govdesi: kendi Scaffold'u yok, uretimde onu
/// PublicationsScreen sagliyor. MediaTile'daki InkWell Material atasi
/// istedigi icin test de Scaffold ile sarmaliyor.
Widget _wrap(MoviesApi api) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: MovieListScreen(api: api)),
);

void main() {
  testWidgets('dolu listede film basligi gorunur', (tester) async {
    final api = _FakeMoviesApi(page: _page([_review()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Crazy, Stupid, Love.'), findsOneWidget);
    // Liste ust satirinda yil VAR; detaydan farki bu.
    expect(find.text('Film · 2011 · 1,5'), findsOneWidget);
  });

  testWidgets('oge artik dokunulabilir', (tester) async {
    final api = _FakeMoviesApi(page: _page([_review()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    final InkWell inkWell = tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Crazy, Stupid, Love.'),
        matching: find.byType(InkWell),
      ),
    );
    expect(inkWell.onTap, isNotNull);
  });

  testWidgets('tile\'a dokununca detay ekrani acilir', (tester) async {
    final review = _review();
    final api = _FakeMoviesApi(page: _page([review]));
    api.detail = _detail(review);

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(MovieDetailScreen), findsNothing);

    await tester.tap(find.text('Crazy, Stupid, Love.'));
    await tester.pumpAndSettle();

    expect(find.byType(MovieDetailScreen), findsOneWidget);
    // Detay ekrani listenin sahte uygulamasini kullandi, aga cikilmadi.
    expect(find.text('Düz metin gövde.'), findsOneWidget);
    // Liste ogesi artik ekranda degil.
    expect(find.byType(MediaTile), findsNothing);
  });

  testWidgets('hata durumunda mesaj ve Tekrar dene gorunur', (tester) async {
    final api = _FakeMoviesApi(error: const ApiException.network());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text(const ApiException.network().userMessage), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('bos listede bos durum metni gorunur', (tester) async {
    final api = _FakeMoviesApi(page: _page([]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Henüz film veya dizi yok'), findsOneWidget);
  });
}
