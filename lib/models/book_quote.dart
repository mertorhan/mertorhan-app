import 'json_parse.dart';

/// Kitap detayindaki tek bir alinti.
///
/// PostSection'in tryParse'i taklit EDILMEZ: orada nullable donusun sebebi
/// taninmayan `kind` degeriydi, alintinin tur alani yok. Burada bozuk veri
/// sessizce atlanacak bir sey degil, gercek bir hatadir.
class BookQuote {
  const BookQuote({
    required this.order,
    required this.text,
    required this.page,
  });

  static const String _label = 'BookQuote';

  /// Siralama anahtari. Sunucu 1'den baslatiyor ama sirali dondurmeyi
  /// garanti etmiyor; sirayi BookDetail kuruyor.
  final int order;

  final String text;

  /// Sayfa bilgisi. Bos "" gelebilir — canlida su an hepsi bos, bu yuzden
  /// null kontrolu yetmez, isNotEmpty ile bakilmali.
  ///
  /// METIN alan: sunucu ham degeri donduruyor. Basina "s." gibi bir onek
  /// EKLENMEZ; dolu bir ornek gorulmedigi icin bicimi uydurmak olurdu.
  final String page;

  factory BookQuote.fromJson(Map<String, dynamic> json) {
    return BookQuote(
      order: requireInt(json, 'order', _label),
      text: requireString(json, 'text', _label),
      page: requireString(json, 'page', _label),
    );
  }

  @override
  String toString() => 'BookQuote($order)';
}
