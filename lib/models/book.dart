import 'json_parse.dart';

/// Bir kitap degerlendirmesi.
class Book {
  const Book({
    required this.id,
    required this.slug,
    required this.title,
    required this.author,
    required this.translator,
    required this.coverImage,
    required this.rating,
    required this.summary,
    required this.publishedAt,
    required this.releaseYear,
    required this.readAt,
    required this.isFeatured,
  });

  static const String _label = 'Book';

  final int id;
  final String slug;
  final String title;

  /// DUZ METIN alan, iliski degil. Bos "" gelebilir.
  final String author;

  /// DUZ METIN alan. Ceviri olmayan kitaplarda "" gelir.
  final String translator;

  /// null gelebilir.
  final String? coverImage;

  /// Tam puan int, ondalikli puan double gelir. null gelebilir.
  final num? rating;

  /// Bos "" gelebilir.
  final String summary;

  final DateTime publishedAt;

  /// Kitabin basim yili. null gelebilir (kunyeye girilmemis).
  final int? releaseYear;

  /// Okunma tarihi. null gelebilir.
  ///
  /// Ekranda yalnizca ay ve yil gosterilir; gun hassasiyeti bir kitabi
  /// "su gun bitirdim" diye isaretlemek olurdu, veri o kadar kesin degil.
  final DateTime? readAt;

  final bool isFeatured;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: requireInt(json, 'id', _label),
      slug: requireString(json, 'slug', _label),
      title: requireString(json, 'title', _label),
      author: requireString(json, 'author', _label),
      translator: requireString(json, 'translator', _label),
      coverImage: optionalString(json, 'cover_image', _label),
      rating: optionalNum(json, 'rating', _label),
      summary: requireString(json, 'summary', _label),
      publishedAt: requireDate(json, 'published_at', _label),
      releaseYear: optionalInt(json, 'release_year', _label),
      readAt: optionalDate(json, 'read_at', _label),
      isFeatured: requireBool(json, 'is_featured', _label),
    );
  }

  @override
  String toString() => 'Book($id, $slug)';
}
