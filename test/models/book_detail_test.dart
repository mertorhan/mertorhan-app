import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/book_detail.dart';

/// Bu dosyadaki hicbir test aga cikmaz; ornek JSON metinleri asagida sabit.

/// Kunyesi tamamen dolu kayit. Alintilar bilerek karisik sirada.
const String _tamDolu = '''
{
  "id": 7,
  "slug": "suc-ve-ceza",
  "title": "Suç ve Ceza",
  "author": "Dostoyevski",
  "translator": "Ergin Altay",
  "cover_image": "https://www.mertorhan.com/media/books/suc.jpg",
  "rating": 4.5,
  "summary": "Kısa özet.",
  "published_at": "2026-08-13",
  "release_year": 1866,
  "read_at": "2026-03-14",
  "is_featured": true,
  "body": "Kitap hakkında düz metin gövde.",
  "quotes": [
    {"order": 30, "text": "Üçüncü alıntı.", "page": "300"},
    {"order": 10, "text": "Birinci alıntı.", "page": ""},
    {"order": 20, "text": "İkinci alıntı.", "page": "200"}
  ],
  "authors": ["Dostoyevski", "İkinci Yazar"],
  "translators": ["Ergin Altay"],
  "genres": ["Roman", "Klasik"],
  "publisher": "İletişim"
}
''';

/// Canlida su an dort kitabin dordu de boyle: kunyenin tamami bos.
const String _kunyesiz = '''
{
  "id": 8,
  "slug": "savas-sanati",
  "title": "Savaş Sanatı",
  "author": "Sun Zi (Sun Tzu)",
  "translator": "Guiyuan Yang",
  "cover_image": null,
  "rating": null,
  "summary": "",
  "published_at": "2026-08-16",
  "release_year": null,
  "read_at": null,
  "is_featured": false,
  "body": "Düz metin gövde.",
  "quotes": [],
  "authors": [],
  "translators": [],
  "genres": [],
  "publisher": null
}
''';

/// authors dize gelmis, liste degil.
const String _bozukAuthors = '''
{
  "id": 9, "slug": "bozuk", "title": "Bozuk",
  "author": "", "translator": "", "cover_image": null, "rating": null,
  "summary": "", "published_at": "2026-08-01",
  "release_year": null, "read_at": null, "is_featured": false,
  "body": "", "quotes": [],
  "authors": "Dostoyevski", "translators": [], "genres": [],
  "publisher": null
}
''';

/// genres listesinin icinde metin olmayan bir oge var.
const String _bozukGenresOgesi = '''
{
  "id": 10, "slug": "bozuk-tur", "title": "Bozuk tür",
  "author": "", "translator": "", "cover_image": null, "rating": null,
  "summary": "", "published_at": "2026-08-01",
  "release_year": null, "read_at": null, "is_featured": false,
  "body": "", "quotes": [],
  "authors": [], "translators": [], "genres": ["Roman", 42],
  "publisher": null
}
''';

/// publisher liste gelmis; sozlesme TEKIL dize ya da null diyor.
const String _bozukPublisher = '''
{
  "id": 11, "slug": "bozuk-yayinevi", "title": "Bozuk yayınevi",
  "author": "", "translator": "", "cover_image": null, "rating": null,
  "summary": "", "published_at": "2026-08-01",
  "release_year": null, "read_at": null, "is_featured": false,
  "body": "", "quotes": [],
  "authors": [], "translators": [], "genres": [],
  "publisher": ["İletişim"]
}
''';

/// quotes liste degil.
const String _bozukQuotes = '''
{
  "id": 12, "slug": "bozuk-alinti", "title": "Bozuk alıntı",
  "author": "", "translator": "", "cover_image": null, "rating": null,
  "summary": "", "published_at": "2026-08-01",
  "release_year": null, "read_at": null, "is_featured": false,
  "body": "", "quotes": {},
  "authors": [], "translators": [], "genres": [],
  "publisher": null
}
''';

/// quotes ogesi JSON nesnesi degil.
const String _bozukQuoteOgesi = '''
{
  "id": 13, "slug": "bozuk-alinti-oge", "title": "Bozuk alıntı ögesi",
  "author": "", "translator": "", "cover_image": null, "rating": null,
  "summary": "", "published_at": "2026-08-01",
  "release_year": null, "read_at": null, "is_featured": false,
  "body": "", "quotes": ["duz metin"],
  "authors": [], "translators": [], "genres": [],
  "publisher": null
}
''';

/// body eksik.
const String _bodysiz = '''
{
  "id": 14, "slug": "govdesiz", "title": "Gövdesiz",
  "author": "", "translator": "", "cover_image": null, "rating": null,
  "summary": "", "published_at": "2026-08-01",
  "release_year": null, "read_at": null, "is_featured": false,
  "quotes": [],
  "authors": [], "translators": [], "genres": [],
  "publisher": null
}
''';

BookDetail _parse(String source) =>
    BookDetail.fromJson(jsonDecode(source) as Map<String, dynamic>);

Matcher get _ayristirmaHatasi => throwsA(
  isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
);

void main() {
  test('tam dolu detay cozulur, liste alanlari Book icinde durur', () {
    final d = _parse(_tamDolu);

    expect(d.book.slug, 'suc-ve-ceza');
    expect(d.book.title, 'Suç ve Ceza');
    expect(d.book.rating, 4.5);
    expect(d.book.publishedAt, DateTime(2026, 8, 13));
    // Kunye alanlari da Book uzerinden geliyor.
    expect(d.book.releaseYear, 1866);
    expect(d.book.readAt, DateTime(2026, 3, 14));
    // Duz metin alanlar SILINMEDI; liste ekrani hala kullaniyor.
    expect(d.book.author, 'Dostoyevski');
    expect(d.book.translator, 'Ergin Altay');
  });

  test('kunye listeleri ve yayinevi cozulur', () {
    final d = _parse(_tamDolu);

    expect(d.authors, ['Dostoyevski', 'İkinci Yazar']);
    expect(d.translators, ['Ergin Altay']);
    expect(d.genres, ['Roman', 'Klasik']);
    expect(d.publisher, 'İletişim');
    expect(d.body, 'Kitap hakkında düz metin gövde.');
  });

  test('alintilar order sirasina gore dizilir', () {
    final d = _parse(_tamDolu);

    expect(d.quotes.map((q) => q.order).toList(), [10, 20, 30]);
    expect(d.quotes.first.text, 'Birinci alıntı.');
  });

  test('page bos gelen alinti atilmaz', () {
    final d = _parse(_tamDolu);

    // Uc alinti geldi, ucu de duruyor.
    expect(d.quotes.length, 3);
    expect(d.quotes.first.page, isEmpty);
    expect(d.quotes.last.page, '300');
  });

  test('kunyesi bos kayit cozulur: uc liste bos, uc alan null', () {
    final d = _parse(_kunyesiz);

    expect(d.authors, isEmpty);
    expect(d.translators, isEmpty);
    expect(d.genres, isEmpty);
    expect(d.publisher, isNull);
    expect(d.book.releaseYear, isNull);
    expect(d.book.readAt, isNull);
    expect(d.quotes, isEmpty);
    // Bos kunye hata degil; kayit gecerli.
    expect(d.book.title, 'Savaş Sanatı');
  });

  test('authors dize gelirse ApiException firlatir', () {
    expect(() => _parse(_bozukAuthors), _ayristirmaHatasi);
  });

  test('genres icinde metin olmayan oge varsa ApiException firlatir', () {
    expect(() => _parse(_bozukGenresOgesi), _ayristirmaHatasi);
  });

  test('publisher liste gelirse ApiException firlatir', () {
    expect(() => _parse(_bozukPublisher), _ayristirmaHatasi);
  });

  test('quotes liste degilse ApiException firlatir', () {
    expect(() => _parse(_bozukQuotes), _ayristirmaHatasi);
  });

  test('quotes ogesi nesne degilse ApiException firlatir', () {
    expect(() => _parse(_bozukQuoteOgesi), _ayristirmaHatasi);
  });

  test('body eksikse ApiException firlatir', () {
    expect(() => _parse(_bodysiz), _ayristirmaHatasi);
  });
}
