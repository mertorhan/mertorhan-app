import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/books_api.dart';
import '../models/book.dart';
import '../utils/meta_line.dart';
import '../widgets/media_tile.dart';
import '../widgets/paged_list_view.dart';

/// Yayinlar > Kitap sekmesinin govdesi.
///
/// DETAY EKRANI YOK: ogeye onTap verilmiyor. Detay ayri kart.
class BookListScreen extends StatefulWidget {
  const BookListScreen({this.api, super.key});

  final BooksApi? api;

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  ApiClient? _ownedClient;
  late final BooksApi _api;

  @override
  void initState() {
    super.initState();

    final BooksApi? injected = widget.api;
    if (injected != null) {
      _api = injected;
    } else {
      final ApiClient client = ApiClient();
      _ownedClient = client;
      _api = BooksApi(client: client);
    }
  }

  @override
  void dispose() {
    _ownedClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<Book>(
      fetch: _api.fetchBooks,
      emptyMessage: 'Henüz kitap yok',
      itemBuilder: (_, Book book) => MediaTile(
        imageUrl: book.coverImage,
        metaLine: bookMetaLine(book),
        title: book.title,
        summary: book.summary,
      ),
    );
  }
}
