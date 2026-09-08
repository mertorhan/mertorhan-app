import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/utils/turkish_case.dart';

void main() {
  test('noktali i buyuyunce noktali I olur', () {
    // Dart'in kendi toUpperCase'i burada 'MIMARI' verirdi.
    expect(turkishUpper('Mimari'), 'MİMARİ');
    expect(turkishUpper('Mimari'), isNot('Mimari'.toUpperCase()));
  });

  test('noktasiz i buyuyunce noktasiz I olur', () {
    expect(turkishUpper('ışık'), 'IŞIK');
  });

  test('bos metin bos kalir', () {
    expect(turkishUpper(''), '');
  });

  test('Turkce ozel harf icermeyen metin bozulmaz', () {
    // 'Portre'de ne 'i' ne 'ı' var; duz toUpperCase ile ayni sonuc.
    expect(turkishUpper('Portre'), 'PORTRE');
    expect(turkishUpper('Portre'), 'Portre'.toUpperCase());
  });

  test('cok kelimeli metinde kelime sonundaki i de noktali buyur', () {
    expect(turkishUpper('Sokak Fotografi'), 'SOKAK FOTOGRAFİ');
    // Bosluk ve diger harfler yerinde kaliyor.
    expect(turkishUpper('Sokak Fotografi'), isNot(contains('I')));
  });

  test('zaten buyuk yazilmis noktali I bozulmaz', () {
    expect(turkishUpper('İstanbul'), 'İSTANBUL');
  });

  test('zaten buyuk metin ayni kalir', () {
    expect(turkishUpper('MANZARA'), 'MANZARA');
  });
}
