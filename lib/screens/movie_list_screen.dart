import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/movies_api.dart';
import '../models/review.dart';
import '../utils/meta_line.dart';
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

  @override
  Widget build(BuildContext context) {
    return PagedListView<Review>(
      fetch: _api.fetchReviews,
      emptyMessage: 'Henüz film veya dizi yok',
      itemBuilder: (_, Review review) => MediaTile(
        imageUrl: review.coverImage,
        metaLine: reviewMetaLine(review),
        title: review.title,
        summary: review.summary,
        onTap: () => _openReview(review),
      ),
    );
  }
}
