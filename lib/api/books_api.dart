import '../models/book.dart';
import '../models/book_detail.dart';
import '../models/filter_options.dart';
import '../models/filter_selection.dart';
import 'api_client.dart';
import 'paged_response.dart';
import 'query.dart';

/// Kitap degerlendirmeleri.
class BooksApi {
  BooksApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// [selection] verilmezse filtre parametresi yazilmaz ve adres eskisiyle
  /// birebir ayni kalir.
  Future<PagedResponse<Book>> fetchBooks({
    int page = 1,
    FilterSelection? selection,
  }) async {
    final String path = buildPath('books/', page: page, selection: selection);
    final Map<String, dynamic> json = await _client.getJson(path);
    return parsePagedResponse(json, Book.fromJson, label: 'books/');
  }

  /// Kitap listesinin filtre secenekleri.
  ///
  /// Canlida su an bos nesne donuyor: kitap kunyeleri henuz girilmemis,
  /// yani tek bir secenek bile yok. Bu hata degil, bos sonuc.
  Future<FilterOptions> fetchFilterOptions() async {
    final Map<String, dynamic> json = await _client.getJson('filters/books/');
    return FilterOptions.fromJson(json);
  }

  /// Tek bir kitabin detayi.
  ///
  /// Olmayan slug icin sunucu 404 doner; ApiClient durum kodu 200 degilse
  /// zaten ApiException.server(404) firlatiyor, burada ek kod gerekmiyor.
  Future<BookDetail> fetchBook(String slug) async {
    final Map<String, dynamic> json = await _client.getJson('books/$slug/');
    return BookDetail.fromJson(json);
  }
}
