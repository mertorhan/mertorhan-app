import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/models/filter_selection.dart';

/// Bu dosyadaki hicbir test aga cikmaz; secim nesnesi saf veri.

void main() {
  test('bos secim', () {
    const s = FilterSelection.empty();

    expect(s.isEmpty, isTrue);
    expect(s.isNotEmpty, isFalse);
    expect(s.count, 0);
    expect(s.toQueryParameters(), isEmpty);
  });

  test('toggle deger ekler', () {
    final s = const FilterSelection.empty().toggle('author', '3');

    expect(s.isSelected('author', '3'), isTrue);
    expect(s.count, 1);
    expect(s.isEmpty, isFalse);
  });

  test('ayni degeri iki kez toggle etmek once ekler sonra cikarir', () {
    final bir = const FilterSelection.empty().toggle('author', '3');
    final iki = bir.toggle('author', '3');

    expect(bir.isSelected('author', '3'), isTrue);
    expect(iki.isSelected('author', '3'), isFalse);
    // Son deger cikinca anahtar da duser.
    expect(iki.isEmpty, isTrue);
    expect(iki.values.containsKey('author'), isFalse);
  });

  test('toggle MEVCUT nesneyi degistirmez', () {
    const bos = FilterSelection.empty();
    final bir = bos.toggle('author', '3');
    final iki = bir.toggle('author', '7');

    // Her adim yeni nesne; eskiler oldugu gibi duruyor.
    expect(bos.count, 0);
    expect(bir.count, 1);
    expect(iki.count, 2);
    expect(bir.isSelected('author', '7'), isFalse);
  });

  test('ayni anahtarda coklu deger', () {
    final s = const FilterSelection.empty()
        .toggle('author', '3')
        .toggle('author', '7');

    expect(s.count, 2);
    expect(s.toQueryParameters(), {
      'author': ['3', '7'],
    });
  });

  test('farkli anahtarlarda secim', () {
    final s = const FilterSelection.empty()
        .toggle('author', '3')
        .toggle('genre', '1')
        .toggle('rating', 'alt7');

    expect(s.count, 3);
    expect(s.toQueryParameters(), {
      'author': ['3'],
      'genre': ['1'],
      'rating': ['alt7'],
    });
  });

  test('bir anahtarin bir degeri cikarilinca digeri kalir', () {
    final s = const FilterSelection.empty()
        .toggle('author', '3')
        .toggle('author', '7')
        .toggle('author', '3');

    expect(s.count, 1);
    expect(s.isSelected('author', '7'), isTrue);
    expect(s.isSelected('author', '3'), isFalse);
  });

  test('toQueryParameters anahtar ve degerleri SIRALI verir', () {
    // Bilerek ters sirada secildi.
    final s = const FilterSelection.empty()
        .toggle('genre', '9')
        .toggle('author', '7')
        .toggle('author', '3')
        .toggle('genre', '2');

    expect(s.toQueryParameters(), {
      'author': ['3', '7'],
      'genre': ['2', '9'],
    });
    expect(s.toQueryParameters().keys.toList(), ['author', 'genre']);
  });

  test('clear her seyi siler', () {
    final s = const FilterSelection.empty()
        .toggle('author', '3')
        .toggle('genre', '1');

    expect(s.clear().isEmpty, isTrue);
    // Kaynak nesne yine degismedi.
    expect(s.count, 2);
  });

  test('isSelected bilinmeyen anahtarda false doner', () {
    final s = const FilterSelection.empty().toggle('author', '3');

    expect(s.isSelected('publisher', '3'), isFalse);
    expect(s.isSelected('author', '99'), isFalse);
  });

  test('ayni secim iki nesne esittir', () {
    final a = const FilterSelection.empty()
        .toggle('author', '3')
        .toggle('genre', '1');
    final b = const FilterSelection.empty()
        .toggle('author', '3')
        .toggle('genre', '1');

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
  });

  test('secim sirasi esitligi ve hash i degistirmez', () {
    final a = const FilterSelection.empty()
        .toggle('author', '3')
        .toggle('author', '7')
        .toggle('genre', '1');
    final b = const FilterSelection.empty()
        .toggle('genre', '1')
        .toggle('author', '7')
        .toggle('author', '3');

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
  });

  test('farkli secimler esit degildir', () {
    final a = const FilterSelection.empty().toggle('author', '3');
    final b = const FilterSelection.empty().toggle('author', '7');
    final c = const FilterSelection.empty().toggle('genre', '3');
    final d = a.toggle('genre', '1');

    expect(a, isNot(equals(b)));
    expect(a, isNot(equals(c)));
    expect(a, isNot(equals(d)));
  });

  test('bos secimler esittir', () {
    final a = const FilterSelection.empty().toggle('author', '3');

    expect(a.clear(), equals(const FilterSelection.empty()));
  });

  test('esit secimler Set icinde tek eleman olur', () {
    final a = const FilterSelection.empty().toggle('author', '3');
    final b = const FilterSelection.empty().toggle('author', '3');
    final c = const FilterSelection.empty().toggle('author', '7');

    expect({a, b}.length, 1);
    expect({a, b, c}.length, 2);
  });

  test('values disaridan degistirilemez', () {
    final s = const FilterSelection.empty().toggle('author', '3');

    expect(() => s.values['genre'] = {'1'}, throwsUnsupportedError);
    expect(() => s.values['author']!.add('7'), throwsUnsupportedError);
  });
}
