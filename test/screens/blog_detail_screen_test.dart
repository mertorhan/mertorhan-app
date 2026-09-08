import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/api/blog_api.dart';
import 'package:mertorhan_app/models/blog_post.dart';
import 'package:mertorhan_app/models/blog_post_detail.dart';
import 'package:mertorhan_app/models/post_section.dart';
import 'package:mertorhan_app/screens/blog_detail_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/quote_box.dart';
import 'package:mertorhan_app/widgets/site_markdown.dart';

/// Sahte uygulama: fetchPost ezilir, gercek istek atilmaz.
class _FakeBlogApi extends BlogApi {
  _FakeBlogApi({this.detail, this.error, this.completer});

  final BlogPostDetail? detail;
  final Object? error;
  final Completer<BlogPostDetail>? completer;

  @override
  Future<BlogPostDetail> fetchPost(String slug) async {
    if (completer != null) return completer!.future;
    if (error != null) throw error!;
    return detail!;
  }
}

BlogPost _post({String? coverImage}) => BlogPost(
  id: 2,
  slug: 'ornek-yazi',
  title: 'Scrum ne diyor?',
  summary: 'Kisa ozet.',
  category: 'Ürün Yönetimi',
  publishedAt: DateTime(2026, 8, 19),
  readingTime: 9,
  coverImage: coverImage,
  isFeatured: false,
);

/// Gercek yanittaki duz semayi taklit eder: tum alanlar her blokta var.
PostSection _section({
  required int order,
  required SectionKind kind,
  String text = '',
  String headingLevel = '',
  String? image,
  String imageTitle = '',
  String imageCaption = '',
  String quoteSource = '',
}) => PostSection(
  order: order,
  kind: kind,
  text: text,
  headingLevel: headingLevel,
  inToc: true,
  image: image,
  imageTitle: imageTitle,
  imageCaption: imageCaption,
  imageAlt: '',
  quoteSource: quoteSource,
  embedUrl: '',
);

BlogPostDetail _detail(List<PostSection> sections, {String? coverImage}) =>
    BlogPostDetail(post: _post(coverImage: coverImage), sections: sections);

Widget _wrap(BlogApi api) => MaterialApp(
  theme: AppTheme.light,
  home: BlogDetailScreen(slug: 'ornek-yazi', api: api),
);

void main() {
  testWidgets('yukleniyor durumunda donen halka gorunur', (tester) async {
    final api = _FakeBlogApi(completer: Completer<BlogPostDetail>());

    await tester.pumpWidget(_wrap(api));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('hata durumunda mesaj ve Tekrar dene gorunur', (tester) async {
    final api = _FakeBlogApi(error: const ApiException.server(404));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(
      find.text(const ApiException.server(404).userMessage),
      findsOneWidget,
    );
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('dolu ekranda baslik ve paragraf metni gorunur', (tester) async {
    final api = _FakeBlogApi(
      detail: _detail([
        _section(
          order: 10,
          kind: SectionKind.paragraph,
          text: 'Birinci paragrafin metni.',
        ),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Scrum ne diyor?'), findsOneWidget);
    expect(find.text('Birinci paragrafin metni.'), findsOneWidget);
    // Ust satir da kurulmus olmali.
    expect(find.text('Ürün Yönetimi · 19 Ağustos 2026 · 9 dk'), findsOneWidget);
  });

  testWidgets('heading blogu cizilir', (tester) async {
    final api = _FakeBlogApi(
      detail: _detail([
        _section(
          order: 10,
          kind: SectionKind.heading,
          text: 'Scrum neden var?',
          headingLevel: 'h2',
        ),
        _section(
          order: 20,
          kind: SectionKind.heading,
          text: 'Alt baslik',
          headingLevel: 'h3',
        ),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Scrum neden var?'), findsOneWidget);
    expect(find.text('Alt baslik'), findsOneWidget);

    // h2 ve h3 farkli katmanlardan gelmeli, ayni stille cizilmemeli.
    final h2 = tester.widget<Text>(find.text('Scrum neden var?'));
    final h3 = tester.widget<Text>(find.text('Alt baslik'));
    expect(h2.style, isNot(equals(h3.style)));
  });

  testWidgets('quote blogu cizilir, kaynak varsa gorunur', (tester) async {
    final api = _FakeBlogApi(
      detail: _detail([
        _section(
          order: 10,
          kind: SectionKind.quote,
          text: 'Alintinin metni.',
          quoteSource: 'Scrum Guide',
        ),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Alintinin metni.'), findsOneWidget);
    expect(find.text('Scrum Guide'), findsOneWidget);
  });

  testWidgets('quote_source bos ise kaynak satiri cizilmez', (tester) async {
    final api = _FakeBlogApi(
      detail: _detail([
        _section(
          order: 10,
          kind: SectionKind.quote,
          text: 'Kaynaksiz alinti.',
          quoteSource: '',
        ),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Kaynaksiz alinti.'), findsOneWidget);
    // Bos metinli bir Text hic kurulmamis olmali.
    expect(find.text(''), findsNothing);
  });

  testWidgets('image null ise blok hic cizilmez', (tester) async {
    final api = _FakeBlogApi(
      detail: _detail([
        _section(
          order: 10,
          kind: SectionKind.image,
          image: null,
          imageTitle: 'Gorsel basligi',
          imageCaption: 'Gorsel altyazisi',
        ),
        _section(
          order: 20,
          kind: SectionKind.paragraph,
          text: 'Devam eden paragraf.',
        ),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Gorsel yoksa basligi ve altyazisi da cizilmez.
    expect(find.text('Gorsel basligi'), findsNothing);
    expect(find.text('Gorsel altyazisi'), findsNothing);
    expect(find.byType(Image), findsNothing);
    // Sonraki blok etkilenmemis olmali.
    expect(find.text('Devam eden paragraf.'), findsOneWidget);
  });

  testWidgets('taninmayan kind ekrani cokertmez, blok atlanir', (
    tester,
  ) async {
    // Sunucudan gelen ham JSON: aradaki blok uygulamanin bilmedigi turde.
    final detail = BlogPostDetail.fromJson({
      'id': 2,
      'slug': 'ornek-yazi',
      'title': 'Scrum ne diyor?',
      'summary': 'Kisa ozet.',
      'category': 'Ürün Yönetimi',
      'published_at': '2026-08-19',
      'reading_time': 9,
      'cover_image': null,
      'is_featured': false,
      'sections': [
        {
          'order': 10,
          'kind': 'paragraph',
          'text': 'Once gelen paragraf.',
          'heading_level': '',
          'in_toc': true,
          'image': null,
          'image_title': '',
          'image_caption': '',
          'image_alt': '',
          'quote_source': '',
          'embed_url': '',
        },
        {
          'order': 20,
          'kind': 'gallery',
          'text': 'Bu blok bilinmiyor.',
          'heading_level': '',
          'in_toc': false,
          'image': null,
          'image_title': '',
          'image_caption': '',
          'image_alt': '',
          'quote_source': '',
          'embed_url': '',
        },
      ],
    });

    await tester.pumpWidget(_wrap(_FakeBlogApi(detail: detail)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Once gelen paragraf.'), findsOneWidget);
    expect(find.text('Bu blok bilinmiyor.'), findsNothing);
  });

  testWidgets('yukleme surerken ekran kaldirilirsa hata cikmaz', (
    tester,
  ) async {
    final completer = Completer<BlogPostDetail>();

    await tester.pumpWidget(_wrap(_FakeBlogApi(completer: completer)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Kullanici geri dondu: ekran agactan silindi, istek hala ucusuyor.
    await tester.pumpWidget(const SizedBox.shrink());

    completer.complete(
      _detail([_section(order: 10, kind: SectionKind.paragraph, text: 'Gec.')]),
    );
    await tester.pumpAndSettle();

    // mounted kontrolu olmasaydi olu State uzerinde setState cagrilirdi.
    expect(tester.takeException(), isNull);
  });

  testWidgets('ekran kaldirildiktan sonra gelen hata da sessiz kalir', (
    tester,
  ) async {
    final completer = Completer<BlogPostDetail>();

    await tester.pumpWidget(_wrap(_FakeBlogApi(completer: completer)));
    await tester.pumpWidget(const SizedBox.shrink());

    completer.completeError(const ApiException.server(404));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  // --- KB-113: markdown baglama ---

  testWidgets('paragraf blogu SiteMarkdown ile ciziliyor', (tester) async {
    // Sitede {{ section.text|markdown }}; mobil de ayni yerden geciyor.
    final api = _FakeBlogApi(
      detail: _detail([
        _section(
          order: 10,
          kind: SectionKind.paragraph,
          text: 'Duz bir paragraf.',
        ),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(SiteMarkdown), findsOneWidget);
    expect(find.text('Duz bir paragraf.'), findsOneWidget);
  });

  testWidgets('paragrafta kalin isleniyor, yildizlar ekranda YOK', (
    tester,
  ) async {
    final api = _FakeBlogApi(
      detail: _detail([
        _section(
          order: 10,
          kind: SectionKind.paragraph,
          text: 'Bu **kalin** bir paragraf.',
        ),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Bu kalin bir paragraf.'), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
  });

  testWidgets('alinti blogu markdown ile ciziliyor', (tester) async {
    // Sitede alinti blogu da {{ section.text|markdown }} filtresinden
    // geciyor; QuoteBox'a markdown: true veriliyor.
    final api = _FakeBlogApi(
      detail: _detail([
        _section(
          order: 10,
          kind: SectionKind.quote,
          text: 'Bu **kalin** bir alinti.',
          quoteSource: 'Scrum Guide',
        ),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(QuoteBox), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(QuoteBox),
        matching: find.byType(SiteMarkdown),
      ),
      findsOneWidget,
    );
    expect(find.text('Bu kalin bir alinti.'), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
    // Kaynak satiri kutu stiline ait, markdown'dan gecmiyor.
    expect(find.text('Scrum Guide'), findsOneWidget);
  });

  testWidgets('markdown alinti ITALIGINI koruyor', (tester) async {
    // Olculdu: SiteMarkdown ortam DefaultTextStyle'ini okumuyor, italik
    // yalnizca tema bodyLarge uzerinden gecebiliyor. QuoteBox bunu boyle
    // yapiyor; test o mekanizmanin ayakta oldugunu civiliyor.
    final api = _FakeBlogApi(
      detail: _detail([
        _section(order: 10, kind: SectionKind.quote, text: 'Alinti metni.'),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    final Text w = tester.widget<Text>(find.text('Alinti metni.'));
    final TextStyle? stil = w.textSpan?.style ?? w.style;
    expect(stil?.fontStyle, FontStyle.italic);
  });

  testWidgets('baslik blogu markdown DEGIL, duz Text', (tester) async {
    // Sitede baslik markdown filtresinden GECMIYOR.
    final api = _FakeBlogApi(
      detail: _detail([
        _section(
          order: 10,
          kind: SectionKind.heading,
          text: 'Bu **kalin** baslik',
          headingLevel: 'h2',
        ),
      ]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(SiteMarkdown), findsNothing);
    // Yildizlar ekranda duruyor.
    expect(find.text('Bu **kalin** baslik'), findsOneWidget);
  });
}
