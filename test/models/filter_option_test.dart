import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/filter_option.dart';

/// Bu dosyadaki hicbir test aga cikmaz; ornek JSON metinleri asagida sabit.

/// Canli /filters/movies/ ucunden: yazar/oyuncu id'leri SAYI geliyor.
const String _sayiDeger = '''
{"value": 5, "label": "Aleksey Serebryakov", "count": 1}
''';

/// Canli /filters/movies/ ucunden: rating DIZE geliyor.
const String _dizeDeger = '''
{"value": "alt7", "label": "7 altı", "count": 2}
''';

/// Yil da sayi gelir.
const String _yil = '''
{"value": 2011, "label": "2011", "count": 1}
''';

/// value bool gelmis; sozlesme sayi ya da dize diyor.
const String _bozukBool = '''
{"value": true, "label": "Bozuk", "count": 1}
''';

/// value null gelmis.
const String _bozukNull = '''
{"value": null, "label": "Bozuk", "count": 1}
''';

/// value liste gelmis.
const String _bozukListe = '''
{"value": [1, 2], "label": "Bozuk", "count": 1}
''';

/// count metin gelmis.
const String _bozukCount = '''
{"value": 1, "label": "Bir", "count": "1"}
''';

/// label eksik.
const String _labelsiz = '''
{"value": 1, "count": 1}
''';

FilterOption _parse(String source) =>
    FilterOption.fromJson(jsonDecode(source) as Map<String, dynamic>);

Matcher get _ayristirmaHatasi => throwsA(
  isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
);

void main() {
  test('sayi gelen value metne cevrilir', () {
    final o = _parse(_sayiDeger);

    expect(o.value, '5');
    expect(o.value, isA<String>());
    expect(o.label, 'Aleksey Serebryakov');
    expect(o.count, 1);
  });

  test('dize gelen value aynen kalir', () {
    final o = _parse(_dizeDeger);

    expect(o.value, 'alt7');
    expect(o.label, '7 altı');
    expect(o.count, 2);
  });

  test('yil da metne cevrilir', () {
    final o = _parse(_yil);

    // Sorgu dizesine yazilirken ?year=2011 olacak; tip ayrimi tasinmiyor.
    expect(o.value, '2011');
  });

  test('value bool gelirse ApiException firlatir', () {
    expect(() => _parse(_bozukBool), _ayristirmaHatasi);
  });

  test('value null gelirse ApiException firlatir', () {
    expect(() => _parse(_bozukNull), _ayristirmaHatasi);
  });

  test('value liste gelirse ApiException firlatir', () {
    expect(() => _parse(_bozukListe), _ayristirmaHatasi);
  });

  test('count metin gelirse ApiException firlatir', () {
    expect(() => _parse(_bozukCount), _ayristirmaHatasi);
  });

  test('label eksikse ApiException firlatir', () {
    expect(() => _parse(_labelsiz), _ayristirmaHatasi);
  });
}
