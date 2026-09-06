import '../api/api_exception.dart';

/// Yazi govdesini olusturan blok turleri.
enum SectionKind { paragraph, heading, image, quote, embed }

/// Yazi govdesindeki tek bir blok.
///
/// Sunucu duz (flat) bir sema donduruyor: her blok, turu ne olursa olsun
/// tum alanlari tasiyor. Kullanilmayan metin alanlari "" gelir, yalnizca
/// image null gelir. Bu yuzden metin alanlarinda null kontrolu yetmez.
class PostSection {
  const PostSection({
    required this.order,
    required this.kind,
    required this.text,
    required this.headingLevel,
    required this.inToc,
    required this.image,
    required this.imageTitle,
    required this.imageCaption,
    required this.imageAlt,
    required this.quoteSource,
    required this.embedUrl,
  });

  final int order;
  final SectionKind kind;

  /// paragraph / heading / quote icin govde. Digerlerinde "".
  final String text;

  /// 'h2' veya 'h3'. Heading disinda "".
  final String headingLevel;

  /// Modelde tutulur, ekranda KULLANILMAZ. Icindekiler listesi KB-102'de
  /// yok; telefon ekraninda ayri bir tasarim isi.
  ///
  /// Not: sunucu bunu paragraph bloklarinda da true donduruyor, yani
  /// yalnizca basliga ozel bir alan degil.
  final bool inToc;

  /// null gelebilir.
  final String? image;

  final String imageTitle;
  final String imageCaption;
  final String imageAlt;
  final String quoteSource;

  /// embed blogunun adresi.
  ///
  /// KB-102'de kapsam disi: canli uctan cekilen 22 blogun hicbiri embed
  /// degildi, ornek veri yoktu. Bu yuzden tur burada taninir ve deger
  /// tasinir ama ekranda cizilmez, url_launcher da eklenmedi.
  final String embedUrl;

  /// Taninmayan `kind` gelirse null doner ve blok atlanir.
  ///
  /// Cokmek yerine atlamanin sebebi ileri uyumluluk: sunucuya yeni bir
  /// blok turu eklendiginde magazadaki eski surum calismaya devam etmeli.
  ///
  /// Dikkat: yalnizca BILINMEYEN TUR sessizce atlanir. Alan eksikse veya
  /// tipi yanlissa yine ApiException firlatilir — o ileri uyumluluk
  /// degil, gercek bir hatadir.
  static PostSection? tryParse(Map<String, dynamic> json) {
    final SectionKind? kind = _parseKind(_requireString(json, 'kind'));
    if (kind == null) return null;

    return PostSection(
      order: _requireInt(json, 'order'),
      kind: kind,
      text: _requireString(json, 'text'),
      headingLevel: _requireString(json, 'heading_level'),
      inToc: _requireBool(json, 'in_toc'),
      image: _optionalString(json, 'image'),
      imageTitle: _requireString(json, 'image_title'),
      imageCaption: _requireString(json, 'image_caption'),
      imageAlt: _requireString(json, 'image_alt'),
      quoteSource: _requireString(json, 'quote_source'),
      embedUrl: _requireString(json, 'embed_url'),
    );
  }

  @override
  String toString() => 'PostSection($order, ${kind.name})';
}

SectionKind? _parseKind(String raw) => switch (raw) {
  'paragraph' => SectionKind.paragraph,
  'heading' => SectionKind.heading,
  'image' => SectionKind.image,
  'quote' => SectionKind.quote,
  'embed' => SectionKind.embed,
  _ => null,
};

Never _missing(String key, Object? value) {
  throw ApiException.parse(
    value == null
        ? "PostSection: '$key' alani yok veya null"
        : "PostSection: '$key' alani beklenmeyen tipte: ${value.runtimeType}",
  );
}

String _requireString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  // Bos metin gecerli bir deger, yalnizca null/yanlis tip hata.
  if (value is String) return value;
  _missing(key, value);
}

int _requireInt(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is int) return value;
  _missing(key, value);
}

bool _requireBool(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is bool) return value;
  _missing(key, value);
}

/// null gecerli; yanlis tip degil.
String? _optionalString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  _missing(key, value);
}
