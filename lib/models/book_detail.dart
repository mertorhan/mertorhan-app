import '../api/api_exception.dart';
import 'book.dart';
import 'book_quote.dart';
import 'json_parse.dart';

/// Bir kitabin detayi: liste alanlari + kunye, govde ve alintilar.
///
/// Book'tan TUREMEK yerine ONU ICINDE TUTUYOR — BlogPostDetail'deki
/// gerekcenin aynisi gecerli: detay yanitindaki on iki liste alani liste
/// yanitiyla birebir ayni, dolayisiyla kompozisyon mevcut Book.fromJson'i
/// ayni map uzerinde oldugu gibi cagirabiliyor. Sifir tekrar, ustelik o
/// parser zaten test edilmis. Kalitim secilseydi super(...) cagrisi icin
/// on iki alani yeniden ayristirip elle gecirmek gerekirdi. Ayrica Book
/// listeye ait kalir, detay kaygisi ona sizmaz.
class BookDetail {
  const BookDetail({
    required this.book,
    required this.body,
    required this.quotes,
    required this.authors,
    required this.translators,
    required this.genres,
    required this.publisher,
  });

  static const String _label = 'BookDetail';

  final Book book;

  /// DUZ METIN. Markdown islenmez.
  final String body;

  /// `order` alanina gore sirali.
  final List<BookQuote> quotes;

  /// Kunye ad listeleri. Bos liste gelebilir.
  ///
  /// Book.author / Book.translator duz metin alanlari HALA duruyor ve
  /// liste ekrani onlari kullaniyor; kunye ise bu listelerden cizilir.
  /// Site tarafinda da boyle.
  final List<String> authors;
  final List<String> translators;
  final List<String> genres;

  /// TEKIL dize ya da null — ad listelerinin aksine liste degil.
  final String? publisher;

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    final Object? raw = json['quotes'];
    if (raw is! List) {
      throw ApiException.parse(
        "$_label: 'quotes' liste bekleniyordu, ${raw.runtimeType} geldi",
      );
    }

    final List<BookQuote> quotes = [];
    for (final (int index, Object? item) in raw.indexed) {
      if (item is! Map<String, dynamic>) {
        throw ApiException.parse(
          '$_label: quotes[$index] JSON nesnesi degil: ${item.runtimeType}',
        );
      }
      quotes.add(BookQuote.fromJson(item));
    }

    quotes.sort((a, b) => a.order.compareTo(b.order));

    return BookDetail(
      book: Book.fromJson(json),
      body: requireString(json, 'body', _label),
      quotes: quotes,
      authors: requireStringList(json, 'authors', _label),
      translators: requireStringList(json, 'translators', _label),
      genres: requireStringList(json, 'genres', _label),
      publisher: optionalString(json, 'publisher', _label),
    );
  }

  @override
  String toString() => 'BookDetail(${book.slug}, ${quotes.length} alinti)';
}
