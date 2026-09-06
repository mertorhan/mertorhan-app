import '../models/blog_post.dart';
import '../models/book.dart';
import '../models/photo.dart';
import '../models/review.dart';
import 'turkish_date.dart';
import 'turkish_number.dart';

/// Liste ogelerinin ust satirini kurar.
///
/// null VE bos parcalar atilir, kalanlar " · " ile birlestirilir. Boylece
/// ayrac ancak iki dolu parca arasinda olusur; satir asla " · " ile
/// baslamaz ve arada cift ayrac kalmaz.
///
/// Dort tur de bunu kullanir; ayrac mantigi tekrarlanmaz.
String joinMeta(List<String?> parts) =>
    parts.where((p) => p != null && p.isNotEmpty).join(' · ');

/// Blog: kategori · tarih · okuma suresi
String postMetaLine(BlogPost post) => joinMeta([
  post.category,
  formatTurkishDate(post.publishedAt),
  '${post.readingTime} dk',
]);

/// Film/dizi: tur · yil · puan
///
/// contentKind null ise (sunucudan taninmayan bir tur geldiyse) etiket
/// duser, kayit yine listelenir.
String reviewMetaLine(Review review) => joinMeta([
  switch (review.contentKind) {
    ContentKind.film => 'Film',
    ContentKind.dizi => 'Dizi',
    null => null,
  },
  review.releaseYear?.toString(),
  review.rating == null ? null : formatRating(review.rating!),
]);

/// Kitap: yazar · puan
String bookMetaLine(Book book) => joinMeta([
  book.author,
  book.rating == null ? null : formatRating(book.rating!),
]);

/// Galeri: kategori · konum
String photoMetaLine(Photo photo) =>
    joinMeta([photo.category, photo.location]);
