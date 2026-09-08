import 'package:flutter/material.dart';

import '../models/photo.dart';
import '../theme/app_colors.dart';

/// Galerinin masonry izgarasi: iki kolon, fotograflar KENDI en-boy
/// oranlariyla.
///
/// YAZI YOK. Baslik, kategori ve konum yalnizca tam ekranda gorunur —
/// sitedeki davranisin aynisi. Izgara fotograflarin kendisidir.
///
/// PAKET EKLENMEDI: flutter_staggered_grid_view'in bu is icin yaptigi sey
/// asagidaki _dagit dongusu kadar; bir bagimlilik tasimaya degmez.
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({required this.photos, required this.onPhotoTap, super.key});

  /// Kenar boslugu. MediaTile'in yatay boslugu ile ayni, boylece galeri
  /// diger sekmelerle ayni hizada baslar.
  static const double _yanBosluk = 16;

  /// Hem kolonlar arasi hem kutucuklar arasi bosluk: fotograflar
  /// birbirine yapismaz.
  static const double _aralik = 12;

  final List<Photo> photos;

  /// Dokunulan fotograf. Ekran bunu tam ekran goruntuleyiciye baglar.
  final ValueChanged<Photo> onPhotoTap;

  /// Bir kutucugun isareti.
  ///
  /// Izgarada yazi olmadigi icin testler bir kutucugu baska turlu
  /// adlandiramaz. Uretimde de ise yariyor: filtre degisip liste
  /// yenilenince element eslesmesi kayit numarasindan yapilir.
  ///
  /// Sihirli metin iki yere kopyalanmasin diye burada duruyor.
  static Key tileKey(int photoId) => ValueKey<String>('photo-tile-$photoId');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Kutucugun yuksekligi genisligine bagli, genislik de ancak
        // burada biliniyor.
        final double kolonGenisligi =
            (constraints.maxWidth - _yanBosluk * 2 - _aralik) / 2;

        final List<List<Photo>> kolonlar = _dagit(photos, kolonGenisligi);

        return SingleChildScrollView(
          // Icerik ekrandan kisa olsa bile asagi cekilebilmeli, yoksa
          // PagedListView'in RefreshIndicator'i calismaz.
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(_yanBosluk),
          child: Row(
            // Kolonlar farkli boyda; kisa olan uzayip bosluk doldurmasin.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Kolon(photos: kolonlar[0], onPhotoTap: onPhotoTap),
              ),
              const SizedBox(width: _aralik),
              Expanded(
                child: _Kolon(photos: kolonlar[1], onPhotoTap: onPhotoTap),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Fotograflari iki kolona dagitir.
  ///
  /// MASONRY KURALI: siradaki fotograf O AN DAHA KISA olan kolona duser.
  /// Sira bozulmaz, yalnizca hangi kolona gidecegi yukseklige bakar;
  /// boylece iki kolon asagi dogru dengeli iner ve altta kocaman bir
  /// bosluk kalmaz.
  ///
  /// Esitlikte SOL kolon secilir: ilk fotograf hep solda baslar ve tek
  /// ogeli listede sag kolon bos kalir.
  static List<List<Photo>> _dagit(List<Photo> photos, double kolonGenisligi) {
    final List<List<Photo>> kolonlar = <List<Photo>>[<Photo>[], <Photo>[]];
    final List<double> yukseklikler = <double>[0, 0];

    for (final Photo photo in photos) {
      final int hedef = yukseklikler[1] < yukseklikler[0] ? 1 : 0;
      kolonlar[hedef].add(photo);
      yukseklikler[hedef] +=
          _kutuYuksekligi(photo, kolonGenisligi) + _aralik;
    }

    return kolonlar;
  }

  /// Kutucugun yuksekligi, gorselin KENDI en-boy oraniyla.
  ///
  /// Oran API'den geliyor (image_width / image_height), yani yukseklik
  /// gorsel INMEDEN once biliniyor: izgara yuklenirken ziplamaz.
  ///
  /// Alanlar nullable. Canlida bugun bes kayitta da dolu, ama eski
  /// kayitlarda null gelebilir; sifir ya da eksi bir olcu de anlamsiz.
  /// O hallerde KARE varsayilir. Gorsel yine BoxFit.contain ile
  /// cizildigi icin kirpilmaz, kutunun icinde ortalanir — yanlis oran
  /// bosluk birakir, goruntuyu bozmaz.
  static double _kutuYuksekligi(Photo photo, double genislik) {
    final int? w = photo.imageWidth;
    final int? h = photo.imageHeight;
    if (w == null || h == null || w <= 0 || h <= 0) return genislik;
    return genislik * h / w;
  }
}

/// Izgaranin tek kolonu.
class _Kolon extends StatelessWidget {
  const _Kolon({required this.photos, required this.onPhotoTap});

  final List<Photo> photos;
  final ValueChanged<Photo> onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      // Kutucuklar kolonun tam genisligini kaplasin; yukseklik hesabi
      // bu genislige gore yapildi.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final Photo photo in photos)
          Padding(
            padding: const EdgeInsets.only(bottom: PhotoGrid._aralik),
            child: _PhotoTile(
              key: PhotoGrid.tileKey(photo.id),
              photo: photo,
              onTap: () => onPhotoTap(photo),
            ),
          ),
      ],
    );
  }
}

/// Tek bir fotograf kutucugu.
///
/// Yuksekligi disaridan degil, LayoutBuilder'in verdigi genislikten
/// tureyen orandan geliyor; kolon genisligi Expanded ile dayatiliyor.
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.onTap, super.key});

  final Photo photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Kolonun dayattigi genisligi LayoutBuilder ile geri okuyoruz;
    // yukseklik ancak ondan sonra hesaplanabiliyor.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double genislik = constraints.maxWidth;
        final String? url = photo.listImage;

        return SizedBox(
          height: PhotoGrid._kutuYuksekligi(photo, genislik),
          child: InkWell(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              // Zemin tek yerden boyanir: hem contain boslugu hem yer
              // tutucu. MediaTile._Cover'daki kararin aynisi.
              child: ColoredBox(
                color: AppColors.card,
                child: url == null
                    ? const _TilePlaceholder()
                    : Image.network(
                        url,
                        // KIRPILMAZ: KB-87 ve sitenin karari. Kutu zaten
                        // gorselin oraniyla olculdugu icin normalde
                        // bosluk kalmaz.
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const _TilePlaceholder(),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gorsel yoksa ya da inemezse kutucugun icine cizilen isaret.
///
/// MediaTile'daki yer tutucunun kardesi ama kopyasi degil: o 96 piksellik
/// sabit bir hucre icin yazilmis (28 piksel ikon), burada kutucuk ekranin
/// yarisi kadar genis. Ortak bir widget'a cikarmak media_tile.dart'in
/// kodunu degistirmeyi gerektirirdi; bu kartta orada yalnizca yorum
/// degisiyor.
class _TilePlaceholder extends StatelessWidget {
  const _TilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image_outlined, color: AppColors.faint, size: 36),
    );
  }
}
