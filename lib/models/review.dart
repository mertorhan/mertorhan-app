import 'json_parse.dart';

/// /movies/ ucundaki icerik turu.
///
/// API ham deger donduruyor ("film" / "dizi"); gorunen etiket degil.
enum ContentKind { film, dizi }

/// Bir film veya dizi degerlendirmesi.
class Review {
  const Review({
    required this.id,
    required this.slug,
    required this.title,
    required this.contentKind,
    required this.coverImage,
    required this.releaseYear,
    required this.rating,
    required this.summary,
    required this.publishedAt,
    required this.watchedAt,
    required this.isFeatured,
  });

  static const String _label = 'Review';

  final int id;
  final String slug;
  final String title;

  /// Taninmayan bir content_type geldiginde null olur.
  ///
  /// KARAR: kayit ATILMAZ, yalnizca tur etiketi duser. PostSection'da
  /// blogu atlamak dogruydu cunku orada bilinmeyen olan seyin kendisiydi;
  /// burada bilinmeyen olan bir kaydin tek alani. Basligi, yili, puani,
  /// ozeti gecerli. Kaydi atmak kullanicidan gercek bir filmi gizlemek
  /// olur — sunucuya yeni bir tur eklendiginde eski surum icerigi yutar.
  final ContentKind? contentKind;

  /// null gelebilir.
  final String? coverImage;

  /// null gelebilir.
  final int? releaseYear;

  /// Tam puan int, ondalikli puan double gelir; ikisi de num.
  /// null gelebilir (puanlanmamis kayit).
  final num? rating;

  /// Bos "" gelebilir.
  final String summary;

  final DateTime publishedAt;

  /// null gelebilir (izlenmemis / tarihi girilmemis).
  final DateTime? watchedAt;

  final bool isFeatured;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: requireInt(json, 'id', _label),
      slug: requireString(json, 'slug', _label),
      title: requireString(json, 'title', _label),
      contentKind: _parseContentKind(
        requireString(json, 'content_type', _label),
      ),
      coverImage: optionalString(json, 'cover_image', _label),
      releaseYear: optionalInt(json, 'release_year', _label),
      rating: optionalNum(json, 'rating', _label),
      summary: requireString(json, 'summary', _label),
      publishedAt: requireDate(json, 'published_at', _label),
      watchedAt: optionalDate(json, 'watched_at', _label),
      isFeatured: requireBool(json, 'is_featured', _label),
    );
  }

  @override
  String toString() => 'Review($id, $slug)';
}

ContentKind? _parseContentKind(String raw) => switch (raw) {
  'film' => ContentKind.film,
  'dizi' => ContentKind.dizi,
  _ => null,
};
