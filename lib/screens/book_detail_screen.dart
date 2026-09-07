import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/books_api.dart';
import '../models/book_detail.dart';
import '../models/book_quote.dart';
import '../theme/app_colors.dart';
import '../utils/meta_line.dart';
import '../utils/turkish_date.dart';
import '../utils/turkish_number.dart';
import '../widgets/credits_block.dart';
import '../widgets/error_view.dart';
import '../widgets/quote_box.dart';

/// Tek bir kitabin detayi.
///
/// Govde duz metin olarak basilir; markdown islenmiyor (blog detayindaki
/// kararin aynisi, site tarafinda da islenmiyor).
class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({required this.slug, this.api, super.key});

  final String slug;

  /// Testlerde sahte uygulama verilir. Uretimde null gecilir ve ekran
  /// kendi istemcisini kurup sahipligini ustlenir.
  final BooksApi? api;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  /// Yalnizca ekranin kendi kurdugu istemci; disaridan gelenin sahibi
  /// biz degiliz, kapatilmaz.
  ApiClient? _ownedClient;
  late final BooksApi _api;

  bool _loading = true;
  ApiException? _error;
  BookDetail? _detail;

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
      final BookDetail detail = await _api.fetchBook(widget.slug);
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
      // Baslik yok, yalnizca geri dugmesi. Kitap adi govdenin en ustunde
      // tam haliyle zaten duruyor; blog detayindaki kararin aynisi.
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

    // Bos durum yok: kitap ya vardir ya sunucu 404 doner.
    return _DetailBody(detail: _detail!);
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  static const EdgeInsets _side = EdgeInsets.symmetric(horizontal: 16);

  /// Kapagin en fazla kaplayacagi yukseklik.
  ///
  /// Blog detayindaki tam genislik yerlesim burada ise yaramiyor: kitap
  /// kapaklari dikey, tam genislikte ekran boyunu asip basligi asagi
  /// itiyorlar. Sinirli yukseklik + contain ile kapak KIRPILMIYOR
  /// (KB-101 karari) ama baslik da ilk ekranda kaliyor.
  static const double _coverMaxHeight = 320;

  final BookDetail detail;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? cover = detail.book.coverImage;
    final num? rating = detail.book.rating;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Kapak yoksa hic cizilmez, bosluk birakilmaz.
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
          child: Text(detail.book.title, style: textTheme.headlineMedium),
        ),
        // Ust satirda YALNIZCA puan var. bookMetaLine kullanilmiyor: o
        // yazari da katiyor, yazar artik kunyeye ait.
        if (rating != null)
          Padding(
            padding: _side,
            child: Text(
              formatRating(rating),
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        CreditsBlock(rows: _bookCreditRows(detail)),
        // Govde bos "" gelebilir; null kontrolu yetmez.
        if (detail.body.isNotEmpty)
          Padding(
            padding: _side.copyWith(top: 16),
            child: Text(detail.body, style: textTheme.bodyLarge),
          ),
        for (final BookQuote quote in detail.quotes)
          Padding(
            padding: _side.copyWith(top: 8, bottom: 8),
            // Sayfa bos "" gelebilir; o zaman satiri QuoteBox cizmiyor.
            child: QuoteBox(text: quote.text, source: quote.page),
          ),
      ],
    );
  }
}

/// Kitabin kunye satirlari.
///
/// Bos degerleri eleme ve "hic satir kalmazsa blogu cizme" isi
/// CreditsBlock'ta; burada yalnizca hangi alanin hangi etiketle
/// gosterildigi duruyor.
///
/// Canlida su an dort kitabin dordunde de kunye bos, yani blok bugun
/// hic cizilmiyor; bu dogru davranis.
List<(String, String)> _bookCreditRows(BookDetail detail) {
  final DateTime? readAt = detail.book.readAt;

  return <(String, String)>[
    // Duz metin book.author / book.translator KULLANILMIYOR; kunye
    // yeni ad listelerinden ciziliyor. Site tarafinda da boyle.
    ('YAZAR', joinMeta(detail.authors)),
    ('ÇEVİRMEN', joinMeta(detail.translators)),
    ('YAYINEVİ', detail.publisher ?? ''),
    ('BASIM YILI', detail.book.releaseYear?.toString() ?? ''),
    // 'Mart 2026' bicimi: gun yok.
    ('OKUDUĞUM', readAt == null ? '' : formatTurkishMonthYear(readAt)),
    ('TÜR', joinMeta(detail.genres)),
  ];
}
