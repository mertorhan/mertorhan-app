import '../api/api_exception.dart';
import 'blog_post.dart';
import 'post_section.dart';

/// Bir yazinin detayi: liste alanlari + govdeyi olusturan bloklar.
///
/// BlogPost'tan TUREMEK yerine ONU ICINDE TUTUYOR. Sebep: detay yanitindaki
/// dokuz alan liste yanitiyla birebir ayni, dolayisiyla kompozisyon mevcut
/// BlogPost.fromJson'i ayni map uzerinde oldugu gibi cagirabiliyor — sifir
/// tekrar, ustelik o parser KB-100'de zaten test edilmis. Kalitim secilseydi
/// super(...) cagrisi icin dokuz alani yeniden ayristirip elle gecirmek
/// gerekirdi. Ayrica BlogPost listeye ait kalir, detay kaygisi ona sizmaz.
class BlogPostDetail {
  const BlogPostDetail({required this.post, required this.sections});

  final BlogPost post;

  /// `order` alanina gore sirali. Taninmayan turdeki bloklar atlanmistir.
  final List<PostSection> sections;

  factory BlogPostDetail.fromJson(Map<String, dynamic> json) {
    final Object? raw = json['sections'];
    if (raw is! List) {
      throw ApiException.parse(
        "BlogPostDetail: 'sections' liste bekleniyordu, ${raw.runtimeType} geldi",
      );
    }

    final List<PostSection> sections = [];
    for (final (int index, Object? item) in raw.indexed) {
      if (item is! Map<String, dynamic>) {
        throw ApiException.parse(
          'BlogPostDetail: sections[$index] JSON nesnesi degil: '
          '${item.runtimeType}',
        );
      }
      // null donen bloklar taninmayan turdedir; atlanirlar.
      final PostSection? section = PostSection.tryParse(item);
      if (section != null) sections.add(section);
    }

    sections.sort((a, b) => a.order.compareTo(b.order));

    return BlogPostDetail(post: BlogPost.fromJson(json), sections: sections);
  }

  @override
  String toString() =>
      'BlogPostDetail(${post.slug}, ${sections.length} blok)';
}
