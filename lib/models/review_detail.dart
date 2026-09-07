import 'json_parse.dart';
import 'review.dart';

/// Bir film veya dizi degerlendirmesinin detayi: liste alanlari + kunye
/// ve govde.
///
/// Review'den TUREMEK yerine ONU ICINDE TUTUYOR — BookDetail'deki
/// gerekcenin aynisi gecerli: detay yanitindaki on bir liste alani liste
/// yanitiyla birebir ayni, dolayisiyla kompozisyon mevcut Review.fromJson'i
/// ayni map uzerinde oldugu gibi cagirabiliyor. Sifir tekrar, ustelik o
/// parser zaten test edilmis. Ayrica Review listeye ait kalir, detay
/// kaygisi ona sizmaz.
///
/// Kitaptan farki: ALINTI YOK. BookDetail'deki quotes dongusunun burada
/// karsiligi yok, fromJson duz bir donus.
class ReviewDetail {
  const ReviewDetail({
    required this.review,
    required this.body,
    required this.directors,
    required this.screenwriters,
    required this.actors,
    required this.genres,
  });

  static const String _label = 'ReviewDetail';

  final Review review;

  /// DUZ METIN. Markdown islenmez.
  final String body;

  /// Kunye ad listeleri. Bos liste gelebilir; sunucu bu dortlukte hicbir
  /// zaman null dondurmuyor.
  ///
  /// Sira ALFABETIK gelir, onem sirasi degil. Bu yuzden actors satiri
  /// ekranda "BASROL" degil "OYUNCULAR" diye etiketlenir: ilk ismin
  /// basrol oldugunu ima etmek yanlis olurdu.
  final List<String> directors;
  final List<String> screenwriters;
  final List<String> actors;
  final List<String> genres;

  factory ReviewDetail.fromJson(Map<String, dynamic> json) {
    return ReviewDetail(
      review: Review.fromJson(json),
      body: requireString(json, 'body', _label),
      directors: requireStringList(json, 'directors', _label),
      screenwriters: requireStringList(json, 'screenwriters', _label),
      actors: requireStringList(json, 'actors', _label),
      genres: requireStringList(json, 'genres', _label),
    );
  }

  @override
  String toString() => 'ReviewDetail(${review.slug})';
}
