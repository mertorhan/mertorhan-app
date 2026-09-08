import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/models/photo.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/photo_grid.dart';

/// GORSEL URL'I HIC VERILMEZ: image ve thumbnail null kalir, Image.network
/// kurulmaz, hicbir test aga cikmaz. Depodaki yerlesik kural.
///
/// Izgara zaten yazi cizmiyor; onemli olan alanlar olculer.
Photo _photo({required int id, int? width, int? height}) => Photo(
  id: id,
  title: 'Fotoğraf $id',
  image: null,
  thumbnail: null,
  imageWidth: width,
  imageHeight: height,
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

/// InkWell bir Material atasi istiyor, o yuzden Scaffold var.
Widget _wrap(List<Photo> photos, {ValueChanged<Photo>? onPhotoTap}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: PhotoGrid(
          photos: photos,
          onPhotoTap: onPhotoTap ?? (_) {},
        ),
      ),
    );

Finder _kutucuk(int id) => find.byKey(PhotoGrid.tileKey(id));

void main() {
  testWidgets('IKI KOLONA DAGITIM: siradaki DAHA KISA kolona duser', (
    tester,
  ) async {
    // 1 numara cok uzun (1:2), 2 numara cok kisa (2:1). Ucuncusu, sag
    // kolon hala kisa oldugu icin oraya gitmeli — sirayla dagitilsaydi
    // sola giderdi.
    await tester.pumpWidget(
      _wrap(<Photo>[
        _photo(id: 1, width: 1000, height: 2000),
        _photo(id: 2, width: 2000, height: 1000),
        _photo(id: 3, width: 2000, height: 1000),
      ]),
    );
    await tester.pumpAndSettle();

    final double solX = tester.getTopLeft(_kutucuk(1)).dx;
    final double sagX = tester.getTopLeft(_kutucuk(2)).dx;

    // Ilk fotograf solda basliyor, ikincisi sagda.
    expect(sagX, greaterThan(solX));
    // Ucuncusu SAG kolonda: o an daha kisa olan oydu.
    expect(tester.getTopLeft(_kutucuk(3)).dx, sagX);
  });

  testWidgets('kutucuk yuksekligi gorselin oranindan hesaplanir', (
    tester,
  ) async {
    // Canlidaki bir kayit: 2000x1340.
    await tester.pumpWidget(
      _wrap(<Photo>[_photo(id: 1, width: 2000, height: 1340)]),
    );
    await tester.pumpAndSettle();

    final Size olcu = tester.getSize(_kutucuk(1));
    expect(olcu.height, closeTo(olcu.width * 1340 / 2000, 0.5));
  });

  testWidgets('DIKEY fotograf yatay olandan uzun cizilir', (tester) async {
    // Canlidaki iki kayit: 1638x2000 (dikey) ve 2000x1340 (yatay).
    await tester.pumpWidget(
      _wrap(<Photo>[
        _photo(id: 1, width: 1638, height: 2000),
        _photo(id: 2, width: 2000, height: 1340),
      ]),
    );
    await tester.pumpAndSettle();

    final Size dikey = tester.getSize(_kutucuk(1));
    final Size yatay = tester.getSize(_kutucuk(2));

    // Genislikler esit (ayni kolon genisligi), yukseklikler degil.
    expect(dikey.width, yatay.width);
    expect(dikey.height, greaterThan(yatay.height));
  });

  testWidgets('BOYUT NULL ise kare varsayilir', (tester) async {
    // Eski kayitlarda image_width/image_height null gelebilir.
    await tester.pumpWidget(_wrap(<Photo>[_photo(id: 1)]));
    await tester.pumpAndSettle();

    final Size olcu = tester.getSize(_kutucuk(1));
    expect(olcu.height, closeTo(olcu.width, 0.5));
  });

  testWidgets('gorsel yoksa yer tutucu cizilir, duzen bozulmaz', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(<Photo>[_photo(id: 1, width: 2000, height: 1000)]),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    // Yer tutucu kutucugun olcusunu degistirmiyor: oran hala gecerli.
    final Size olcu = tester.getSize(_kutucuk(1));
    expect(olcu.height, closeTo(olcu.width / 2, 0.5));
  });

  testWidgets('dokununca onTap dokunulan fotografla tetiklenir', (
    tester,
  ) async {
    Photo? dokunulan;

    await tester.pumpWidget(
      _wrap(<Photo>[
        _photo(id: 1, width: 2000, height: 1000),
        _photo(id: 2, width: 2000, height: 1000),
      ], onPhotoTap: (Photo p) => dokunulan = p),
    );
    await tester.pumpAndSettle();

    await tester.tap(_kutucuk(2));
    await tester.pumpAndSettle();

    expect(dokunulan?.id, 2);
  });

  testWidgets('TEK FOTOGRAF: sol kolonda cizilir, cokme yok', (tester) async {
    // Dagitim dongusunun sinir durumu: sag kolon bos kaliyor.
    await tester.pumpWidget(
      _wrap(<Photo>[_photo(id: 1, width: 2000, height: 1340)]),
    );
    await tester.pumpAndSettle();

    expect(_kutucuk(1), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Sol kolonda: kenar boslugunun hemen sagindan basliyor, ekranin
    // ortasindan degil.
    final double x = tester.getTopLeft(_kutucuk(1)).dx;
    final double ekranGenisligi = tester.getSize(find.byType(PhotoGrid)).width;
    expect(x, lessThan(ekranGenisligi / 2));
  });
}
