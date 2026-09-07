/// Modellerin ortak JSON ayristirma yardimcilari.
///
/// KB-100'deki BlogPost kalibinin paylasilan hali. Her yardimci `label`
/// alir; hata mesajinda hangi modelin hangi alani sorunlu, o yaziyor.
///
/// Not: blog_post.dart ve post_section.dart hala kendi private kopyalarini
/// kullaniyor. Onlari buraya tasimak KB-100/KB-102'nin isi, bu kartin
/// kapsami degil — ayri kart konusu.
library;

import '../api/api_exception.dart';

Never missing(String label, String key, Object? value) {
  throw ApiException.parse(
    value == null
        ? "$label: '$key' alani yok veya null"
        : "$label: '$key' alani beklenmeyen tipte: ${value.runtimeType}",
  );
}

/// Bos metin gecerli bir degerdir; yalnizca null/yanlis tip hata.
String requireString(Map<String, dynamic> json, String key, String label) {
  final Object? value = json[key];
  if (value is String) return value;
  missing(label, key, value);
}

int requireInt(Map<String, dynamic> json, String key, String label) {
  final Object? value = json[key];
  if (value is int) return value;
  missing(label, key, value);
}

bool requireBool(Map<String, dynamic> json, String key, String label) {
  final Object? value = json[key];
  if (value is bool) return value;
  missing(label, key, value);
}

/// null gecerli; yanlis tip degil.
String? optionalString(Map<String, dynamic> json, String key, String label) {
  final Object? value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  missing(label, key, value);
}

int? optionalInt(Map<String, dynamic> json, String key, String label) {
  final Object? value = json[key];
  if (value == null) return null;
  if (value is int) return value;
  missing(label, key, value);
}

/// Puan gibi alanlar icin: tam deger int, ondalikli deger double gelir.
/// requireInt/optionalInt ikisini birden karsilamaz, bu yuzden num.
///
/// bool da teknik olarak num degil ama JSON'da sayi bekledigimiz yere
/// bool gelirse bu bir hatadir; `is num` onu zaten elemez, bool num
/// degildir.
num? optionalNum(Map<String, dynamic> json, String key, String label) {
  final Object? value = json[key];
  if (value == null) return null;
  if (value is num) return value;
  missing(label, key, value);
}

/// Ad listeleri icin: ["Dostoyevski", "Tolstoy"].
///
/// Bos liste GECERLI bir degerdir, yoklugu degil — kunye alani girilmemis
/// kitapta [] gelir. Liste degilse veya icinde metin olmayan bir oge varsa
/// hata; hangi ogenin bozuk oldugu indeksle raporlanir, cunku uzun bir
/// listede "liste bozuk" demek hata ayiklamaya yetmiyor.
List<String> requireStringList(
  Map<String, dynamic> json,
  String key,
  String label,
) {
  final Object? raw = json[key];
  if (raw is! List) {
    throw ApiException.parse(
      "$label: '$key' liste bekleniyordu, ${raw.runtimeType} geldi",
    );
  }

  final List<String> values = [];
  for (final (int index, Object? item) in raw.indexed) {
    if (item is! String) {
      throw ApiException.parse(
        "$label: $key[$index] metin degil: ${item.runtimeType}",
      );
    }
    values.add(item);
  }
  return values;
}

/// "2026-08-19" bicimindeki metni tarihe cevirir.
///
/// Cozulemezse ApiException firlatilir; yerine bugunun tarihi veya epoch
/// KONULMAZ (KB-100'deki gerekce): uydurma tarih, yanlis bilgiyi dogruymus
/// gibi gostermek olur.
DateTime requireDate(Map<String, dynamic> json, String key, String label) {
  final String raw = requireString(json, key, label);
  final DateTime? parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    throw ApiException.parse("$label: '$key' tarihe cevrilemedi: '$raw'");
  }
  return parsed;
}

/// Tarih null olabilir; dolu ama cozulemiyorsa yine hata.
DateTime? optionalDate(Map<String, dynamic> json, String key, String label) {
  final Object? value = json[key];
  if (value == null) return null;
  return requireDate(json, key, label);
}
