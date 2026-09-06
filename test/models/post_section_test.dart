import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/post_section.dart';

/// Ornek bloklar canli uctan alinan gercek yanittan kisaltildi.
/// Sunucu duz sema donduruyor: her blokta 11 anahtarin hepsi var.
const String _paragraph = '''
{
  "order": 10, "kind": "paragraph",
  "text": "Scrum'ı öğrenmeye çalışmadan önce neden var olduğuna bakalım.",
  "heading_level": "", "in_toc": true,
  "image": null, "image_title": "", "image_caption": "", "image_alt": "",
  "quote_source": "", "embed_url": ""
}
''';

const String _quote = '''
{
  "order": 20, "kind": "quote",
  "text": "Cevapları sonradan konuşursanız her seferinde tartışma çıkar.",
  "heading_level": "", "in_toc": true,
  "image": null, "image_title": "", "image_caption": "", "image_alt": "",
  "quote_source": "", "embed_url": ""
}
''';

/// Canlida ornegi yok; sozlesmeye gore kuruldu.
const String _heading = '''
{
  "order": 5, "kind": "heading",
  "text": "Scrum neden var?",
  "heading_level": "h2", "in_toc": true,
  "image": null, "image_title": "", "image_caption": "", "image_alt": "",
  "quote_source": "", "embed_url": ""
}
''';

/// Sunucuya sonradan eklenmis, uygulamanin bilmedigi bir tur.
const String _bilinmeyenTur = '''
{
  "order": 30, "kind": "gallery",
  "text": "", "heading_level": "", "in_toc": false,
  "image": null, "image_title": "", "image_caption": "", "image_alt": "",
  "quote_source": "", "embed_url": ""
}
''';

/// 'order' metin gelmis — bu ileri uyumluluk degil, gercek hata.
const String _bozukAlan = '''
{
  "order": "on", "kind": "paragraph",
  "text": "Metin.", "heading_level": "", "in_toc": true,
  "image": null, "image_title": "", "image_caption": "", "image_alt": "",
  "quote_source": "", "embed_url": ""
}
''';

PostSection? _parse(String source) =>
    PostSection.tryParse(jsonDecode(source) as Map<String, dynamic>);

void main() {
  test('paragraph blogu cozulur', () {
    final s = _parse(_paragraph)!;

    expect(s.kind, SectionKind.paragraph);
    expect(s.order, 10);
    expect(s.text, isNotEmpty);
    // Kullanilmayan metin alanlari "" gelir, null degil.
    expect(s.headingLevel, '');
    expect(s.quoteSource, '');
    expect(s.image, isNull);
  });

  test('quote blogu cozulur, kaynagi bos olabilir', () {
    final s = _parse(_quote)!;

    expect(s.kind, SectionKind.quote);
    expect(s.quoteSource, isEmpty);
  });

  test('heading blogu seviyesini tasir', () {
    final s = _parse(_heading)!;

    expect(s.kind, SectionKind.heading);
    expect(s.headingLevel, 'h2');
  });

  test('taninmayan kind null doner, cokme olmaz', () {
    expect(_parse(_bilinmeyenTur), isNull);
  });

  test('yanlis tipli alan ApiException firlatir', () {
    expect(
      () => _parse(_bozukAlan),
      throwsA(
        isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
      ),
    );
  });
}
