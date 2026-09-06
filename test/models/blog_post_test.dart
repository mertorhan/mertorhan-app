import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/blog_post.dart';

/// Bu dosyadaki hicbir test aga cikmaz. Ornek JSON metinleri asagida sabit
/// duruyor; gercek istek atan test, internet yavassa veya sunucu kapaliysa
/// kirmizi olur ve kodda hata varmis gibi gorunur.
///
/// Tam dolu kayit, canli uctan alinan gercek yanittan kisaltildi.
const String _tamDolu = '''
{
  "id": 2,
  "slug": "scrum-ne-diyor-sertifika-ne-ogretmiyor",
  "title": "Scrum ne diyor, sertifika ne öğretmiyor?",
  "summary": "Scrum Guide'ın söylediklerini günlük dille tekrar yazdım.",
  "category": "Ürün Yönetimi",
  "published_at": "2026-08-19",
  "reading_time": 9,
  "cover_image": "https://www.mertorhan.com/media/blog/Agile-Scrum.jpeg",
  "is_featured": true
}
''';

const String _bosSummary = '''
{
  "id": 3, "slug": "bos-ozet", "title": "Ozeti olmayan yazi",
  "summary": "",
  "category": "Deneme", "published_at": "2026-01-05", "reading_time": 2,
  "cover_image": "https://www.mertorhan.com/media/blog/x.jpeg",
  "is_featured": false
}
''';

const String _nullCategory = '''
{
  "id": 4, "slug": "kategorisiz", "title": "Kategorisiz yazi",
  "summary": "Kisa ozet.",
  "category": null,
  "published_at": "2026-02-10", "reading_time": 4,
  "cover_image": "https://www.mertorhan.com/media/blog/y.jpeg",
  "is_featured": false
}
''';

const String _nullCoverImage = '''
{
  "id": 5, "slug": "kapaksiz", "title": "Kapak gorseli olmayan yazi",
  "summary": "Kisa ozet.",
  "category": "Deneme", "published_at": "2026-03-01", "reading_time": 6,
  "cover_image": null,
  "is_featured": false
}
''';

/// 'title' alani hic yok, 'reading_time' metin gelmis.
const String _bozuk = '''
{
  "id": 6, "slug": "bozuk",
  "summary": "Kisa ozet.",
  "category": null, "published_at": "2026-04-01", "reading_time": "alti",
  "cover_image": null, "is_featured": false
}
''';

/// 'published_at' tarih degil.
const String _bozukTarih = '''
{
  "id": 7, "slug": "bozuk-tarih", "title": "Tarihi bozuk yazi",
  "summary": "Kisa ozet.",
  "category": null, "published_at": "dun", "reading_time": 3,
  "cover_image": null, "is_featured": false
}
''';

BlogPost _parse(String source) =>
    BlogPost.fromJson(jsonDecode(source) as Map<String, dynamic>);

void main() {
  test('tam dolu kayit cozulur', () {
    final post = _parse(_tamDolu);

    expect(post.id, 2);
    expect(post.slug, 'scrum-ne-diyor-sertifika-ne-ogretmiyor');
    expect(post.title, 'Scrum ne diyor, sertifika ne öğretmiyor?');
    expect(post.summary, isNotEmpty);
    expect(post.category, 'Ürün Yönetimi');
    expect(post.publishedAt, DateTime(2026, 8, 19));
    expect(post.readingTime, 9);
    expect(post.coverImage, endsWith('Agile-Scrum.jpeg'));
    expect(post.isFeatured, isTrue);
  });

  test('summary bos metin gelirse gecerli sayilir, null olmaz', () {
    final post = _parse(_bosSummary);

    expect(post.summary, '');
    expect(post.summary, isEmpty);
    // Asil nokta: bos metin bir deger, yokluk degil.
    expect(post.title, isNotEmpty);
  });

  test('category null gelebilir', () {
    final post = _parse(_nullCategory);

    expect(post.category, isNull);
    expect(post.coverImage, isNotNull);
  });

  test('cover_image null gelebilir', () {
    final post = _parse(_nullCoverImage);

    expect(post.coverImage, isNull);
    expect(post.category, 'Deneme');
  });

  test('eksik ve yanlis tipli alan ApiException firlatir', () {
    expect(
      () => _parse(_bozuk),
      throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.parse,
        ),
      ),
    );
  });

  test('cozulemeyen published_at ApiException firlatir', () {
    expect(
      () => _parse(_bozukTarih),
      throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.parse,
        ),
      ),
    );
  });
}
