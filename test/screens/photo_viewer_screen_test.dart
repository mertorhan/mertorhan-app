import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/models/photo.dart';
import 'package:mertorhan_app/screens/photo_viewer_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';

/// GORSEL URL'I HIC VERILMEZ: image ve thumbnail null kalir, Image.network
/// kurulmaz, hicbir test aga cikmaz. Depodaki yerlesik desen
/// (bkz. book_detail_screen_test.dart).
///
/// Goruntuleyici API almiyor; sahte uygulamaya gerek yok.
Photo _photo({
  required int id,
  required String title,
  String? category,
  String location = '',
  String camera = '',
  String lens = '',
  String iso = '',
  String shutterSpeed = '',
  String aperture = '',
  String focalLength = '',
  DateTime? takenAt,
}) => Photo(
  id: id,
  title: title,
  image: null,
  thumbnail: null,
  imageWidth: null,
  imageHeight: null,
  category: category,
  location: location,
  camera: camera,
  lens: lens,
  iso: iso,
  shutterSpeed: shutterSpeed,
  aperture: aperture,
  focalLength: focalLength,
  takenAt: takenAt,
  order: 0,
);

/// Uc fotograflik liste; gecis ve basa donme bunun uzerinde sinaniyor.
List<Photo> _ucFotograf() => <Photo>[
  _photo(id: 1, title: 'Birinci', location: 'Muğla'),
  _photo(id: 2, title: 'İkinci', location: 'Ankara'),
  _photo(id: 3, title: 'Üçüncü', location: 'İzmir'),
];

Widget _wrap(List<Photo> photos, int initialIndex) => MaterialApp(
  theme: AppTheme.light,
  home: PhotoViewerScreen(photos: photos, initialIndex: initialIndex),
);

/// Kapatma testleri icin gercek bir Navigator yigini: goruntuleyici bir
/// route olarak PUSH edilir, yoksa pop edecek bir sey olmaz.
Widget _wrapPushed(List<Photo> photos, int initialIndex) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Builder(
      builder: (BuildContext context) => TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                PhotoViewerScreen(photos: photos, initialIndex: initialIndex),
          ),
        ),
        child: const Text('Aç'),
      ),
    ),
  ),
);

/// PageView'i bir sayfa ileri (sola) kaydirir.
Future<void> _solaKaydir(WidgetTester tester) async {
  await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
  await tester.pumpAndSettle();
}

/// PageView'i bir sayfa geri (saga) kaydirir.
Future<void> _sagaKaydir(WidgetTester tester) async {
  await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
  await tester.pumpAndSettle();
}

void main() {
  // --- Acilis ve kunye ---

  testWidgets('acilista dogru fotografin kunyesi ve sayaci gorunur', (
    tester,
  ) async {
    final List<Photo> photos = <Photo>[
      _photo(id: 1, title: 'Birinci', location: 'Muğla'),
      _photo(
        id: 2,
        title: 'İkinci',
        category: 'Mimari',
        location: 'Ankara',
        takenAt: DateTime(2026, 3, 19),
      ),
      _photo(id: 3, title: 'Üçüncü', location: 'İzmir'),
    ];

    await tester.pumpWidget(_wrap(photos, 1));
    await tester.pumpAndSettle();

    // Konum · tarih joinMeta ile birlesti.
    expect(find.text('Ankara · 19 Mart 2026'), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
    // Komsu sayfalar kunyesiyle birlikte ekranda degil.
    expect(find.text('Birinci'), findsNothing);
    expect(find.text('Üçüncü'), findsNothing);
  });

  testWidgets('kategori Turkce kurallarina gore buyuk harfle basilir', (
    tester,
  ) async {
    final List<Photo> photos = <Photo>[
      _photo(id: 1, title: 'Birinci', category: 'Mimari'),
    ];

    await tester.pumpWidget(_wrap(photos, 0));
    await tester.pumpAndSettle();

    // Satir VAR ve metni buyutulmus hali.
    final Finder satir = find.byKey(PhotoViewerScreen.categoryKey);
    expect(satir, findsOneWidget);
    expect(tester.widget<Text>(satir).data, 'MİMARİ');
    // Dart'in duz toUpperCase'i burada 'MIMARI' verirdi.
    expect(find.text('MIMARI'), findsNothing);
  });

  testWidgets('kategori NULL ise satir cizilmez', (tester) async {
    final List<Photo> photos = <Photo>[
      _photo(id: 1, title: 'Birinci', location: 'Muğla'),
    ];

    await tester.pumpWidget(_wrap(photos, 0));
    await tester.pumpAndSettle();

    expect(find.byKey(PhotoViewerScreen.categoryKey), findsNothing);
    // Kunyenin geri kalani yerinde: eksik olan yalnizca kategori.
    expect(find.text('Muğla'), findsOneWidget);
  });

  testWidgets('kategori BOS ise satir cizilmez', (tester) async {
    // Sunucu bos metin alanlarini "" donduruyor, null degil; null
    // kontrolu tek basina yetmez.
    final List<Photo> photos = <Photo>[
      _photo(id: 1, title: 'Birinci', category: '', location: 'Muğla'),
    ];

    await tester.pumpWidget(_wrap(photos, 0));
    await tester.pumpAndSettle();

    expect(find.byKey(PhotoViewerScreen.categoryKey), findsNothing);
    expect(find.text('Muğla'), findsOneWidget);
  });

  testWidgets('konum da tarih de yoksa kunye satiri cizilmez', (tester) async {
    final List<Photo> photos = <Photo>[_photo(id: 1, title: 'Yalnız Başlık')];

    await tester.pumpWidget(_wrap(photos, 0));
    await tester.pumpAndSettle();

    // Baslik iki yerde: yer tutucunun icinde ve kunyede. Gorsel gelmedigi
    // icin kullanici hangi kayitta oldugunu yer tutucudan da gorebilmeli.
    expect(find.text('Yalnız Başlık'), findsNWidgets(2));
    expect(find.textContaining('·'), findsNothing);
  });

  testWidgets('gorsel yoksa yer tutucu ve baslik basilir', (tester) async {
    await tester.pumpWidget(_wrap(_ucFotograf(), 0));
    await tester.pumpAndSettle();

    // Sessizce bos kalmiyor.
    expect(find.text('Görsel yok'), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  // --- Yatay gecis ve basa donme ---

  testWidgets('sola kaydirinca sonrakine gecer, sayac guncellenir', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_ucFotograf(), 0));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('Muğla'), findsOneWidget);

    await _solaKaydir(tester);

    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.text('Ankara'), findsOneWidget);
    expect(find.text('Muğla'), findsNothing);
  });

  testWidgets('saga kaydirinca oncekine gecer', (tester) async {
    await tester.pumpWidget(_wrap(_ucFotograf(), 2));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);

    await _sagaKaydir(tester);

    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.text('Ankara'), findsOneWidget);
  });

  testWidgets('BASA DONER: son fotografta sola kaydirinca ilkine gider', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_ucFotograf(), 2));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.text('İzmir'), findsOneWidget);

    await _solaKaydir(tester);

    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('Muğla'), findsOneWidget);
    expect(find.text('İzmir'), findsNothing);
  });

  testWidgets('SONA DONER: ilk fotografta saga kaydirinca sonuncusuna gider', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_ucFotograf(), 0));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);

    await _sagaKaydir(tester);

    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.text('İzmir'), findsOneWidget);
    expect(find.text('Muğla'), findsNothing);
  });

  testWidgets('bastan sona tur atinca basa donulur', (tester) async {
    // Uc kaydirma = tam tur. Sarma bir kez degil, her defasinda calisiyor.
    await tester.pumpWidget(_wrap(_ucFotograf(), 0));
    await tester.pumpAndSettle();

    await _solaKaydir(tester);
    await _solaKaydir(tester);
    await _solaKaydir(tester);

    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('Muğla'), findsOneWidget);
  });

  testWidgets('TEK FOTOGRAF: sayac 1 / 1, kaydirma cokmuyor', (tester) async {
    final List<Photo> photos = <Photo>[
      _photo(id: 1, title: 'Tek', location: 'Muğla'),
    ];

    await tester.pumpWidget(_wrap(photos, 0));
    await tester.pumpAndSettle();
    expect(find.text('1 / 1'), findsOneWidget);

    await _solaKaydir(tester);
    await _sagaKaydir(tester);

    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('Muğla'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // --- EXIF izgarasi ---

  testWidgets('BOS alanin etiketi ekranda YOK, dolu alanin ki VAR', (
    tester,
  ) async {
    final List<Photo> photos = <Photo>[
      _photo(
        id: 1,
        title: 'Birinci',
        camera: 'Fujifilm X-T30',
        iso: '100',
        // lens, shutterSpeed, aperture, focalLength bos "" kaliyor.
      ),
    ];

    await tester.pumpWidget(_wrap(photos, 0));
    await tester.pumpAndSettle();

    expect(find.text('KAMERA'), findsOneWidget);
    expect(find.text('Fujifilm X-T30'), findsOneWidget);
    expect(find.text('ISO'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);

    expect(find.text('LENS'), findsNothing);
    expect(find.text('ENSTANTANE'), findsNothing);
    expect(find.text('DİYAFRAM'), findsNothing);
    expect(find.text('ODAK'), findsNothing);
  });

  testWidgets('HEPSI BOSKEN izgara ve ustundeki ayrac hic cizilmez', (
    tester,
  ) async {
    // _ucFotograf'ta alti EXIF alani da "" .
    await tester.pumpWidget(_wrap(_ucFotograf(), 0));
    await tester.pumpAndSettle();

    expect(find.text('KAMERA'), findsNothing);
    expect(find.text('LENS'), findsNothing);
    expect(find.text('ISO'), findsNothing);
    expect(find.text('ENSTANTANE'), findsNothing);
    expect(find.text('DİYAFRAM'), findsNothing);
    expect(find.text('ODAK'), findsNothing);
    // Ayrac da kalmiyor: bos bir cizgi cizilmiyor.
    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('alti alan da doluyken hepsi cizilir ve ayrac gorunur', (
    tester,
  ) async {
    final List<Photo> photos = <Photo>[
      _photo(
        id: 1,
        title: 'Birinci',
        camera: 'Fujifilm X-T30',
        lens: 'XF 35mm',
        iso: '100',
        shutterSpeed: '1/250',
        aperture: 'f/2.8',
        focalLength: '35 mm',
      ),
    ];

    await tester.pumpWidget(_wrap(photos, 0));
    await tester.pumpAndSettle();

    for (final String label in <String>[
      'KAMERA',
      'LENS',
      'ISO',
      'ENSTANTANE',
      'DİYAFRAM',
      'ODAK',
    ]) {
      expect(find.text(label), findsOneWidget, reason: '$label eksik');
    }
    expect(find.text('1/250'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  // --- Kapatma ---

  testWidgets('kapat dugmesi ekrani kapatir', (tester) async {
    await tester.pumpWidget(_wrapPushed(_ucFotograf(), 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoViewerScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoViewerScreen), findsNothing);
    expect(find.text('Aç'), findsOneWidget);
  });

  testWidgets('sistem geri tusu da kapatir', (tester) async {
    // PopScope EKLENMEDI; bu test o karari kilitler ki ileride yanlislikla
    // geri tusu engellenmesin.
    await tester.pumpWidget(_wrapPushed(_ucFotograf(), 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoViewerScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(PhotoViewerScreen), findsNothing);
  });

  testWidgets('kaydirdiktan sonra da kapat dugmesi yerinde', (tester) async {
    // Sayac ve kapat dugmesi PageView'in DISINDA; kaydirmayla gitmiyor.
    await tester.pumpWidget(_wrapPushed(_ucFotograf(), 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();

    await _solaKaydir(tester);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoViewerScreen), findsNothing);
  });
}
