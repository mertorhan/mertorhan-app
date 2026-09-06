import '../api/api_exception.dart';

/// /api/v1/blog/ ucundaki tek bir yazi.
///
/// fromJson elle yazildi; kod uretimi yok. Eksik veya yanlis tipli alan
/// gelirse cokmek yerine [ApiException] firlatilir, boylece hata API
/// katmaninin normal hata yolundan akar.
class BlogPost {
  const BlogPost({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.category,
    required this.publishedAt,
    required this.readingTime,
    required this.coverImage,
    required this.isFeatured,
  });

  final int id;
  final String slug;
  final String title;

  /// Bos "" gelebilir; bu gecerli bir degerdir, yoklugu degil.
  /// Ekranda kullanmadan once isNotEmpty ile bakilmali.
  final String summary;

  /// null gelebilir.
  final String? category;

  final DateTime publishedAt;

  /// Dakika.
  final int readingTime;

  /// null gelebilir.
  final String? coverImage;

  final bool isFeatured;

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: _requireInt(json, 'id'),
      slug: _requireString(json, 'slug'),
      title: _requireString(json, 'title'),
      summary: _requireString(json, 'summary'),
      category: _optionalString(json, 'category'),
      publishedAt: _requireDate(json, 'published_at'),
      readingTime: _requireInt(json, 'reading_time'),
      coverImage: _optionalString(json, 'cover_image'),
      isFeatured: _requireBool(json, 'is_featured'),
    );
  }

  @override
  String toString() => 'BlogPost($id, $slug)';
}

Never _missing(String key, Object? value) {
  throw ApiException.parse(
    value == null
        ? "BlogPost: '$key' alani yok veya null"
        : "BlogPost: '$key' alani beklenmeyen tipte: ${value.runtimeType}",
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

/// "2026-08-19" bicimindeki metni tarihe cevirir.
///
/// Cozulemezse ApiException firlatilir; yerine bugunun tarihi veya epoch
/// KONULMAZ. Bu alan hem siralamada hem ekranda kullaniliyor; uydurma bir
/// tarih koymak, yanlis bilgiyi dogruymus gibi gostermek olur. Gurultulu
/// sekilde basarisiz olmak, sessizce yanlis olmaktan iyidir.
DateTime _requireDate(Map<String, dynamic> json, String key) {
  final String raw = _requireString(json, key);
  final DateTime? parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    throw ApiException.parse("BlogPost: '$key' tarihe cevrilemedi: '$raw'");
  }
  return parsed;
}
