import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/blog_api.dart';
import '../models/blog_post_detail.dart';
import '../models/post_section.dart';
import '../theme/app_colors.dart';
import '../utils/meta_line.dart';
import '../widgets/quote_box.dart';

/// Tek bir yazinin detayi.
///
/// Govde duz metin olarak basilir; markdown islenmiyor (site tarafinda da
/// henuz islenmiyor, ayri kart).
class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({required this.slug, this.api, super.key});

  final String slug;

  /// Testlerde sahte uygulama verilir. Uretimde null gecilir ve ekran
  /// kendi istemcisini kurup sahipligini ustlenir.
  final BlogApi? api;

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  /// Yalnizca ekranin kendi kurdugu istemci; disaridan gelenin sahibi
  /// biz degiliz, kapatilmaz.
  ApiClient? _ownedClient;
  late final BlogApi _api;

  bool _loading = true;
  ApiException? _error;
  BlogPostDetail? _detail;

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
      final BlogPostDetail detail = await _api.fetchPost(widget.slug);
      // Istek ucusurken kullanici geri donebilir; o halde bu ekran agactan
      // silinmis olur ve setState olu State uzerinde calisir.
      if (!mounted) return;
      setState(() {
        _detail = detail;
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
      // Baslik yok, yalnizca geri dugmesi. Yazi basligi govdenin en ustunde
      // tam haliyle ve buyuk puntoyla zaten duruyor; aynisini AppBar'a
      // kirpilmis halde koymak onu ikinci kez, daha kotu gostermek olur.
      // Sabit bir etiket ("Yayın") ise hicbir bilgi tasimaz.
      appBar: AppBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final ApiException? error = _error;
    if (error != null) {
      return _ErrorView(message: error.userMessage, onRetry: _load);
    }

    // Bos durum yok: yazi ya vardir ya sunucu 404 doner.
    return _DetailBody(detail: _detail!);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  static const EdgeInsets _side = EdgeInsets.symmetric(horizontal: 16);

  final BlogPostDetail detail;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? cover = detail.post.coverImage;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Tam genislik, kirpma yok: yukseklik gorselin kendi oranindan
        // gelir (KB-87). Kapak yoksa hic cizilmez, bosluk birakilmaz.
        if (cover != null)
          Image.network(
            cover,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        Padding(
          padding: _side.copyWith(top: 16, bottom: 4),
          child: Text(detail.post.title, style: textTheme.headlineMedium),
        ),
        Padding(
          padding: _side,
          child: Text(
            postMetaLine(detail.post),
            style: textTheme.labelMedium?.copyWith(color: AppColors.secondary),
          ),
        ),
        const SizedBox(height: 8),
        for (final PostSection section in detail.sections)
          _SectionView(section: section),
      ],
    );
  }
}

/// Tek bir blogun cizimi.
class _SectionView extends StatelessWidget {
  const _SectionView({required this.section});

  final PostSection section;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return switch (section.kind) {
      SectionKind.paragraph => _Block(
        child: Text(section.text, style: textTheme.bodyLarge),
      ),

      // h2 ve h3 farkli tema katmanlari; sabit puntolar yazilmaz.
      SectionKind.heading => _Block(
        child: Text(
          section.text,
          style: section.headingLevel == 'h3'
              ? textTheme.titleLarge
              : textTheme.headlineSmall,
        ),
      ),

      SectionKind.image => _ImageBlock(section: section),

      SectionKind.quote => _QuoteBlock(section: section),

      // KB-102'de kapsam disi: canli uctan cekilen 22 blogun hicbiri embed
      // degildi, ornek veri yoktu. Tur modelde taniniyor ve embedUrl
      // tasiniyor ama ekranda cizilmiyor; url_launcher da eklenmedi.
      SectionKind.embed => const SizedBox.shrink(),
    };
  }
}

/// Bloklarin ortak kenar boslugu.
class _Block extends StatelessWidget {
  const _Block({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: child,
    );
  }
}

class _ImageBlock extends StatelessWidget {
  const _ImageBlock({required this.section});

  final PostSection section;

  @override
  Widget build(BuildContext context) {
    final String? url = section.image;
    // Gorsel yoksa blok hic cizilmez; basligi ve altyazisi da gitmis olur.
    if (url == null) return const SizedBox.shrink();

    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metin alanlari "" gelebilir; null kontrolu yetmez.
          if (section.imageTitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(section.imageTitle, style: textTheme.titleSmall),
            ),
          Image.network(
            url,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
          if (section.imageCaption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text(
                section.imageCaption,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  const _QuoteBlock({required this.section});

  final PostSection section;

  @override
  Widget build(BuildContext context) {
    // Kutu stili QuoteBox'ta; kitap detayi da ayni kutuyu ciziyor.
    // Kaynak bos "" gelebilir, o zaman satiri QuoteBox cizmiyor.
    return _Block(
      child: QuoteBox(text: section.text, source: section.quoteSource),
    );
  }
}
