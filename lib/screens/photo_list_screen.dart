import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/photos_api.dart';
import '../models/filter_option.dart';
import '../models/filter_selection.dart';
import '../models/photo.dart';
import '../utils/meta_line.dart';
import '../widgets/filter_chips.dart';
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

    final PhotosApi? injected = widget.api;
    if (injected != null) {
      _api = injected;
    } else {
      final ApiClient client = ApiClient();
      _ownedClient = client;
      _api = PhotosApi(client: client);
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

  /// TEK SECIM: sitedeki galeri davranisi boyle. toggle tek basina
  /// yetmez, ikinci degeri EKLERDI; bu yuzden her seferinde bos secimden
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
          child: PagedListView<Photo>(
            // PagedListView'da didUpdateWidget YOK: closure degisse bile
            // yeniden cekmiyor. Secime bagli key verince eski State
            // atiliyor ve liste yeni secimle cekiliyor. Bu yaklasim tam
            // da paged_list_view.dart'a DOKUNMAMAK icin secildi.
            key: ValueKey<FilterSelection>(_selection),
            fetch: () => _api.fetchPhotos(selection: _selection),
            emptyMessage: _selection.isEmpty
                ? 'Henüz fotoğraf yok'
                : 'Bu filtreye uyan fotoğraf yok',
            itemBuilder: (_, Photo photo) => MediaTile(
              // Kucuk gorsel varsa o, yoksa tam boy; ikisi de yoksa yer
              // tutucu.
              imageUrl: photo.listImage,
              metaLine: photoMetaLine(photo),
              title: photo.title,
            ),
          ),
        ),
      ],
    );
  }
}
