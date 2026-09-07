import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/query.dart';
import 'package:mertorhan_app/models/filter_selection.dart';

/// buildPath saf fonksiyon: aga cikmaz, istemci gerekmez.

FilterSelection _secim(List<(String, String)> ciftler) {
  FilterSelection s = const FilterSelection.empty();
  for (final (String key, String value) in ciftler) {
    s = s.toggle(key, value);
  }
  return s;
}

void main() {
  test('sayfasiz ve secimsiz: yalin taban', () {
    expect(buildPath('books/'), 'books/');
  });

  test('ilk sayfada page YAZILMAZ', () {
    // Mevcut davranis buydu; adresler degismesin.
    expect(buildPath('books/', page: 1), 'books/');
  });

  test('sifir ve negatif sayfa da ilk sayfaya duser', () {
    expect(buildPath('books/', page: 0), 'books/');
    expect(buildPath('books/', page: -3), 'books/');
  });

  test('ikinci sayfadan itibaren page yazilir', () {
    expect(buildPath('books/', page: 2), 'books/?page=2');
    expect(buildPath('movies/', page: 17), 'movies/?page=17');
  });

  test('bos secim filtre parametresi yazmaz', () {
    expect(
      buildPath('books/', selection: const FilterSelection.empty()),
      'books/',
    );
    // Secilip geri birakilan deger de bos sayilir.
    final bosalan = _secim([('author', '3')]).toggle('author', '3');
    expect(buildPath('books/', selection: bosalan), 'books/');
  });

  test('tek filtre', () {
    expect(
      buildPath('books/', selection: _secim([('author', '3')])),
      'books/?author=3',
    );
  });

  test('ayni parametre birden cok kez: VEYA', () {
    expect(
      buildPath(
        'movies/',
        selection: _secim([('actor', '1'), ('actor', '5')]),
      ),
      'movies/?actor=1&actor=5',
    );
  });

  test('farkli parametreler birlikte', () {
    expect(
      buildPath(
        'movies/',
        selection: _secim([('genre', '2'), ('actor', '5')]),
      ),
      'movies/?actor=5&genre=2',
    );
  });

  test('sayfa ve filtre birlikte: page once', () {
    expect(
      buildPath('books/', page: 3, selection: _secim([('author', '3')])),
      'books/?page=3&author=3',
    );
  });

  test('SIRA KARARLI: secim sirasi adresi degistirmez', () {
    final ileri = _secim([
      ('author', '7'),
      ('author', '3'),
      ('genre', '9'),
      ('genre', '2'),
    ]);
    final geri = _secim([
      ('genre', '2'),
      ('genre', '9'),
      ('author', '3'),
      ('author', '7'),
    ]);

    // Ayni secim, farkli tiklama sirasi -> ayni adres.
    expect(buildPath('books/', selection: ileri), buildPath('books/', selection: geri));
    expect(
      buildPath('books/', selection: ileri),
      'books/?author=3&author=7&genre=2&genre=9',
    );
  });

  test('degerler URL kodlanir', () {
    // Elle birlestirilseydi bu karakterler adresi bozardi.
    expect(
      buildPath('books/', selection: _secim([('publisher', 'Yapı Kredi')])),
      'books/?publisher=Yap%C4%B1+Kredi',
    );
    expect(
      buildPath('books/', selection: _secim([('genre', 'a&b=c')])),
      'books/?genre=a%26b%3Dc',
    );
  });

  test('rating gibi dize degerler de calisir', () {
    expect(
      buildPath('movies/', selection: _secim([('rating', 'alt7')])),
      'movies/?rating=alt7',
    );
  });

  test('donen yol GORELI: basinda egik cizgi yok', () {
    // ApiClient taban adresi kendisi ekliyor; basta / olsaydi cift
    // egik cizgi olusurdu.
    expect(buildPath('books/', page: 2).startsWith('/'), isFalse);
  });
}
