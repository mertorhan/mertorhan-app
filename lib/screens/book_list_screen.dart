import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/books_api.dart';
import '../models/book.dart';
import '../utils/meta_line.dart';
import '../widgets/media_tile.dart';
import '../widgets/paged_list_view.dart';
import 'book_detail_screen.dart';

/// Yayinlar > Kitap sekmesinin govdesi.
///
/// Kendi AppBar'i YOK: ust sekmelerin AppBar'i PublicationsScreen'de,
/// bu ekran onun TabBarView cocugu.
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

  /// Detay ekranini acar.
  ///
  /// widget.api asagi geciriliyor, _api DEGIL: uretimde null oldugu icin
  /// detay kendi istemcisini kurar. _api gecilseydi detay, listenin sahibi
  /// oldugu ApiClient'i odunc alirdi ve liste dispose olunca kapali bir
  /// istemcinin uzerinde kalirdi. Testte de sahte uygulama akar, gezinme
  /// testi aga cikmaz.
  void _openBook(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookDetailScreen(slug: book.slug, api: widget.api),
      ),
    );
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
        onTap: () => _openBook(book),
      ),
    );
  }
}
