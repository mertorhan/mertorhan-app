import '../api/api_exception.dart';
import 'json_parse.dart';

/// Bir filtre grubundaki tek secenek.
///
/// Ornek: {"value": 3, "label": "Dostoyevski", "count": 2}
class FilterOption {
  const FilterOption({
    required this.value,
    required this.label,
    required this.count,
  });

  static const String _label = 'FilterOption';

  /// Sorgu parametresine yazilacak deger.
  ///
  /// NEDEN String: JSON'da sayi da dize de geliyor — id ve yillar sayi
  /// (`"value": 2011`), rating ve content_type dize (`"value": "alt7"`).
  /// Ama iki durumda da tek isi var: sorgu dizesine yazilmak. Tip ayrimini
  /// modelde tasimak, kullanan her yerde yeniden dallanmak demek olurdu —
  /// oysa ?year=2011 ile ?rating=alt7 arasinda adres kurarken hicbir fark
  /// yok. Sayi gelirse toString() ile cevrilir.
  final String value;

  /// Kullaniciya gosterilecek metin. Sunucu bunu zaten alfabetik sirali
  /// donduruyor; uygulama yeniden siralamaz.
  final String label;

  /// Bu secenege uyan kayit sayisi.
  ///
  /// Sunucu count = 0 olan secenegi hic gondermiyor, yani pratikte
  /// her zaman 1 veya daha buyuk.
  final int count;

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      value: _requireValue(json),
      label: requireString(json, 'label', _label),
      count: requireInt(json, 'count', _label),
    );
  }

  @override
  String toString() => 'FilterOption($value, $count)';
}

/// value yalnizca sayi ya da dize olabilir.
///
/// bool, null, liste veya nesne gelirse bu gercek bir sozlesme ihlalidir;
/// sessizce toString() ile "true" yazmak, bozuk veriyi gecerli bir filtre
/// degeriymis gibi gostermek olurdu.
String _requireValue(Map<String, dynamic> json) {
  final Object? value = json['value'];
  if (value is String) return value;
  if (value is int) return value.toString();
  throw ApiException.parse(
    value == null
        ? "FilterOption: 'value' alani yok veya null"
        : "FilterOption: 'value' sayi ya da metin bekleniyordu, "
              '${value.runtimeType} geldi',
  );
}
