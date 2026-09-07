import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/review.dart';
import 'package:mertorhan_app/models/review_detail.dart';

/// Bu dosyadaki hicbir test aga cikmaz; ornek JSON metinleri asagida sabit.

/// Canli /movies/crazy-stupid-love/ kaydinin kisaltilmisi.
///
/// actors ALFABETIK geliyor: basrol Steve Carell ama ucuncu sirada.
/// Sunucunun sirasi oldugu gibi korunur, uygulama yeniden siralamaz.
const String _tamDolu = '''
{
  "id": 1,
  "slug": "crazy-stupid-love",
  "title": "Crazy, Stupid, Love.",
  "content_type": "film",
  "cover_image": "https://www.mertorhan.com/media/movies/Crazy_Stupid_Love.jpg",
  "release_year": 2011,
  "rating": 1.5,
  "summary": "Kısa özet.",
  "published_at": "2026-08-16",
  "watched_at": "2026-08-05",
  "is_featured": false,
  "body": "Film hakkında düz metin gövde.",
  "directors": ["Glenn Ficarra", "John Requa"],
  "screenwriters": ["Dan Fogelman"],
  "actors": ["Julianne Moore", "Ryan Gosling", "Steve Carell"],
  "genres": ["Comedy"]
}
''';

/// Canli /movies/glass-onion/ kaydi: dort liste de bos, ama yil dolu.
const String _kunyesiz = '''
{
  "id": 2,
  "slug": "glass-onion",
  "title": "Glass Onion",
  "content_type": "film",
  "cover_image": null,
  "release_year": 2022,
  "rating": null,
  "summary": "",
  "published_at": "2026-08-10",
  "watched_at": null,
  "is_featured": false,
  "body": "Düz metin gövde.",
  "directors": [],
  "screenwriters": [],
  "actors": [],
  "genres": []
}
''';

/// Govde bos "" gelmis; bu gecerli bir degerdir, yoklugu degil.
const String _govdesizAmaGecerli = '''
{
  "id": 3, "slug": "bos-govde", "title": "Boş gövde",
  "content_type": "dizi", "cover_image": null, "release_year": null,
  "rating": null, "summary": "", "published_at": "2026-08-01",
  "watched_at": null, "is_featured": false,
  "body": "",
  "directors": [], "screenwriters": [], "actors": [], "genres": []
}
''';

/// directors dize gelmis, liste degil.
const String _bozukDirectors = '''
{
  "id": 4, "slug": "bozuk", "title": "Bozuk",
  "content_type": "film", "cover_image": null, "release_year": null,
  "rating": null, "summary": "", "published_at": "2026-08-01",
  "watched_at": null, "is_featured": false,
  "body": "",
  "directors": "Glenn Ficarra", "screenwriters": [], "actors": [],
  "genres": []
}
''';

/// genres listesinin icinde metin olmayan bir oge var.
const String _bozukGenresOgesi = '''
{
  "id": 5, "slug": "bozuk-tur", "title": "Bozuk tür",
  "content_type": "film", "cover_image": null, "release_year": null,
  "rating": null, "summary": "", "published_at": "2026-08-01",
  "watched_at": null, "is_featured": false,
  "body": "",
  "directors": [], "screenwriters": [], "actors": [],
  "genres": ["Comedy", 42]
}
''';

/// actors null gelmis; sozlesme bos liste diyor, null degil.
const String _bozukActors = '''
{
  "id": 6, "slug": "bozuk-oyuncu", "title": "Bozuk oyuncu",
  "content_type": "film", "cover_image": null, "release_year": null,
  "rating": null, "summary": "", "published_at": "2026-08-01",
  "watched_at": null, "is_featured": false,
  "body": "",
  "directors": [], "screenwriters": [], "actors": null, "genres": []
}
''';

/// body eksik.
const String _bodysiz = '''
{
  "id": 7, "slug": "govdesiz", "title": "Gövdesiz",
  "content_type": "film", "cover_image": null, "release_year": null,
  "rating": null, "summary": "", "published_at": "2026-08-01",
  "watched_at": null, "is_featured": false,
  "directors": [], "screenwriters": [], "actors": [], "genres": []
}
''';

ReviewDetail _parse(String source) =>
    ReviewDetail.fromJson(jsonDecode(source) as Map<String, dynamic>);

Matcher get _ayristirmaHatasi => throwsA(
  isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
);

void main() {
  test('tam dolu detay cozulur, liste alanlari Review icinde durur', () {
    final d = _parse(_tamDolu);

    expect(d.review.slug, 'crazy-stupid-love');
    expect(d.review.title, 'Crazy, Stupid, Love.');
    expect(d.review.contentKind, ContentKind.film);
    expect(d.review.releaseYear, 2011);
    expect(d.review.rating, 1.5);
    expect(d.review.watchedAt, DateTime(2026, 8, 5));
  });

  test('kunye listeleri cozulur', () {
    final d = _parse(_tamDolu);

    expect(d.directors, ['Glenn Ficarra', 'John Requa']);
    expect(d.screenwriters, ['Dan Fogelman']);
    expect(d.actors, ['Julianne Moore', 'Ryan Gosling', 'Steve Carell']);
    expect(d.genres, ['Comedy']);
    expect(d.body, 'Film hakkında düz metin gövde.');
  });

  test('sunucunun oyuncu sirasi degistirilmez', () {
    final d = _parse(_tamDolu);

    // Alfabetik geliyor; uygulama yeniden siralamiyor, oldugu gibi tasiyor.
    expect(d.actors.first, 'Julianne Moore');
    expect(d.actors.last, 'Steve Carell');
  });

  test('dort liste de bos gelebilir, kayit yine gecerli', () {
    final d = _parse(_kunyesiz);

    expect(d.directors, isEmpty);
    expect(d.screenwriters, isEmpty);
    expect(d.actors, isEmpty);
    expect(d.genres, isEmpty);
    // Kunye bos ama yil dolu; kayit gecerli.
    expect(d.review.releaseYear, 2022);
    expect(d.review.watchedAt, isNull);
    expect(d.review.title, 'Glass Onion');
  });

  test('body bos "" gecerlidir', () {
    final d = _parse(_govdesizAmaGecerli);

    expect(d.body, isEmpty);
    expect(d.review.contentKind, ContentKind.dizi);
  });

  test('directors dize gelirse ApiException firlatir', () {
    expect(() => _parse(_bozukDirectors), _ayristirmaHatasi);
  });

  test('genres icinde metin olmayan oge varsa ApiException firlatir', () {
    expect(() => _parse(_bozukGenresOgesi), _ayristirmaHatasi);
  });

  test('actors null gelirse ApiException firlatir', () {
    expect(() => _parse(_bozukActors), _ayristirmaHatasi);
  });

  test('body eksikse ApiException firlatir', () {
    expect(() => _parse(_bodysiz), _ayristirmaHatasi);
  });
}
