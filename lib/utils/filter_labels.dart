/// Filtre gruplarinin Turkce basliklari ve gosterim sirasi.
///
/// API yalnizca anahtar donduruyor ('author', 'year'); baslik ve sira
/// arayuz karari, bu yuzden burada.
///
/// ETIKETLER UC BASINA TANIMLI, tek global harita YOK. Sebep: ayni anahtar
/// iki ucta farkli sey demek — 'year' kitapta "Basim yili", filmde "Yapim
/// yili". Tek haritada birlestirilse biri digerinin yerine yazilirdi.
///
/// Sira sitedeki panel sirasiyla ayni: once kisiler, sonra olgular.
library;

import '../models/filter_options.dart';

/// (anahtar, baslik) ciftleri, gosterim sirasinda.
typedef FilterGroups = List<(String, String)>;

/// Kitap listesinin filtre gruplari.
const FilterGroups bookFilterGroups = [
  ('year', 'Basım yılı'),
  ('read_year', 'Okuma yılı'),
  ('author', 'Yazar'),
  ('translator', 'Çevirmen'),
  ('publisher', 'Yayınevi'),
  ('genre', 'Tür'),
  ('rating', 'Puan'),
];

/// Film ve dizi listesinin filtre gruplari.
///
/// 'actor' basligi OYUNCULAR, "Basrol" DEGIL: sunucu ad listelerini
/// alfabetik donduruyor, basrol sirasi korunmuyor. Gerekce
/// movie_detail_screen.dart'taki kunye satirinda yazili; ayni gerekce
/// burada da gecerli.
const FilterGroups movieFilterGroups = [
  ('content_type', 'Film / dizi'),
  ('year', 'Yapım yılı'),
  ('watched_year', 'İzleme yılı'),
  ('director', 'Yönetmen'),
  ('screenwriter', 'Senarist'),
  ('actor', 'Oyuncular'),
  ('genre', 'Tür'),
  ('rating', 'Puan'),
];

/// Blog ve galeri: tek grup.
const FilterGroups categoryFilterGroups = [('category', 'Kategori')];

/// [groups] icinden yalnizca [options]'ta karsiligi olanlari dondurur.
///
/// Iki yonlu eleme:
///   - Sunucunun gondermedigi grup cizilmez (secenek yok, baslik da yok)
///   - TANIMADIGIMIZ anahtar ATLANIR: sunucuya yeni bir filtre eklenirse
///     magazadaki eski surum basliksiz bir grup cizmek yerine onu sessizce
///     gecer. PostSection.tryParse'taki bilinmeyen blok kararinin aynisi.
FilterGroups visibleGroups(FilterGroups groups, FilterOptions options) {
  return groups
      .where(((String, String) g) => options.optionsFor(g.$1).isNotEmpty)
      .toList();
}
