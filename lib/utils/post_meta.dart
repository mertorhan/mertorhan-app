import '../models/blog_post.dart';
import 'turkish_date.dart';

/// Yazinin ust satiri: kategori · tarih · okuma suresi.
///
/// Parcalar once listeye toplanir, sonra birlestirilir. Boylece category
/// null oldugunda ayraci da dusmus olur; satir " · " ile baslayamaz.
///
/// Hem liste ogesi hem detay ekrani bunu kullanir; mantik tekrarlanmaz.
String postMetaLine(BlogPost post) {
  final List<String> parts = [
    if (post.category != null) post.category!,
    formatTurkishDate(post.publishedAt),
    '${post.readingTime} dk',
  ];
  return parts.join(' · ');
}
