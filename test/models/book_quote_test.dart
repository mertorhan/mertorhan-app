import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/book_quote.dart';

/// Bu dosyadaki hicbir test aga cikmaz; ornek JSON metinleri asagida sabit.

/// Canli /books/simdinin-gucu/ ucundan alinan gercek alinti: page bos.
const String _sayfasiz = '''
{
  "order": 1,
  "text": "• Ben Buda'nın aydınlanmayı basitçe \\"ıstırabın sonu\\" olarak tanımlayışını severim.",
  "page": ""
}
''';

const String _sayfali = '''
{"order": 2, "text": "Bir alıntı.", "page": "42"}
''';

/// order metin gelmis.
const String _bozukOrder = '''
{"order": "1", "text": "Bir alıntı.", "page": ""}
''';

/// page null gelmis; sozlesme "" diyor, null degil.
const String _bozukPage = '''
{"order": 1, "text": "Bir alıntı.", "page": null}
''';

BookQuote _parse(String source) =>
    BookQuote.fromJson(jsonDecode(source) as Map<String, dynamic>);

void main() {
  test('alinti cozulur, page bos olabilir', () {
    final q = _parse(_sayfasiz);

    expect(q.order, 1);
    expect(q.text, startsWith('• Ben Buda'));
    // Bos metin gecerli bir degerdir; null kontrolu yetmez.
    expect(q.page, isEmpty);
  });

  test('dolu page ham haliyle korunur', () {
    final q = _parse(_sayfali);

    // Basina "s." gibi bir onek EKLENMEZ; bicim sunucunun.
    expect(q.page, '42');
  });

  test('order metin gelirse ApiException firlatir', () {
    expect(
      () => _parse(_bozukOrder),
      throwsA(
        isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
      ),
    );
  });

  test('page null gelirse ApiException firlatir', () {
    expect(
      () => _parse(_bozukPage),
      throwsA(
        isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
      ),
    );
  });
}
