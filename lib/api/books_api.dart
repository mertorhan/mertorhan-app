import '../models/book.dart';
import '../models/book_detail.dart';
import 'api_client.dart';
import 'paged_response.dart';

/// Kitap degerlendirmeleri.
class BooksApi {
  BooksApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<PagedResponse<Book>> fetchBooks({int page = 1}) async {
    final String path = page <= 1 ? 'books/' : 'books/?page=$page';
    final Map<String, dynamic> json = await _client.getJson(path);
    return parsePagedResponse(json, Book.fromJson, label: 'books/');
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
