import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/books_api.dart';
import '../models/book.dart';
import '../models/filter_options.dart';
import '../models/filter_selection.dart';
import '../utils/filter_labels.dart';
import '../utils/meta_line.dart';
import '../widgets/filter_bar.dart';
import '../widgets/filter_sheet.dart';
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

  FilterSelection _selection = const FilterSelection.empty();

  /// Panel ILK ACILDIGINDA cekilir, ekran acilisinda degil: filtreye
  /// dokunmayan kullaniciya ikinci bir istek yuku bindirmemek icin.
  /// Bir kez geldikten sonra saklanir.
  FilterOptions? _options;
  bool _optionsLoading = false;

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

  /// Filtre panelini acar; gerekirse once secenekleri ceker.
  Future<void> _openFilters() async {
    if (_optionsLoading) return;

    FilterOptions? options = _options;

    if (options == null) {
      setState(() => _optionsLoading = true);
      try {
        options = await _api.fetchFilterOptions();
        if (!mounted) return;
        setState(() {
          _options = options;
          _optionsLoading = false;
        });
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(() => _optionsLoading = false);
        // Hata saklanmiyor: ekranda cizilecek bir yeri yok, liste zaten
        // calisiyor. Kullaniciya bir kez soylenir, gecilir.
        _showSnack(e.userMessage);
        return;
      } catch (e) {
        if (!mounted) return;
        setState(() => _optionsLoading = false);
        _showSnack(const ApiException.parse('').userMessage);
        return;
      }
    }

    if (!mounted) return;

    // Secenek yoksa panel ACILMAZ. Canlida /filters/books/ su an bos nesne
    // donduruyor (kitap kunyeleri henuz girilmemis), yani bugun kitapta
    // her zaman bu dala giriliyor. Bombos bir panel acip kullaniciyi geri
    // dondurmek yerine durumu soyluyoruz.
    if (options.isEmpty) {
      _showSnack('Şu an filtrelenecek bir şey yok.');
      return;
    }

    final FilterSelection? secim = await showFilterSheet(
      context: context,
      options: options,
      current: _selection,
      groups: bookFilterGroups,
    );

    // null: kullanici ✕ ya da geri ile kapatti, hicbir sey degismez.
    // Ayni secim: gereksiz istek atmayalim. FilterSelection'in == tanimli.
    if (secim == null || secim == _selection) return;
    if (!mounted) return;
    setState(() => _selection = secim);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilterBar(
          selectedCount: _selection.count,
          onOpen: _openFilters,
          onClear: () => setState(() {
            _selection = const FilterSelection.empty();
          }),
        ),
        Expanded(
          child: PagedListView<Book>(
            // PagedListView'da didUpdateWidget YOK: closure degisse bile
            // yeniden cekmiyor. Secime bagli key verince Flutter eski
            // State'i atiyor, initState calisiyor ve liste yeni secimle
            // cekiliyor. Bu yaklasim tam da paged_list_view.dart'a
            // DOKUNMAMAK icin secildi. Ayni desen home_shell.dart'ta da
            // var (KeyedSubtree + ValueKey).
            //
            // Yan etki, bilincli: filtre degisince kaydirma basa doner.
            // Yeni bir liste geldigi icin dogru davranis.
            key: ValueKey<FilterSelection>(_selection),
            fetch: () => _api.fetchBooks(selection: _selection),
            emptyMessage: _selection.isEmpty
                ? 'Henüz kitap yok'
                : 'Bu filtreye uyan kitap yok',
            itemBuilder: (_, Book book) => MediaTile(
              imageUrl: book.coverImage,
              metaLine: bookMetaLine(book),
              title: book.title,
              summary: book.summary,
              onTap: () => _openBook(book),
            ),
          ),
        ),
      ],
    );
  }
}
