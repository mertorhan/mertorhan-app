import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/movies_api.dart';
import '../models/review_detail.dart';
import '../theme/app_colors.dart';
import '../utils/meta_line.dart';
import '../utils/turkish_date.dart';
import '../utils/turkish_number.dart';
import '../widgets/credits_block.dart';
import '../widgets/error_view.dart';

/// Tek bir film veya dizinin detayi.
///
/// Govde duz metin olarak basilir; markdown islenmiyor (kitap ve blog
/// detayindaki kararin aynisi, site tarafinda da islenmiyor).
class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({required this.slug, this.api, super.key});

  final String slug;

  /// Testlerde sahte uygulama verilir. Uretimde null gecilir ve ekran
  /// kendi istemcisini kurup sahipligini ustlenir.
  final MoviesApi? api;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  /// Yalnizca ekranin kendi kurdugu istemci; disaridan gelenin sahibi
  /// biz degiliz, kapatilmaz.
  ApiClient? _ownedClient;
  late final MoviesApi _api;

  bool _loading = true;
  ApiException? _error;
  ReviewDetail? _detail;

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
      final ReviewDetail detail = await _api.fetchReview(widget.slug);
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
      // Baslik yok, yalnizca geri dugmesi. Film adi govdenin en ustunde
      // tam haliyle zaten duruyor; kitap ve blog detayindaki kararin
      // aynisi.
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
      return ErrorView(message: error.userMessage, onRetry: _load);
    }

    // Bos durum yok: kayit ya vardir ya sunucu 404 doner.
    return _DetailBody(detail: _detail!);
  }
}

/// Filmin kunye satirlari: kisiler, sonra olgular, sonra tur.
///
/// Bos degerleri eleme ve "hic satir kalmazsa blogu cizme" isi
/// CreditsBlock'ta; burada yalnizca hangi alanin hangi etiketle
/// gosterildigi duruyor.
///
/// OYUNCULAR, "BASROL" DEGIL: sunucu ad listelerini alfabetik
/// donduruyor, basrol sirasi korunmuyor (canlida dogrulandi — Crazy
/// Stupid Love'da basrol Steve Carell ama listede ucuncu). "Basrol"
/// demek ekrandaki ilk ismin basrol oldugunu ima ederdi; veri o bilgiyi
/// tasimiyor. Sirayi duzeltemeyiz, etiketi duzeltebiliriz.
List<(String, String)> _movieCreditRows(ReviewDetail detail) {
  final DateTime? watchedAt = detail.review.watchedAt;

  return <(String, String)>[
    ('YÖNETMEN', joinMeta(detail.directors)),
    ('SENARİST', joinMeta(detail.screenwriters)),
    ('OYUNCULAR', joinMeta(detail.actors)),
    ('YAPIM YILI', detail.review.releaseYear?.toString() ?? ''),
    // 'Mart 2026' bicimi: gun yok.
    ('İZLEDİĞİM', watchedAt == null ? '' : formatTurkishMonthYear(watchedAt)),
    ('TÜR', joinMeta(detail.genres)),
  ];
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  static const EdgeInsets _side = EdgeInsets.symmetric(horizontal: 16);

  /// Afisin en fazla kaplayacagi yukseklik.
  ///
  /// Kitap kapagindaki gerekcenin aynisi: film afisleri de dikey, tam
  /// genislikte ekran boyunu asip basligi asagi itiyorlar. Sinirli
  /// yukseklik + contain ile afis KIRPILMIYOR (KB-101 karari) ama
  /// baslik da ilk ekranda kaliyor.
  static const double _coverMaxHeight = 320;

  final ReviewDetail detail;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? cover = detail.review.coverImage;
    final num? rating = detail.review.rating;

    // Ust satir: tur ve puan. YAPIM YILI BURADA YOK, o kunyeye ait —
    // reviewMetaLine kullanilmiyor cunku o yili da katiyor. Liste
    // ogesinde yil olmasi dogru, orada kunye yok.
    final String metaLine = joinMeta([
      contentKindLabel(detail.review.contentKind),
      rating == null ? null : formatRating(rating),
    ]);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Afis yoksa hic cizilmez, bosluk birakilmaz.
        if (cover != null)
          Padding(
            padding: _side.copyWith(top: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: _coverMaxHeight),
                child: Image.network(
                  cover,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        Padding(
          padding: _side.copyWith(top: 16, bottom: 4),
          child: Text(detail.review.title, style: textTheme.headlineMedium),
        ),
        // Tur de puan da dusebilir; ikisi de yoksa satir hic cizilmez.
        if (metaLine.isNotEmpty)
          Padding(
            padding: _side,
            child: Text(
              metaLine,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        CreditsBlock(rows: _movieCreditRows(detail)),
        // Govde bos "" gelebilir; null kontrolu yetmez.
        if (detail.body.isNotEmpty)
          Padding(
            padding: _side.copyWith(top: 16),
            child: Text(detail.body, style: textTheme.bodyLarge),
          ),
      ],
    );
  }
}
