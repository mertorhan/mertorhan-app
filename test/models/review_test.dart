import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/review.dart';

/// Canli /movies/ ucundan alinan gercek kayit.
const String _tamDolu = '''
{
  "id": 5,
  "slug": "crazy-stupid-love",
  "title": "Crazy, Stupid, Love.",
  "content_type": "film",
  "cover_image": "https://www.mertorhan.com/media/movies/Crazy_Stupid_Love.jpg",
  "release_year": 2011,
  "rating": 1.5,
  "summary": "Karısının ani boşanma isteği üzerine hayatı altüst olan adam.",
  "published_at": "2026-08-16",
  "watched_at": "2026-08-05",
  "is_featured": false
}
''';

/// Canlida rating hep double geldi; sozlesme int'i de kabul ediyor.
const String _tamPuan = '''
{
  "id": 6, "slug": "dizi-ornegi", "title": "Bir dizi",
  "content_type": "dizi", "cover_image": null,
  "release_year": 2021, "rating": 8,
  "summary": "", "published_at": "2026-08-10",
  "watched_at": null, "is_featured": true
}
''';

const String _bosAlanlar = '''
{
  "id": 7, "slug": "eksik-kayit", "title": "Eksikli kayıt",
  "content_type": "film", "cover_image": null,
  "release_year": null, "rating": null,
  "summary": "", "published_at": "2026-08-01",
  "watched_at": null, "is_featured": false
}
''';

/// Sunucuya sonradan eklenmis, uygulamanin bilmedigi bir tur.
const String _bilinmeyenTur = '''
{
  "id": 8, "slug": "belgesel-ornegi", "title": "Bir belgesel",
  "content_type": "belgesel", "cover_image": null,
  "release_year": 2024, "rating": 4.5,
  "summary": "Özet.", "published_at": "2026-07-01",
  "watched_at": null, "is_featured": false
}
''';

/// release_year metin gelmis.
const String _bozuk = '''
{
  "id": 9, "slug": "bozuk", "title": "Bozuk",
  "content_type": "film", "cover_image": null,
  "release_year": "2011", "rating": null,
  "summary": "", "published_at": "2026-07-01",
  "watched_at": null, "is_featured": false
}
''';

Review _parse(String source) =>
    Review.fromJson(jsonDecode(source) as Map<String, dynamic>);

void main() {
  test('tam dolu kayit cozulur', () {
    final r = _parse(_tamDolu);

    expect(r.id, 5);
    expect(r.slug, 'crazy-stupid-love');
    expect(r.contentKind, ContentKind.film);
    expect(r.releaseYear, 2011);
    expect(r.rating, 1.5);
    expect(r.publishedAt, DateTime(2026, 8, 16));
    expect(r.watchedAt, DateTime(2026, 8, 5));
    expect(r.isFeatured, isFalse);
  });

  test('rating double gelince cozulur', () {
    expect(_parse(_tamDolu).rating, 1.5);
    expect(_parse(_tamDolu).rating, isA<double>());
  });

  test('rating int gelince de cozulur', () {
    final r = _parse(_tamPuan);

    expect(r.rating, 8);
    expect(r.rating, isA<int>());
    expect(r.contentKind, ContentKind.dizi);
  });

  test('null alanlar kabul edilir', () {
    final r = _parse(_bosAlanlar);

    expect(r.coverImage, isNull);
    expect(r.releaseYear, isNull);
    expect(r.rating, isNull);
    expect(r.watchedAt, isNull);
    // Bos ozet gecerli bir degerdir, yokluk degil.
    expect(r.summary, isEmpty);
  });

  test('bilinmeyen content_type kaydi dusurmez, sadece etiket duser', () {
    final r = _parse(_bilinmeyenTur);

    expect(r.contentKind, isNull);
    // Kaydin geri kalani saglam: kullaniciya gosterilebilir.
    expect(r.title, 'Bir belgesel');
    expect(r.releaseYear, 2024);
    expect(r.rating, 4.5);
  });

  test('yanlis tipli alan ApiException firlatir', () {
    expect(
      () => _parse(_bozuk),
      throwsA(
        isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
      ),
    );
  });
}
