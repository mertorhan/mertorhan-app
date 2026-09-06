import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/movies_api.dart';
import '../models/review.dart';
import '../utils/meta_line.dart';
import '../widgets/media_tile.dart';
import '../widgets/paged_list_view.dart';

/// Yayinlar > Film ve dizi sekmesinin govdesi.
///
/// DETAY EKRANI YOK: ogeye onTap verilmiyor, boylece tiklanabilir gorunup
/// hicbir sey yapmiyor olmuyor. Detay ayri kart.
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
      ),
    );
  }
}
