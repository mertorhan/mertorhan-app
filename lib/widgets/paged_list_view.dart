import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../api/paged_response.dart';
import '../theme/app_colors.dart';

/// Dort turun ortak liste govdesi.
///
/// Dort durum: yukleniyor · hata + "Tekrar dene" · bos · dolu.
/// Asagi cekip yenileme her durumda calisir.
///
/// SAYFALAMA YOK: yalnizca ilk sayfa cekilir. PagedResponse.hasNextPage
/// okunabilir durumda ama kullanilmiyor; sonsuz kaydirma ayri kart.
class PagedListView<T> extends StatefulWidget {
  const PagedListView({
    required this.fetch,
    required this.emptyMessage,
    this.itemBuilder,
    this.bodyBuilder,
    super.key,
  }) : assert(
         (itemBuilder == null) != (bodyBuilder == null),
         'itemBuilder ile bodyBuilder\'dan tam olarak biri verilmeli',
       );

  final Future<PagedResponse<T>> Function() fetch;

  /// Dolu durumda ogeleri TEK TEK cizer; aralarina ayrac konur.
  ///
  /// Dort turden ucunun (blog, film, kitap) kullandigi yol.
  final Widget Function(BuildContext context, T item)? itemBuilder;

  /// Dolu durumun govdesini bastan kurar; TUM listeyi gorur.
  ///
  /// Izgara gibi duzenler ogeyi tek tek alamaz: kolonlara dagitmak icin
  /// hepsini birden gormek zorundadir. Verilirse ListView yerine bunun
  /// dondurdugu widget cizilir.
  ///
  /// DONDURULEN WIDGET KAYDIRILABILIR OLMALI. RefreshIndicator ancak
  /// kaydirilabilir bir cocukla calisir; olmazsa asagi cekip yenileme
  /// sessizce olur, kimse fark etmez. Icerik ekrandan kisa oldugunda da
  /// calismasi icin AlwaysScrollableScrollPhysics gerekir — asagidaki
  /// _MessageView ayni sebeple oyle yazilmis.
  ///
  /// Yukleniyor, hata ve bos durumlarini ETKILEMEZ; onlar burada, tek
  /// yerde kalir. Bos liste zaten emptyMessage'a dustugu icin bodyBuilder
  /// hicbir zaman bos listeyle cagrilmaz.
  final Widget Function(BuildContext context, List<T> items)? bodyBuilder;

  /// API basarili ama hic kayit yoksa gosterilecek satir.
  final String emptyMessage;

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>>
    // Ust sekmeler arasinda gidip gelirken liste yeniden cekilmesin diye
    // durum korunur. TabBarView cocuklari tembel kurar, yani acilista
    // dort istek birden atilmaz; yalnizca gorunen sekme ceker.
    with AutomaticKeepAliveClientMixin {
  bool _loading = true;
  ApiException? _error;
  PagedResponse<T>? _page;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final PagedResponse<T> page = await widget.fetch();
      // Istek ucusurken ekran agactan silinmis olabilir; setState olu
      // State uzerinde calisirsa hata verir.
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
    super.build(context); // AutomaticKeepAliveClientMixin gerektiriyor.

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
        null when _page!.items.isEmpty => _MessageView(
          message: widget.emptyMessage,
        ),
        // Bos durumdan SONRA geliyor: bodyBuilder bos listeyle cagrilmaz.
        null when widget.bodyBuilder != null => widget.bodyBuilder!(
          context,
          _page!.items,
        ),
        // Kurucudaki assert ikisinden tam olarak birinin verildigini
        // garanti ediyor; buraya dusuldugunde itemBuilder dolu.
        null => ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _page!.items.length,
          separatorBuilder: (_, _) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (BuildContext context, int index) =>
              widget.itemBuilder!(context, _page!.items[index]),
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
