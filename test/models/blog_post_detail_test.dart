import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/models/blog_post_detail.dart';
import 'package:mertorhan_app/models/post_section.dart';

/// Canli detay yanitinin kisaltilmis hali. Bloklar bilerek karisik
/// sirada ve aralarinda uygulamanin tanimadigi bir tur var.
const String _detay = '''
{
  "id": 2,
  "slug": "scrum-ne-diyor-sertifika-ne-ogretmiyor",
  "title": "Scrum ne diyor, sertifika ne öğretmiyor?",
  "summary": "Kısa özet.",
  "category": "Ürün Yönetimi",
  "published_at": "2026-08-19",
  "reading_time": 9,
  "cover_image": "https://www.mertorhan.com/media/blog/Agile-Scrum.jpeg",
  "is_featured": true,
  "sections": [
    {"order": 30, "kind": "quote", "text": "Alıntı.",
     "heading_level": "", "in_toc": true, "image": null,
     "image_title": "", "image_caption": "", "image_alt": "",
     "quote_source": "", "embed_url": ""},
    {"order": 40, "kind": "gallery", "text": "",
     "heading_level": "", "in_toc": false, "image": null,
     "image_title": "", "image_caption": "", "image_alt": "",
     "quote_source": "", "embed_url": ""},
    {"order": 10, "kind": "paragraph", "text": "Birinci paragraf.",
     "heading_level": "", "in_toc": true, "image": null,
     "image_title": "", "image_caption": "", "image_alt": "",
     "quote_source": "", "embed_url": ""}
  ]
}
''';

void main() {
  test('detay cozulur, liste alanlari BlogPost icinde durur', () {
    final d = BlogPostDetail.fromJson(
      jsonDecode(_detay) as Map<String, dynamic>,
    );

    expect(d.post.slug, 'scrum-ne-diyor-sertifika-ne-ogretmiyor');
    expect(d.post.title, 'Scrum ne diyor, sertifika ne öğretmiyor?');
    expect(d.post.readingTime, 9);
    expect(d.post.publishedAt, DateTime(2026, 8, 19));
  });

  test('bloklar order sirasina gore dizilir', () {
    final d = BlogPostDetail.fromJson(
      jsonDecode(_detay) as Map<String, dynamic>,
    );

    expect(d.sections.map((s) => s.order).toList(), [10, 30]);
  });

  test('taninmayan turdeki blok atlanir, digerleri korunur', () {
    final d = BlogPostDetail.fromJson(
      jsonDecode(_detay) as Map<String, dynamic>,
    );

    // Uc blok geldi, biri ("gallery") taninmadi.
    expect(d.sections.length, 2);
    expect(d.sections.map((s) => s.kind).toList(), [
      SectionKind.paragraph,
      SectionKind.quote,
    ]);
  });
}
