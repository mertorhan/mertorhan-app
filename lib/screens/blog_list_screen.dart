import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/blog_api.dart';
import '../theme/app_colors.dart';
import '../widgets/blog_post_tile.dart';

/// Yayinlar sekmesi: blog yazilarinin listesi.
///
/// Durum yonetimi setState ile; paket yok. Sayfalama BU EKRANDA YOK,
/// yalnizca ilk sayfa cekilir. BlogPage.hasNextPage okunabilir durumda
/// ama kullanilmiyor; sonsuz kaydirma ayri kart.
class BlogListScreen extends StatefulWidget {
  const BlogListScreen({this.api, super.key});

  /// Testlerde sahte uygulama verilir. Uretimde null gecilir ve ekran
  /// kendi istemcisini kurup sahipligini ustlenir.
  final BlogApi? api;

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  /// Yalnizca ekranin kendi kurdugu istemci; disaridan gelen sahte
  /// uygulamanin istemcisi kapatilmaz, sahibi biz degiliz.
  ApiClient? _ownedClient;
  late final BlogApi _api;

  bool _loading = true;
  ApiException? _error;
  BlogPage? _page;

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

    _load();
  }

  @override
  void dispose() {
    _ownedClient?.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final BlogPage page = await _api.fetchPosts();
      // Sekme durumu korunmuyor: istek ucusurken kullanici baska sekmeye
      // gecerse bu ekran agactan silinir. O halde setState olu State
      // uzerinde calisir ve hata verir.
      if (!mounted) return;
      setState(() {
        _page = page;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    } catch (e) {
      // ApiException disi bir sey de gelse ekran cokmemeli.
      if (!mounted) return;
      setState(() {
        _error = ApiException.parse('beklenmeyen hata: $e');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yayınlar')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: switch (_error) {
        final ApiException error => _MessageView(
          message: error.userMessage,
          action: FilledButton(
            onPressed: _load,
            child: const Text('Tekrar dene'),
          ),
        ),
        // Hata yoksa _page dolu; ilk kare zaten _loading ile ayrildi.
        null when _page!.posts.isEmpty => const _MessageView(
          message: 'Henüz yazı yok',
        ),
        null => ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _page!.posts.length,
          separatorBuilder: (_, _) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (_, int index) =>
              BlogPostTile(post: _page!.posts[index]),
        ),
      },
    );
  }
}

/// Hata ve bos durumlarin ortak govdesi.
///
/// Kaydirilabilir, cunku RefreshIndicator ancak kaydirilabilir bir cocukla
/// calisir; boylece bu durumlarda da asagi cekip yenilenebiliyor.
class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(height: 16),
                      action!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
