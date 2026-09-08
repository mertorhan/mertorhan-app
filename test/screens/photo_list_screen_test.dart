import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/api_exception.dart';
import 'package:mertorhan_app/api/paged_response.dart';
import 'package:mertorhan_app/api/photos_api.dart';
import 'package:mertorhan_app/models/filter_option.dart';
import 'package:mertorhan_app/models/filter_options.dart';
import 'package:mertorhan_app/models/filter_selection.dart';
import 'package:mertorhan_app/models/photo.dart';
import 'package:mertorhan_app/screens/photo_list_screen.dart';
import 'package:mertorhan_app/screens/photo_viewer_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/filter_chips.dart';
import 'package:mertorhan_app/widgets/photo_grid.dart';

/// Sahte uygulama: iki uc de ezilir, gercek istek atilmaz.
///
/// fetchFilterOptions ezilmezse uretim govdesi calisir ve test GERCEK aga
/// cikar; galeri ekrani secenekleri ACILISTA cekiyor.
class _FakePhotosApi extends PhotosApi {
  _FakePhotosApi({this.page, this.error, this.options, this.optionsError});

  final PagedResponse<Photo>? page;
  final Object? error;
  final FilterOptions? options;
  final Object? optionsError;

  /// Ekranin fetch'e gecirdigi son secim.
  FilterSelection? sonSecim;
  int cagriSayisi = 0;

  @override
  Future<PagedResponse<Photo>> fetchPhotos({
    int page = 1,
    FilterSelection? selection,
  }) async {
    sonSecim = selection;
    cagriSayisi++;
    if (error != null) throw error!;
    return this.page!;
  }

  @override
  Future<FilterOptions> fetchFilterOptions() async {
    if (optionsError != null) throw optionsError!;
    return options ?? const FilterOptions.empty();
  }
}

Photo _photo({int id = 1, String title = 'Bir fotoğraf'}) => Photo(
  id: id,
  title: title,
  image: null,
  thumbnail: null,
  imageWidth: null,
  imageHeight: null,
  category: 'Manzara',
  location: 'Muğla',
  camera: '',
  lens: '',
  iso: '',
  shutterSpeed: '',
  aperture: '',
  focalLength: '',
  takenAt: null,
  order: 0,
);

PagedResponse<Photo> _page(List<Photo> items) => PagedResponse<Photo>(
  items: items,
  hasNextPage: false,
  totalCount: items.length,
);

FilterOptions _kategoriler() => const FilterOptions(
  groups: {
    'category': [
      FilterOption(value: '1', label: 'Manzara', count: 5),
      FilterOption(value: '2', label: 'Portre', count: 2),
    ],
  },
);

/// Ekran sekme govdesi: kendi Scaffold'u yok, uretimde onu
/// PublicationsScreen sagliyor. Izgara kutucugundaki InkWell Material
/// atasi istedigi icin test de Scaffold ile sarmaliyor.
Widget _wrap(PhotosApi api) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: PhotoListScreen(api: api)),
);

/// Izgarada yazi yok: bir fotografa kayit numarasindan ulasiliyor.
Finder _kutucuk(int id) => find.byKey(PhotoGrid.tileKey(id));

void main() {
  testWidgets('dolu listede izgara kutucugu cizilir, YAZI YOK', (
    tester,
  ) async {
    final api = _FakePhotosApi(page: _page([_photo()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoGrid), findsOneWidget);
    expect(_kutucuk(1), findsOneWidget);
    // Baslik, kategori ve konum yalnizca tam ekranda gorunur.
    expect(find.text('Bir fotoğraf'), findsNothing);
    expect(find.text('Manzara · Muğla'), findsNothing);
  });

  testWidgets('kutucuk dokunulabilir', (tester) async {
    final api = _FakePhotosApi(page: _page([_photo()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Izgarada yazi olmadigi icin InkWell kutucuk anahtarindan bulunur.
    final InkWell inkWell = tester.widget<InkWell>(
      find.descendant(of: _kutucuk(1), matching: find.byType(InkWell)),
    );
    expect(inkWell.onTap, isNotNull);
  });

  testWidgets('kutucuga dokununca tam ekran goruntuleyici acilir', (
    tester,
  ) async {
    final api = _FakePhotosApi(
      page: _page([_photo(title: 'Birinci'), _photo(id: 2, title: 'İkinci')]),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoViewerScreen), findsNothing);

    await tester.tap(_kutucuk(2));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoViewerScreen), findsOneWidget);
    // Dokunulan fotografla acildi, listenin basindan degil.
    expect(find.text('2 / 2'), findsOneWidget);
    // Baslik artik burada gorunuyor: tam ekranda yazi var.
    expect(find.text('İkinci'), findsWidgets);
  });

  testWidgets('goruntuleyici acilirken YENI ISTEK ATILMAZ', (tester) async {
    final api = _FakePhotosApi(page: _page([_photo()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();
    expect(api.cagriSayisi, 1);

    await tester.tap(_kutucuk(1));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoViewerScreen), findsOneWidget);
    // Elde duran liste oldugu gibi gecti.
    expect(api.cagriSayisi, 1);
  });

  testWidgets('hata durumunda mesaj ve Tekrar dene gorunur', (tester) async {
    final api = _FakePhotosApi(error: const ApiException.network());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text(const ApiException.network().userMessage), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  testWidgets('bos listede bos durum metni gorunur', (tester) async {
    final api = _FakePhotosApi(page: _page([]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Henüz fotoğraf yok'), findsOneWidget);
  });

  // --- KB-112: kategori filtresi ---

  testWidgets('secenek varsa hap sirasi cizilir', (tester) async {
    final api = _FakePhotosApi(page: _page([_photo()]), options: _kategoriler());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(FilterChipRow), findsOneWidget);
    expect(find.text('Tümü'), findsOneWidget);
    expect(find.text('Manzara (5)'), findsOneWidget);
  });

  testWidgets('secenek yoksa hap sirasi HIC cizilmez', (tester) async {
    final api = _FakePhotosApi(page: _page([_photo()]));

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    expect(find.byType(FilterChipRow), findsNothing);
    // Izgara yine cizildi: liste calisiyor.
    expect(_kutucuk(1), findsOneWidget);
  });

  testWidgets('secenek cekimi hata verirse ekran calismaya devam eder', (
    tester,
  ) async {
    final api = _FakePhotosApi(
      page: _page([_photo()]),
      optionsError: const ApiException.timeout(),
    );

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    // Filtre bir ek ozellik; yoklugu listeyi engellemiyor.
    expect(find.byType(FilterChipRow), findsNothing);
    expect(_kutucuk(1), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kategori secince liste yeni selection ile cekilir', (
    tester,
  ) async {
    final api = _FakePhotosApi(page: _page([_photo()]), options: _kategoriler());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();
    expect(api.cagriSayisi, 1);

    await tester.tap(find.text('Manzara (5)'));
    await tester.pumpAndSettle();

    expect(api.cagriSayisi, 2);
    expect(api.sonSecim, const FilterSelection.empty().toggle('category', '1'));
  });

  testWidgets('TEK SECIM: ikinci kategori oncekini degistirir', (tester) async {
    final api = _FakePhotosApi(page: _page([_photo()]), options: _kategoriler());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manzara (5)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Portre (2)'));
    await tester.pumpAndSettle();

    expect(api.sonSecim, const FilterSelection.empty().toggle('category', '2'));
    expect(api.sonSecim!.count, 1);
  });

  testWidgets('ayni hapa tekrar basmak Tumu ye dondurur', (tester) async {
    final api = _FakePhotosApi(page: _page([_photo()]), options: _kategoriler());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manzara (5)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manzara (5)'));
    await tester.pumpAndSettle();

    expect(api.sonSecim, const FilterSelection.empty());
  });

  testWidgets('secim varken bos sonuc farkli mesaj gosterir', (tester) async {
    final api = _FakePhotosApi(page: _page([]), options: _kategoriler());

    await tester.pumpWidget(_wrap(api));
    await tester.pumpAndSettle();
    expect(find.text('Henüz fotoğraf yok'), findsOneWidget);

    await tester.tap(find.text('Manzara (5)'));
    await tester.pumpAndSettle();

    expect(find.text('Bu filtreye uyan fotoğraf yok'), findsOneWidget);
  });
}
