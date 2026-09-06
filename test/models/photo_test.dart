import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/models/photo.dart';

/// Canli /photos/ ucundan alinan gercek kayit.
const String _tamDolu = '''
{
  "id": 2,
  "title": "İlk Durabildiğimiz Cepten",
  "image": "https://www.mertorhan.com/media/gallery/Edit5.jpg",
  "thumbnail": "https://www.mertorhan.com/media/gallery/thumbs/Edit5.jpg",
  "image_width": 2000,
  "image_height": 1340,
  "category": "Manzara",
  "location": "Datça yolu, Muğla",
  "taken_at": "2026-07-05",
  "camera": "Canon EOS 4000D",
  "lens": "Canon EF-S 18-55mm f/3.5-5.6 III",
  "iso": "100",
  "shutter_speed": "1/200 sn",
  "aperture": "f/9",
  "focal_length": "46 mm",
  "order": 0
}
''';

/// Eski kayit: thumbnail uretilmemis, olculer ve tarih yok, EXIF bos.
const String _eskiKayit = '''
{
  "id": 1, "title": "Eski kayıt",
  "image": "https://www.mertorhan.com/media/gallery/eski.jpg",
  "thumbnail": null,
  "image_width": null, "image_height": null,
  "category": null, "location": "", "taken_at": null,
  "camera": "", "lens": "", "iso": "",
  "shutter_speed": "", "aperture": "", "focal_length": "",
  "order": 1
}
''';

/// Gorsel de yok: liste yer tutucu cizmeli.
const String _gorselsiz = '''
{
  "id": 3, "title": "Görselsiz",
  "image": null, "thumbnail": null,
  "image_width": null, "image_height": null,
  "category": null, "location": "", "taken_at": null,
  "camera": "", "lens": "", "iso": "",
  "shutter_speed": "", "aperture": "", "focal_length": "",
  "order": 2
}
''';

/// order metin gelmis.
const String _bozuk = '''
{
  "id": 4, "title": "Bozuk",
  "image": null, "thumbnail": null,
  "image_width": null, "image_height": null,
  "category": null, "location": "", "taken_at": null,
  "camera": "", "lens": "", "iso": "",
  "shutter_speed": "", "aperture": "", "focal_length": "",
  "order": "iki"
}
''';

Photo _parse(String source) =>
    Photo.fromJson(jsonDecode(source) as Map<String, dynamic>);

void main() {
  test('tam dolu kayit cozulur', () {
    final p = _parse(_tamDolu);

    expect(p.title, 'İlk Durabildiğimiz Cepten');
    expect(p.imageWidth, 2000);
    expect(p.imageHeight, 1340);
    expect(p.category, 'Manzara');
    expect(p.takenAt, DateTime(2026, 7, 5));
    expect(p.order, 0);
  });

  test('iso METIN olarak korunur, sayiya cevrilmez', () {
    final p = _parse(_tamDolu);

    expect(p.iso, '100');
    expect(p.iso, isA<String>());
  });

  test('eski kayitta thumbnail, olculer ve tarih null olabilir', () {
    final p = _parse(_eskiKayit);

    expect(p.thumbnail, isNull);
    expect(p.imageWidth, isNull);
    expect(p.imageHeight, isNull);
    expect(p.takenAt, isNull);
    expect(p.category, isNull);
    // EXIF alanlari bos "" gelir, null degil.
    expect(p.camera, isEmpty);
    expect(p.iso, isEmpty);
  });

  test('listImage thumbnail yoksa image e duser', () {
    expect(_parse(_tamDolu).listImage, endsWith('thumbs/Edit5.jpg'));
    expect(_parse(_eskiKayit).listImage, endsWith('eski.jpg'));
    // Ikisi de yoksa null: cagiran yer tutucu cizer.
    expect(_parse(_gorselsiz).listImage, isNull);
  });

  test('yanlis tipli alan ApiException firlatir', () {
    expect(
      () => _parse(_bozuk),
      throwsA(
        isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.parse),
      ),
    );
  });
}
