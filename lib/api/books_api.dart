import '../models/book.dart';
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
}
