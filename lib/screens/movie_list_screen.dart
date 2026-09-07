import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/movies_api.dart';
import '../models/filter_options.dart';
import '../models/filter_selection.dart';
import '../models/review.dart';
import '../utils/filter_labels.dart';
import '../utils/meta_line.dart';
import '../widgets/filter_bar.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/media_tile.dart';
import '../widgets/paged_list_view.dart';
import 'movie_detail_screen.dart';

/// Yayinlar > Film ve dizi sekmesinin govdesi.
///
/// Kendi AppBar'i YOK: ust sekmelerin AppBar'i PublicationsScreen'de,
/// bu ekran onun TabBarView cocugu.
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({this.api, super.key});

  final MoviesApi? api;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  ApiClient? _ownedClient;
  late final MoviesApi _api;

  FilterSelection _selection = const FilterSelection.empty();

  /// Panel ILK ACILDIGINDA cekilir, ekran acilisinda degil: filtreye
  /// dokunmayan kullaniciya ikinci bir istek yuku bindirmemek icin.
  /// Bir kez geldikten sonra saklanir.
  FilterOptions? _options;
  bool _optionsLoading = false;

  @override
  void initState() {
    super.initState();

    final MoviesApi? injected = widget.api;
    if (injected != null) {
      _api = injected;
    } else {
      final ApiClient client = ApiClient();
      _ownedClient = client;
      _api = MoviesApi(client: client);
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
  void _openReview(Review review) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MovieDetailScreen(slug: review.slug, api: widget.api),
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

    // Secenek yoksa panel ACILMAZ. Bombos bir panel acip kullaniciyi geri
    // dondurmek yerine durumu soyluyoruz. Sunucuya kunye girildiginde
    // kendiliginden calismaya baslar.
    if (options.isEmpty) {
      _showSnack('Şu an filtrelenecek bir şey yok.');
      return;
    }

    final FilterSelection? secim = await showFilterSheet(
      context: context,
      options: options,
      current: _selection,
      groups: movieFilterGroups,
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
          child: PagedListView<Review>(
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
            fetch: () => _api.fetchReviews(selection: _selection),
            emptyMessage: _selection.isEmpty
                ? 'Henüz film veya dizi yok'
                : 'Bu filtreye uyan film veya dizi yok',
            itemBuilder: (_, Review review) => MediaTile(
              imageUrl: review.coverImage,
              metaLine: reviewMetaLine(review),
              title: review.title,
              summary: review.summary,
              onTap: () => _openReview(review),
            ),
          ),
        ),
      ],
    );
  }
}
