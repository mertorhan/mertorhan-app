import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/blog_api.dart';
import '../models/filter_option.dart';
import '../models/filter_selection.dart';
import '../models/blog_post.dart';
import '../utils/meta_line.dart';
import '../widgets/filter_chips.dart';
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

  FilterSelection _selection = const FilterSelection.empty();

  /// Tek gruplu turde secenekler EKRAN ACILISINDA cekilir, panel
  /// acilisinda degil. Kilitli karar 5'ten bilincli sapma: burada panel
  /// yok, haplarin gorunur olmasi gerekiyor ki kullanici secebilsin.
  ///
  /// Cekilemezse ya da bossa hap sirasi HIC cizilmez ve liste normal
  /// calisir. Filtre bir ek ozellik; yoklugu listeyi engellememeli, bu
  /// yuzden hata saklanmiyor ve kullaniciya gosterilmiyor.
  List<FilterOption> _categories = const [];

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

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final options = await _api.fetchFilterOptions();
      if (!mounted) return;
      setState(() => _categories = options.optionsFor('category'));
    } catch (_) {
      // Sessiz gecilir: liste zaten calisiyor, filtre olmadan da
      // kullanilabilir.
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

  /// TEK SECIM: sitedeki blog davranisi boyle. toggle tek basina yetmez,
  /// ikinci degeri EKLERDI; bu yuzden her seferinde bos secimden
  /// baslaniyor.
  void _selectCategory(String? value) {
    setState(() {
      _selection = value == null
          ? const FilterSelection.empty()
          : const FilterSelection.empty().toggle('category', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Secenek yoksa hap sirasi HIC cizilmez; yalnizca "Tumu" yazan
        // bir satir bir ise yaramaz.
        if (_categories.isNotEmpty)
          FilterChipRow(
            options: _categories,
            selectedValue: _selection.values['category']?.firstOrNull,
            onSelected: _selectCategory,
          ),
        Expanded(
          child: PagedListView<BlogPost>(
            // PagedListView'da didUpdateWidget YOK: closure degisse bile
            // yeniden cekmiyor. Secime bagli key verince eski State
            // atiliyor ve liste yeni secimle cekiliyor. Bu yaklasim tam
            // da paged_list_view.dart'a DOKUNMAMAK icin secildi.
            key: ValueKey<FilterSelection>(_selection),
            fetch: () => _api.fetchPosts(selection: _selection),
            emptyMessage: _selection.isEmpty
                ? 'Henüz yazı yok'
                : 'Bu filtreye uyan yazı yok',
            itemBuilder: (_, BlogPost post) => MediaTile(
              imageUrl: post.coverImage,
              metaLine: postMetaLine(post),
              title: post.title,
              summary: post.summary,
              onTap: () => _openPost(post),
            ),
          ),
        ),
      ],
    );
  }
}
