import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/api/blog_api.dart';
import 'package:mertorhan_app/api/books_api.dart';
import 'package:mertorhan_app/api/movies_api.dart';
import 'package:mertorhan_app/api/paged_response.dart';
import 'package:mertorhan_app/api/photos_api.dart';
import 'package:mertorhan_app/models/blog_post.dart';
import 'package:mertorhan_app/models/book.dart';
import 'package:mertorhan_app/models/photo.dart';
import 'package:mertorhan_app/models/review.dart';
import 'package:mertorhan_app/screens/publications_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';

/// Sahte uygulamalar: hicbiri gercek istek atmaz.
class _FakeBlogApi extends BlogApi {
  _FakeBlogApi({this.items = const []});
  final List<BlogPost> items;

  @override
  Future<PagedResponse<BlogPost>> fetchPosts({int page = 1}) async =>
      _paged(items);
}

class _FakeMoviesApi extends MoviesApi {
  _FakeMoviesApi({this.items = const [], this.error, this.completer});
  final List<Review> items;
  final Object? error;
  final Completer<PagedResponse<Review>>? completer;

  @override
  Future<PagedResponse<Review>> fetchReviews({int page = 1}) async {
    if (completer != null) return completer!.future;
    if (error != null) throw error!;
    return _paged(items);
  }
}

class _FakeBooksApi extends BooksApi {
  _FakeBooksApi({this.items = const [], this.error});
  final List<Book> items;
  final Object? error;

  @override
  Future<PagedResponse<Book>> fetchBooks({int page = 1}) async {
    if (error != null) throw error!;
    return _paged(items);
  }
}

class _FakePhotosApi extends PhotosApi {
  _FakePhotosApi({this.items = const [], this.error});
  final List<Photo> items;
  final Object? error;

  @override
  Future<PagedResponse<Photo>> fetchPhotos({int page = 1}) async {
    if (error != null) throw error!;
    return _paged(items);
  }
}

PagedResponse<T> _paged<T>(List<T> items) =>
    PagedResponse<T>(items: items, hasNextPage: false, totalCount: items.length);

BlogPost _post(String title) => BlogPost(
  id: 1,
  slug: 'yazi',
  title: title,
  summary: '',
  category: null,
  publishedAt: DateTime(2026, 8, 19),
  readingTime: 9,
  coverImage: null,
  isFeatured: false,
);

Review _review(String title) => Review(
  id: 2,
  slug: 'film',
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

Book _book(String title) => Book(
  id: 3,
  slug: 'kitap',
  title: title,
  author: 'Bir Yazar',
  translator: '',
  coverImage: null,
  rating: null,
  summary: '',
  publishedAt: DateTime(2026, 8, 13),
  releaseYear: null,
  readAt: null,
  isFeatured: false,
);

Photo _photo(String title) => Photo(
  id: 4,
  title: title,
  image: null,
  thumbnail: null,
  imageWidth: null,
  imageHeight: null,
  category: 'Manzara',
  location: 'Muğla',
  camera: '',
  lens: '',
  iso: '',
  shutterSpeed: '',
  aperture: '',
  focalLength: '',
  takenAt: null,
  order: 0,
);

Widget _wrap(PublicationsApis apis) =>
    MaterialApp(theme: AppTheme.light, home: PublicationsScreen(apis: apis));

/// Bos listelerle acilan varsayilan kurulum.
PublicationsApis _bosApis() => PublicationsApis(
  blog: _FakeBlogApi(),
  movies: _FakeMoviesApi(),
  books: _FakeBooksApi(),
  photos: _FakePhotosApi(),
);

Future<void> _gotoTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dort sekme gorunur', (tester) async {
    await tester.pumpWidget(_wrap(_bosApis()));
    await tester.pumpAndSettle();

    expect(find.text('Yayınlar'), findsOneWidget);
    expect(find.text('Blog'), findsOneWidget);
    expect(find.text('Film ve dizi'), findsOneWidget);
    expect(find.text('Kitap'), findsOneWidget);
    expect(find.text('Galeri'), findsOneWidget);
  });

  testWidgets('her tur kendi verisini gosterir', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PublicationsApis(
          blog: _FakeBlogApi(items: [_post('Bir blog yazisi')]),
          movies: _FakeMoviesApi(items: [_review('Bir film')]),
          books: _FakeBooksApi(items: [_book('Bir kitap')]),
          photos: _FakePhotosApi(items: [_photo('Bir fotograf')]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bir blog yazisi'), findsOneWidget);
    expect(find.text('Bir film'), findsNothing);

    await _gotoTab(tester, 'Film ve dizi');
    expect(find.text('Bir film'), findsOneWidget);
    // Ust satir: tur · yil · puan (Turkce virgul)
    expect(find.text('Film · 2011 · 1,5'), findsOneWidget);

    await _gotoTab(tester, 'Kitap');
    expect(find.text('Bir kitap'), findsOneWidget);
    // Puan null oldugu icin yalnizca yazar, ayrac dusmus.
    expect(find.text('Bir Yazar'), findsOneWidget);

    await _gotoTab(tester, 'Galeri');
    expect(find.text('Bir fotograf'), findsOneWidget);
    expect(find.text('Manzara · Muğla'), findsOneWidget);
  });

  testWidgets('sekme degisince onceki listenin verisi kalmaz', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PublicationsApis(
          blog: _FakeBlogApi(items: [_post('Blog kaydi')]),
          movies: _FakeMoviesApi(items: [_review('Film kaydi')]),
          books: _FakeBooksApi(),
          photos: _FakePhotosApi(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _gotoTab(tester, 'Film ve dizi');
    expect(find.text('Blog kaydi'), findsNothing);

    // Geri donunce blog yine gorunur (durum korunuyor).
    await _gotoTab(tester, 'Blog');
    expect(find.text('Blog kaydi'), findsOneWidget);
  });

  testWidgets('film sekmesi yukleniyor durumunu gosterir', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PublicationsApis(
          blog: _FakeBlogApi(),
          movies: _FakeMoviesApi(completer: Completer<PagedResponse<Review>>()),
          books: _FakeBooksApi(),
          photos: _FakePhotosApi(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Film ve dizi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('film sekmesi hata durumunu gosterir', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PublicationsApis(
          blog: _FakeBlogApi(),
          movies: _FakeMoviesApi(error: const ApiException.network()),
          books: _FakeBooksApi(),
          photos: _FakePhotosApi(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _gotoTab(tester, 'Film ve dizi');

    expect(find.text(const ApiException.network().userMessage), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('kitap sekmesi hata durumunu gosterir', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PublicationsApis(
          blog: _FakeBlogApi(),
          movies: _FakeMoviesApi(),
          books: _FakeBooksApi(error: const ApiException.server(500)),
          photos: _FakePhotosApi(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _gotoTab(tester, 'Kitap');

    expect(
      find.text(const ApiException.server(500).userMessage),
      findsOneWidget,
    );
  });

  testWidgets('galeri sekmesi hata durumunu gosterir', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PublicationsApis(
          blog: _FakeBlogApi(),
          movies: _FakeMoviesApi(),
          books: _FakeBooksApi(),
          photos: _FakePhotosApi(error: const ApiException.timeout()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _gotoTab(tester, 'Galeri');

    expect(find.text(const ApiException.timeout().userMessage), findsOneWidget);
  });

  testWidgets('her turun bos durumu kendi metnini gosterir', (tester) async {
    await tester.pumpWidget(_wrap(_bosApis()));
    await tester.pumpAndSettle();

    expect(find.text('Henüz yazı yok'), findsOneWidget);

    await _gotoTab(tester, 'Film ve dizi');
    expect(find.text('Henüz film veya dizi yok'), findsOneWidget);

    await _gotoTab(tester, 'Kitap');
    expect(find.text('Henüz kitap yok'), findsOneWidget);

    await _gotoTab(tester, 'Galeri');
    expect(find.text('Henüz fotoğraf yok'), findsOneWidget);
  });

  testWidgets('film ve kitap ogeleri dokunulabilir degil', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PublicationsApis(
          blog: _FakeBlogApi(),
          movies: _FakeMoviesApi(items: [_review('Bir film')]),
          books: _FakeBooksApi(),
          photos: _FakePhotosApi(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _gotoTab(tester, 'Film ve dizi');

    // Detay ekrani yok; onTap verilmedigi icin InkWell tepkisiz olmali.
    final InkWell inkWell = tester.widget<InkWell>(
      find.ancestor(of: find.text('Bir film'), matching: find.byType(InkWell)),
    );
    expect(inkWell.onTap, isNull);
  });
}
