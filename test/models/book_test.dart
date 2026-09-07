import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/book.dart';

/// Canli /books/ ucundan alinan gercek kayit: cevirmen bos "" geliyor.
const String _cevirmensiz = '''
{
  "id": 4,
  "slug": "orneklerle-kolay-ekonomi",
  "title": "Örneklerle Kolay Ekonomi",
  "author": "DR. Mahfi Eğilmez",
  "translator": "",
  "cover_image": "https://www.mertorhan.com/media/books/Mahfi.jpg",
  "rating": null,
  "summary": "Ekonominin temel kavramlarını sıfırdan anlatan bir kitap.",
  "published_at": "2026-08-13",
  "is_featured": true
}
''';

const String _cevirmenli = '''
{
  "id": 3, "slug": "ceviri-kitap", "title": "Çeviri kitap",
  "author": "Bir Yazar", "translator": "Fatih Demirci",
  "cover_image": null, "rating": 4.5,
  "summary": "", "published_at": "2026-08-01", "is_featured": false
}
''';

/// Sozlesme tam puani da kabul ediyor.
const String _tamPuan = '''
{
  "id": 2, "slug": "tam-puan", "title": "Tam puanlı",
  "author": "Yazar", "translator": "",
  "cover_image": null, "rating": 5,
  "summary": "Özet.", "published_at": "2026-07-01", "is_featured": false
}
''';

/// Basim yili ve okuma tarihi dolu.
const String _kunyeli = '''
{
  "id": 5, "slug": "kunyeli", "title": "Künyeli kitap",
  "author": "Yazar", "translator": "",
  "cover_image": null, "rating": null,
  "summary": "", "published_at": "2026-08-01",
  "release_year": 1866, "read_at": "2026-03-14",
  "is_featured": false
}
''';

/// Canlida su an dort kitabin dordu de boyle: iki alan da null.
const String _kunyesiz = '''
{
  "id": 6, "slug": "kunyesiz", "title": "Künyesiz kitap",
  "author": "Yazar", "translator": "",
  "cover_image": null, "rating": null,
  "summary": "", "published_at": "2026-08-01",
  "release_year": null, "read_at": null,
  "is_featured": false
}
''';

/// rating metin gelmis.
const String _bozuk = '''
{
  "id": 1, "slug": "bozuk", "title": "Bozuk",
  "author": "Yazar", "translator": "",
  "cover_image": null, "rating": "4.5",
  "summary": "", "published_at": "2026-07-01", "is_featured": false
}
''';

Book _parse(String source) =>
    Book.fromJson(jsonDecode(source) as Map<String, dynamic>);

void main() {
  test('tam dolu kayit cozulur, cevirmen bos olabilir', () {
    final b = _parse(_cevirmensiz);

    expect(b.title, 'Örneklerle Kolay Ekonomi');
    expect(b.author, 'DR. Mahfi Eğilmez');
    // Bos metin gecerli bir degerdir; null kontrolu yetmez.
    expect(b.translator, isEmpty);
    expect(b.rating, isNull);
    expect(b.publishedAt, DateTime(2026, 8, 13));
  });

  test('cevirmen ve ondalikli puan cozulur', () {
    final b = _parse(_cevirmenli);

    expect(b.translator, 'Fatih Demirci');
    expect(b.rating, 4.5);
    expect(b.coverImage, isNull);
  });

  test('rating int gelince de cozulur', () {
    final b = _parse(_tamPuan);

    expect(b.rating, 5);
    expect(b.rating, isA<int>());
  });

  test('basim yili ve okuma tarihi cozulur', () {
    final b = _parse(_kunyeli);

    expect(b.releaseYear, 1866);
    expect(b.readAt, DateTime(2026, 3, 14));
  });

  test('basim yili ve okuma tarihi null gelebilir', () {
    final b = _parse(_kunyesiz);

    expect(b.releaseYear, isNull);
    expect(b.readAt, isNull);
  });

  test('release_year ve read_at anahtarlari hic yoksa da cozulur', () {
    // Eski kayitlarda alanlar sozlesmede yoktu; yoklugu hata degil.
    final b = _parse(_cevirmensiz);

    expect(b.releaseYear, isNull);
    expect(b.readAt, isNull);
  });

  test('yanlis tipli rating ApiException firlatir', () {
    expect(
      () => _parse(_bozuk),
      throwsA(
        isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
      ),
    );
  });
}
