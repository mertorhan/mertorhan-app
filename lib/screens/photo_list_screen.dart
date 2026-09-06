import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/photos_api.dart';
import '../models/photo.dart';
import '../utils/meta_line.dart';
import '../widgets/media_tile.dart';
import '../widgets/paged_list_view.dart';

/// Yayinlar > Galeri sekmesinin govdesi.
///
/// TAM EKRAN GORUNTULEME YOK: fotografa dokunmak bu kartta bir sey
/// yapmiyor, o yuzden onTap verilmiyor. Ayri kart.
class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({this.api, super.key});

  final PhotosApi? api;

  @override
  State<PhotoListScreen> createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  ApiClient? _ownedClient;
  late final PhotosApi _api;

  @override
  void initState() {
    super.initState();

    final PhotosApi? injected = widget.api;
    if (injected != null) {
      _api = injected;
    } else {
      final ApiClient client = ApiClient();
      _ownedClient = client;
      _api = PhotosApi(client: client);
    }
  }

  @override
  void dispose() {
    _ownedClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<Photo>(
      fetch: _api.fetchPhotos,
      emptyMessage: 'Henüz fotoğraf yok',
      itemBuilder: (_, Photo photo) => MediaTile(
        // Kucuk gorsel varsa o, yoksa tam boy; ikisi de yoksa yer tutucu.
        imageUrl: photo.listImage,
        metaLine: photoMetaLine(photo),
        title: photo.title,
      ),
    );
  }
}
