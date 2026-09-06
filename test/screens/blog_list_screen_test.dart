import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/api/blog_api.dart';
import 'package:mertorhan_app/api/paged_response.dart';
import 'package:mertorhan_app/models/blog_post.dart';
import 'package:mertorhan_app/models/blog_post_detail.dart';
import 'package:mertorhan_app/screens/blog_detail_screen.dart';
import 'package:mertorhan_app/screens/blog_list_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';

/// Sahte uygulama: fetchPosts ezilir, gercek istek atilmaz.
///
/// Aga cikan test, internet yavassa veya sunucu kapaliysa kirmizi olur ve
/// kodda hata varmis gibi gorunur. Bu dosyada hicbir test aga cikmaz.
class _FakeBlogApi extends BlogApi {
  _FakeBlogApi({this.page, this.error, this.completer});

  final PagedResponse<BlogPost>? page;
  final Object? error;

  /// Verilirse yanit bu tamamlanana kadar bekletilir.
  final Completer<PagedResponse<BlogPost>>? completer;

  int cagriSayisi = 0;

  /// Detay ekrani acildiginda kullanilir; boylece gezinme testi de aga
  /// cikmaz.
  BlogPostDetail? detail;

  @override
  Future<PagedResponse<BlogPost>> fetchPosts({int page = 1}) async {
    cagriSayisi++;
    if (completer != null) return completer!.future;
    if (error != null) throw error!;
    return this.page!;
  }

  @override
  Future<BlogPostDetail> fetchPost(String slug) async => detail!;
}

BlogPost _post({
  int id = 1,
  String title = 'Ornek baslik',
  String summary = 'Ornek ozet.',
  String? category = 'Ürün Yönetimi',
  String? coverImage,
}) {
  return BlogPost(
    id: id,
    slug: 'ornek-$id',
    title: title,
    summary: summary,
    category: category,
    publishedAt: DateTime(2026, 8, 19),
    readingTime: 9,
    coverImage: coverImage,
    isFeatured: false,
  );
}

PagedResponse<BlogPost> _page(List<BlogPost> posts) =>
    PagedResponse<BlogPost>(items: posts, hasNextPage: false, totalCount: posts.length);

Widget _wrap(BlogApi api) =>
    MaterialApp(theme: AppTheme.light, home: BlogListScreen(api: api));

void main() {
  testWidgets('yukleniyor durumunda donen halka gorunur', (tester) async {
    final api = _FakeBlogApi(completer: Completer<PagedResponse<BlogPost>>());

    await tester.pumpWidget(_wrap(api));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('hata durumunda mesaj ve Tekrar dene gorunur', (tester) async {
    final api = _FakeBlogApi(error: const ApiException.network());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text(const ApiException.network().userMessage), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Tekrar dene yeniden istek atar', (tester) async {
    final api = _FakeBlogApi(error: const ApiException.timeout());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();
    expect(api.cagriSayisi, 1);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(api.cagriSayisi, 2);
  });

  testWidgets('dolu listede yazi basligi gorunur', (tester) async {
    final api = _FakeBlogApi(
      page: _page([_post(title: 'Scrum ne diyor?')]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Scrum ne diyor?'), findsOneWidget);
  });

  testWidgets('bos listede bos durum metni gorunur', (tester) async {
    final api = _FakeBlogApi(page: _page([]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Henüz yazı yok'), findsOneWidget);
  });

  testWidgets('cover_image null olan kayitta yer tutucu cizilir', (
    tester,
  ) async {
    final api = _FakeBlogApi(page: _page([_post(coverImage: null)]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Yer tutucu ikonu var, gercek gorsel yok.
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('category null iken ust satir ayracla baslamaz', (tester) async {
    final api = _FakeBlogApi(page: _page([_post(category: null)]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('19 Ağustos 2026 · 9 dk'), findsOneWidget);
    expect(find.textContaining('· 19 Ağustos'), findsNothing);
  });

  testWidgets('summary bos ise ozet satiri hic cizilmez', (tester) async {
    final api = _FakeBlogApi(
      page: _page([_post(title: 'Ozetsiz', summary: '')]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Ozetsiz'), findsOneWidget);
    // Ust satir + baslik var, ucuncu bir metin yok.
    expect(find.text(''), findsNothing);
  });

  testWidgets('yukleme surerken ekran kaldirilirsa hata cikmaz', (
    tester,
  ) async {
    final completer = Completer<PagedResponse<BlogPost>>();
    final api = _FakeBlogApi(completer: completer);

    await tester.pumpWidget(_wrap(api));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Ekran agactan silinir, istek hala ucusuyor.
    await tester.pumpWidget(const SizedBox.shrink());

    completer.complete(_page([_post()]));
    await tester.pumpAndSettle();

    // mounted kontrolu olmasaydi olu State uzerinde setState cagrilirdi.
    expect(tester.takeException(), isNull);
  });

  testWidgets('tile\'a dokununca detay ekrani acilir', (tester) async {
    final post = _post(title: 'Scrum ne diyor?');
    final api = _FakeBlogApi(page: _page([post]));
    api.detail = BlogPostDetail(post: post, sections: const []);

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(BlogDetailScreen), findsNothing);

    await tester.tap(find.text('Scrum ne diyor?'));
    await tester.pumpAndSettle();

    expect(find.byType(BlogDetailScreen), findsOneWidget);
    // Ayni baslik artik detay ekraninda gorunuyor.
    expect(find.text('Scrum ne diyor?'), findsOneWidget);
  });

  testWidgets('ekran kaldirildiktan sonra gelen hata da sessiz kalir', (
    tester,
  ) async {
    final completer = Completer<PagedResponse<BlogPost>>();
    final api = _FakeBlogApi(completer: completer);

    await tester.pumpWidget(_wrap(api));
    await tester.pumpWidget(const SizedBox.shrink());

    completer.completeError(const ApiException.network());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
