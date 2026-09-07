import '../models/filter_selection.dart';

/// Liste uclarinin GORELI yolunu kurar.
///
/// Dort ucun (blog, movies, books, photos) yol kurmasi ayni:
/// `page <= 1 ? 'books/' : 'books/?page=2'`. Filtre eklenince dort yerde
/// birden karmasiklasacakti, tek yere alindi — parsePagedResponse'un
/// ayni gerekcesi.
///
/// GORELI donuyor cunku ApiClient.getJson taban adresi kendisi ekliyor
/// (`Uri.parse('$baseUrl$path')`). Basinda egik cizgi YOK.
///
/// Adres [Uri] ile kurulur, elle birlestirilmez: degerlerin URL kodlamasi
/// (bosluk, Turkce harf, & ve = gibi karakterler) boylece kendiliginden
/// dogru olur.
String buildPath(String base, {int page = 1, FilterSelection? selection}) {
  final Map<String, List<String>> query = <String, List<String>>{
    // Ilk sayfada page YAZILMAZ: mevcut davranis buydu, adresler
    // degismesin. Sunucu zaten page'siz istegi ilk sayfa sayiyor.
    if (page > 1) 'page': <String>['$page'],

    // toQueryParameters anahtarlari ve degerleri sirali veriyor; ayni
    // secim her zaman ayni adresi uretsin diye. Sirasiz bir adres ne
    // onbelleklenebilir ne test edilebilir.
    ...?selection?.toQueryParameters(),
  };

  if (query.isEmpty) return base;

  // Uri.queryParameters bir anahtara liste verilince parametreyi tekrar
  // eder: ?author=1&author=2. Sunucu bunu VEYA olarak yorumluyor
  // (canlida dogrulandi).
  return Uri(path: base, queryParameters: query).toString();
}
