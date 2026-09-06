import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/blog_api.dart';
import '../models/blog_post.dart';
import '../utils/meta_line.dart';
import '../widgets/media_tile.dart';
import '../widgets/paged_list_view.dart';
import 'blog_detail_screen.dart';

/// Yayinlar > Blog sekmesinin govdesi.
///
/// Kendi AppBar'i YOK: ust sekmelerin AppBar'i PublicationsScreen'de,
/// bu ekran onun TabBarView cocugu.
class BlogListScreen extends StatefulWidget {
  const BlogListScreen({this.api, super.key});

  /// Testlerde sahte uygulama verilir. Uretimde null gecilir ve ekran
  /// kendi istemcisini kurup sahipligini ustlenir.
  final BlogApi? api;

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  /// Yalnizca ekranin kendi kurdugu istemci; disaridan gelenin sahibi
  /// biz degiliz, kapatilmaz.
  ApiClient? _ownedClient;
  late final BlogApi _api;

  @override
  void initState() {
    super.initState();

    final BlogApi? injected = widget.api;
    if (injected != null) {
      _api = injected;
    } else {
      final ApiClient client = ApiClient();
      _ownedClient = client;
      _api = BlogApi(client: client);
    }
  }

  @override
  void dispose() {
    _ownedClient?.close();
    super.dispose();
  }

  /// Detay ekranini acar.
  ///
  /// widget.api asagi geciriliyor: uretimde null oldugu icin detay kendi
  /// istemcisini kurar; testte sahte uygulama akar ve gezinme testi de
  /// aga cikmaz.
  void _openPost(BlogPost post) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlogDetailScreen(slug: post.slug, api: widget.api),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<BlogPost>(
      fetch: _api.fetchPosts,
      emptyMessage: 'Henüz yazı yok',
      itemBuilder: (_, BlogPost post) => MediaTile(
        imageUrl: post.coverImage,
        metaLine: postMetaLine(post),
        title: post.title,
        summary: post.summary,
        onTap: () => _openPost(post),
      ),
    );
  }
}
