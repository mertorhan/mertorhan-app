import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mertorhan_app/api/api_client.dart';
import 'package:mertorhan_app/api/blog_api.dart';
import 'package:mertorhan_app/api/books_api.dart';
import 'package:mertorhan_app/api/movies_api.dart';
import 'package:mertorhan_app/api/photos_api.dart';
import 'package:mertorhan_app/models/filter_selection.dart';

/// Bu dosyadaki hicbir test aga cikmaz.
///
/// Sahteleme HTTP katmaninda: MockClient gercek ApiClient'a enjekte
/// ediliyor, boylece tel uzerinden gidecek MUTLAK adres dogrulanabiliyor.
/// Ekran testlerindeki gibi API sinifini ezseydik baseUrl birlestirmesi
/// test disinda kalirdi — oysa bu kartin asil riski yanlis adres uretmek.
///
/// MockClient http paketinin kendi icinde geliyor (package:http/testing.dart);
/// http zaten dogrudan bagimlilik, yeni paket eklenmedi.

/// Atilan isteklerin adreslerini biriktirir.
class _Kayit {
  final List<Uri> istekler = <Uri>[];

  /// [govde] yanit olarak dondurulur; varsayilan bos sayfali liste.
  ApiClient client([String govde = '{"count": 0, "results": []}']) {
    return ApiClient(
      client: MockClient((http.Request request) async {
        istekler.add(request.url);
        return http.Response(govde, 200, headers: _basliklar);
      }),
    );
  }

  Uri get tek => istekler.single;
}

/// Turkce karakterli govdenin dogru cozulmesi icin.
const Map<String, String> _basliklar = {
  'content-type': 'application/json; charset=utf-8',
};

const String _taban = 'https://www.mertorhan.com/api/v1/';

FilterSelection _secim(List<(String, String)> ciftler) {
  FilterSelection s = const FilterSelection.empty();
  for (final (String key, String value) in ciftler) {
    s = s.toggle(key, value);
  }
  return s;
}

void main() {
  // --- Secenek uclari: dogru yol cagriliyor mu ---

  test('BooksApi.fetchFilterOptions filters/books/ cagirir', () async {
    final kayit = _Kayit();
    await BooksApi(client: kayit.client('{}')).fetchFilterOptions();

    expect(kayit.tek.toString(), '${_taban}filters/books/');
  });

  test('MoviesApi.fetchFilterOptions filters/movies/ cagirir', () async {
    final kayit = _Kayit();
    await MoviesApi(client: kayit.client('{}')).fetchFilterOptions();

    expect(kayit.tek.toString(), '${_taban}filters/movies/');
  });

  test('BlogApi.fetchFilterOptions filters/blog/ cagirir', () async {
    final kayit = _Kayit();
    await BlogApi(client: kayit.client('{}')).fetchFilterOptions();

    expect(kayit.tek.toString(), '${_taban}filters/blog/');
  });

  test('PhotosApi.fetchFilterOptions filters/photos/ cagirir', () async {
    final kayit = _Kayit();
    await PhotosApi(client: kayit.client('{}')).fetchFilterOptions();

    expect(kayit.tek.toString(), '${_taban}filters/photos/');
  });

  test('bos nesne yaniti cozulur, secenek yok', () async {
    // Canlida /filters/books/ su an tam olarak boyle donuyor.
    final kayit = _Kayit();
    final f = await BooksApi(client: kayit.client('{}')).fetchFilterOptions();

    expect(f.isEmpty, isTrue);
  });

  test('dolu secenek yaniti cozulur', () async {
    final kayit = _Kayit();
    final f = await MoviesApi(client: kayit.client('''
{
  "actor": [{"value": 5, "label": "Aleksey Serebryakov", "count": 1}],
  "rating": [{"value": "alt7", "label": "7 altı", "count": 2}]
}
''')).fetchFilterOptions();

    expect(f.optionsFor('actor').single.value, '5');
    expect(f.optionsFor('rating').single.label, '7 altı');
  });

  // --- Liste uclari: geriye uyumluluk ---

  test('selection verilmeyince adres eskisiyle AYNI', () async {
    final kayit = _Kayit();
    final api = BooksApi(client: kayit.client());

    await api.fetchBooks();
    await api.fetchBooks(page: 2);

    expect(kayit.istekler[0].toString(), '${_taban}books/');
    expect(kayit.istekler[1].toString(), '${_taban}books/?page=2');
  });

  test('bos selection da adresi degistirmez', () async {
    final kayit = _Kayit();
    await BooksApi(
      client: kayit.client(),
    ).fetchBooks(selection: const FilterSelection.empty());

    expect(kayit.tek.toString(), '${_taban}books/');
  });

  // --- Liste uclari: filtre ---

  test('fetchBooks secimi adrese yazar', () async {
    final kayit = _Kayit();
    await BooksApi(client: kayit.client()).fetchBooks(
      selection: _secim([('author', '3'), ('genre', '1')]),
    );

    expect(kayit.tek.toString(), '${_taban}books/?author=3&genre=1');
  });

  test('fetchReviews coklu degeri tekrar eden parametre olarak yazar', () async {
    final kayit = _Kayit();
    await MoviesApi(client: kayit.client()).fetchReviews(
      selection: _secim([('actor', '5'), ('actor', '1')]),
    );

    // Sunucu bunu VEYA olarak yorumluyor (canlida dogrulandi).
    expect(kayit.tek.toString(), '${_taban}movies/?actor=1&actor=5');
    expect(kayit.tek.queryParametersAll['actor'], ['1', '5']);
  });

  test('fetchPosts sayfa ve secimi birlikte yazar', () async {
    final kayit = _Kayit();
    await BlogApi(client: kayit.client()).fetchPosts(
      page: 2,
      selection: _secim([('category', '5')]),
    );

    expect(kayit.tek.toString(), '${_taban}blog/?page=2&category=5');
  });

  test('fetchPhotos secimi adrese yazar', () async {
    final kayit = _Kayit();
    await PhotosApi(
      client: kayit.client(),
    ).fetchPhotos(selection: _secim([('category', '1')]));

    expect(kayit.tek.toString(), '${_taban}photos/?category=1');
  });

  test('kodlanmasi gereken deger adreste bozulmaz', () async {
    final kayit = _Kayit();
    await BooksApi(
      client: kayit.client(),
    ).fetchBooks(selection: _secim([('publisher', 'Yapı Kredi')]));

    expect(kayit.tek.toString(), '${_taban}books/?publisher=Yap%C4%B1+Kredi');
    // Sunucu tarafinda cozuldugunde ozgun deger geri geliyor.
    expect(kayit.tek.queryParameters['publisher'], 'Yapı Kredi');
  });
}
