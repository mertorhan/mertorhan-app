import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/filter_options.dart';

/// Bu dosyadaki hicbir test aga cikmaz; ornek JSON metinleri asagida sabit.

/// Canli /filters/movies/ yanitinin kisaltilmisi.
///
/// Anahtarlar liste ucunun sorgu parametre adlariyla birebir ayni.
/// value hem sayi (actor, year) hem dize (rating) geliyor.
const String _filmler = '''
{
  "year": [
    {"value": 2011, "label": "2011", "count": 1},
    {"value": 2021, "label": "2021", "count": 1}
  ],
  "actor": [
    {"value": 5, "label": "Aleksey Serebryakov", "count": 1},
    {"value": 4, "label": "Bob Odenkirk", "count": 1}
  ],
  "rating": [
    {"value": "alt7", "label": "7 altı", "count": 2}
  ]
}
''';

/// Canli /filters/books/ su an TAM OLARAK boyle: bos nesne.
/// Kitap kunyeleri henuz girilmemis. Bu hata degil.
const String _bosNesne = '{}';

/// Sunucu bos grup gondermiyor ama gelirse anahtar acilmamali.
const String _bosGrup = '''
{
  "category": [{"value": 1, "label": "Manzara", "count": 5}],
  "author": []
}
''';

/// Anahtarin degeri liste degil.
const String _bozukGrup = '''
{"author": {"value": 1}}
''';

/// Liste ogesi JSON nesnesi degil.
const String _bozukOge = '''
{"author": ["Dostoyevski"]}
''';

/// Ogenin ici bozuk: value bool.
const String _bozukOgeIci = '''
{"author": [{"value": true, "label": "Bozuk", "count": 1}]}
''';

FilterOptions _parse(String source) =>
    FilterOptions.fromJson(jsonDecode(source) as Map<String, dynamic>);

Matcher get _ayristirmaHatasi => throwsA(
  isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
);

void main() {
  test('tum gruplar cozulur', () {
    final f = _parse(_filmler);

    expect(f.groups.keys, ['year', 'actor', 'rating']);
    expect(f.optionsFor('year').length, 2);
    expect(f.optionsFor('actor').length, 2);
    expect(f.optionsFor('rating').single.value, 'alt7');
  });

  test('sunucunun anahtar sirasi korunur', () {
    final f = _parse(_filmler);

    // Grup sirasi ve Turkce basliklar arayuz karari; bu katman
    // sunucunun verdigi sirayi oldugu gibi tasir.
    expect(f.groups.keys.toList(), ['year', 'actor', 'rating']);
  });

  test('sunucunun secenek sirasi korunur', () {
    final f = _parse(_filmler);

    // Sunucu label'a gore alfabetik donduruyor; uygulama yeniden siralamaz.
    expect(f.optionsFor('actor').first.label, 'Aleksey Serebryakov');
    expect(f.optionsFor('actor').last.label, 'Bob Odenkirk');
  });

  test('bos nesne gecerlidir, bos sonuc verir', () {
    final f = _parse(_bosNesne);

    expect(f.isEmpty, isTrue);
    expect(f.groups, isEmpty);
  });

  test('bos liste gelen anahtar atlanir', () {
    final f = _parse(_bosGrup);

    expect(f.groups.keys, ['category']);
    // "Grup var ama secenek yok" diye bir ara durum olusmaz.
    expect(f.groups.containsKey('author'), isFalse);
  });

  test('optionsFor bilinmeyen anahtarda bos liste doner', () {
    final f = _parse(_filmler);

    // Cagiran taraf null kontrolu yapmasin diye.
    expect(f.optionsFor('publisher'), isEmpty);
  });

  test('empty kurucusu bos sonuc verir', () {
    const f = FilterOptions.empty();

    expect(f.isEmpty, isTrue);
    expect(f.optionsFor('author'), isEmpty);
  });

  test('anahtarin degeri liste degilse ApiException firlatir', () {
    expect(() => _parse(_bozukGrup), _ayristirmaHatasi);
  });

  test('liste ogesi nesne degilse ApiException firlatir', () {
    expect(() => _parse(_bozukOge), _ayristirmaHatasi);
  });

  test('ogenin ici bozuksa ApiException firlatir', () {
    expect(() => _parse(_bozukOgeIci), _ayristirmaHatasi);
  });
}
