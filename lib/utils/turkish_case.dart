/// API'den GELEN metni Turkce kurallarina gore buyutur.
///
/// Dart'in toUpperCase'i locale bilmez: 'i' -> 'I' verir, dogrusu 'İ'.
/// Nokta iki yonlu bir sorun: 'ı' da 'I' olmali, toUpperCase onu zaten
/// dogru cevirmiyor. Bu yuzden iki harf ONCE elle degistirilir, sonra
/// toUpperCase geri kalanla ilgilenir.
///
/// KAYNAKTA yazilan etiketler icin CAGRILMAZ — onlar zaten dogru harfle
/// yazilir (bkz. credits_block.dart). Bu fonksiyon yalnizca sunucudan
/// gelen, kaynakta duzeltemeyecegimiz metinler icin var: galerideki
/// kategori adi gibi.
String turkishUpper(String text) =>
    text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
