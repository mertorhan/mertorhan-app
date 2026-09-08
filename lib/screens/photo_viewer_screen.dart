import 'package:flutter/material.dart';

import '../models/photo.dart';
import '../theme/app_colors.dart';
import '../utils/meta_line.dart';
import '../utils/turkish_case.dart';
import '../utils/turkish_date.dart';

/// Galeride bir fotografin tam ekran hali.
///
/// Sitedeki lightbox'in karsiligi: koyu zemin, fotograf ustte, kunye
/// altta, yana kaydirarak gecis.
///
/// API'YE GITMEZ: Photo modelinde slug yok, tekil uc de yok. Liste hangi
/// kayitlari cektiyse onlar aynen buraya gecer; goruntuleyici yeni istek
/// atmaz.
///
/// Fotografa yakinlasilabilir (InteractiveViewer, 1x-3x). Yakinlastirma
/// bir ANAHTAR gibi calisiyor: 1x'te sayfa gecisi ve dikey kaydirma
/// aciktir, uzerinde ikisi de susar ve parmak fotografi gezdirir.
/// Gerekcesi _zoomed alaninin dokumaninda.
class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({
    required this.photos,
    required this.initialIndex,
    super.key,
  });

  /// Kunyedeki kategori satirinin isareti.
  ///
  /// Satirin CIZILMEDIGINI dogrulamanin baska yolu yok: metni bilinmeyen
  /// bir Text'in yoklugu aranamaz. Testte tekrar yazilmasin diye burada
  /// duruyor, sihirli metin iki yere kopyalanmiyor.
  static const Key categoryKey = Key('photo-viewer-category');

  /// Listedeki fotograflarin tamami; gecis bunlar arasinda doner.
  final List<Photo> photos;

  /// Dokunulan fotografin listedeki sirasi.
  final int initialIndex;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  /// PageView'e verilecek baslangic ofseti kac "tur" iceri alinsin.
  ///
  /// Sonsuz listede geriye kaydirmak icin 0'in solunda sayfa kalmali;
  /// bu yuzden ortadan baslaniyor. Deger tur cinsinden: 1000 tur, altti
  /// fotografla 6000 sayfa demek. Kullanicinin bitirebilecegi bir sayi
  /// degil.
  static const int _baslangicTuru = 1000;

  late final PageController _controller;

  /// PageView'in ham sayfa numarasi; fotograf index'i DEGIL.
  late int _page;

  /// Gosterilen sayfa yakinlastirilmis mi. Sayfanin kendisi bildiriyor.
  ///
  /// JEST KILIDI — neden bu bayrak var (Flutter 3.47.2 davranisi):
  ///
  /// InteractiveViewer'in olcek taniyicisi tek parmakla da surukler ve
  /// jest arenasina KOSULSUZ girer; panEnabled: false onu arenadan
  /// cikarmaz, yalnizca kazandigi jesti uygulamamasini saglar.
  ///
  /// 1x'te PageView'i kurtaran sey esik farki: surukleme taniyicilari
  /// 18 piksele (yatayda yalniz dx, dikeyde yalniz dy) bakarken olcek
  /// taniyicisi 36 piksel Oklid mesafesi istiyor. dx de dy de 18'in
  /// altindayken Oklid en fazla ~25 olabilir, yani 36'ya hic ulasamaz:
  /// iki eksen de kapli oldugu icin tek parmak surukleme HER ZAMAN
  /// PageView'e ya da sayfanin dikey kaydiricisina duser.
  ///
  /// Yakinlastirilmisken tam tersi gerekiyor ve
  /// NeverScrollableScrollPhysics tam olarak bunu yapiyor: kaydiricinin
  /// surukleme taniyicilarini arenadan KALDIRIYOR (kaybettirmiyor).
  /// Geriye tek basina olcek taniyicisi kaliyor, pan sorunsuz calisiyor.
  bool _zoomed = false;

  /// Taban her zaman uzunlugun tam kati: bu sayede taban % uzunluk == 0
  /// ve acilistaki initialIndex bozulmadan geri okunur.
  int get _taban => widget.photos.length * _baslangicTuru;

  /// BASA DONME BURADA: ham sayfa numarasi fotograf sayisina gore
  /// sarilir. Sitedeki `% items.length` davranisinin aynisi — son
  /// fotografta sola kaydirinca ilkine, ilkinde saga kaydirinca
  /// sonuncusuna gidilir.
  int _photoIndex(int page) => page % widget.photos.length;

  @override
  void initState() {
    super.initState();

    // Kurucuda DEGIL burada: const kurucunun assert'i ancak derleme
    // zamani sabitleriyle calisabilir, List.isNotEmpty oyle bir ifade
    // degil. Kontrol yine de cagirandan once, ilk cizimden once yapiliyor.
    assert(
      widget.photos.isNotEmpty,
      'Bos liste: _photoIndex icindeki % sifira bolerdi',
    );
    assert(
      widget.initialIndex >= 0 && widget.initialIndex < widget.photos.length,
      'initialIndex liste disinda: ${widget.initialIndex} / '
      '${widget.photos.length}',
    );

    _page = _taban + widget.initialIndex;
    _controller = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Gosterilen sayfa yakinlastirma durumunu bildirdiginde.
  void _onZoomChanged(bool zoomed) {
    if (zoomed == _zoomed) return;
    setState(() => _zoomed = zoomed);
  }

  @override
  Widget build(BuildContext context) {
    // Tek fotografta kaydirmanin gidecegi yer yok; jesti hic acmiyoruz.
    // Modulo zaten cokmezdi ama sayfa numarasi bosuna buyurdu.
    final bool tekFotograf = widget.photos.length == 1;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              // itemCount VERILMEZ: liste sinirsiz, sarma isini
              // _photoIndex yapiyor. Sonlu bir PageView uclarda jesti
              // hic vermez (son sayfada sola cekince geri ziplar,
              // onPageChanged tetiklenmez); jumpToPage ile telafi de
              // gorunur bir sicrama yapardi.
              // IKI KOSUL BIRLESIR, biri digerini ezmez: tek fotografta
              // gidilecek sayfa yok; yakinlastirilmisken de surukleme
              // fotografi kaydirmali, sayfayi degil.
              physics: (tekFotograf || _zoomed)
                  ? const NeverScrollableScrollPhysics()
                  : null,
              // Sayfa degisince yakinlastirma durumu sifirlanir. Eski
              // sayfayi PageView zaten atiyor (gorunmeyen sayfa tutulmaz),
              // ama BURADAKI bayrak kendiliginden dusmez; dusmezse kilit
              // acik kalir ve kaydirma bir daha calismaz.
              onPageChanged: (int page) => setState(() {
                _page = page;
                _zoomed = false;
              }),
              itemBuilder: (BuildContext context, int page) => _PhotoPage(
                photo: widget.photos[_photoIndex(page)],
                onZoomChanged: _onZoomChanged,
              ),
            ),
            // PageView'IN DISINDA, Stack'in ust katmaninda: kaydirirken
            // sayac da kapat dugmesi de yerinde kalir.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopBar(
                index: _photoIndex(_page),
                total: widget.photos.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sayac ve kapat dugmesi.
///
/// Sitede sayac kunyenin altinda duruyor; burada uste alindi. Telefonda
/// kunye ekranin altina dusuyor ve sayac gorus alanindan cikiyordu —
/// bilincli sapma.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            '${index + 1} / $total',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.faint),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: AppColors.paper,
          tooltip: 'Kapat',
        ),
      ],
    );
  }
}

/// Tek bir fotografin sayfasi: gorsel + kunye.
///
/// DIKEY KAYDIRILABILIR: kunye uzun oldugunda (alti EXIF alani dolu bir
/// kayitta) icerik ekrana sigmiyor. Yatay PageView ile dikey scroll ayni
/// jesti paylasmaz; asagi kaydirmak fotografi degistirmez.
class _PhotoPage extends StatefulWidget {
  const _PhotoPage({required this.photo, required this.onZoomChanged});

  /// Gorselin kaplayabilecegi EN FAZLA yukseklik, ekran boyunun orani.
  /// Sitedeki 55vh'nin karsiligi.
  static const double _gorselYukseklikOrani = 0.55;

  /// Ust cubugun (sayac + kapat dugmesi) altinda kalmamak icin.
  static const double _ustBosluk = 48;

  /// Yakinlastirma tavani.
  ///
  /// Buyuk gorselin uzun kenari 2000 piksel (sitedeki imaging kodunda
  /// MAX_LONG_EDGE). Telefonda birkac yuz piksellik bir kutuda 3x zaten
  /// kaynagin cozunurlugunu tuketiyor; otesi bulanik buyutme olurdu.
  static const double _maxScale = 3.0;

  /// Bunun ustu "yakinlastirilmis" sayilir.
  ///
  /// Tam 1.0 ile karsilastirmak riskli: matris carpimlarindan kalan
  /// kayan nokta artigi (1.0000001) kilidi acilmaz birakirdi ve bu
  /// kullaniciya "kaydirma bozuldu" diye gorunurdu.
  static const double _zoomEsigi = 1.01;

  final Photo photo;

  /// Olcek 1x'in ustune cikinca / geri inince ust ekrana haber verir.
  /// Ust ekran buna gore PageView'i kilitler.
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<_PhotoPage> {
  final TransformationController _transformation = TransformationController();

  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _transformation.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformation.removeListener(_onTransformChanged);
    _transformation.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final bool zoomed =
        _transformation.value.getMaxScaleOnAxis() > _PhotoPage._zoomEsigi;
    // Her matris degisiminde degil, yalnizca ESIK gecildiginde is yapilir;
    // pan sirasinda saniyede onlarca setState atmanin anlami yok.
    if (zoomed == _zoomed) return;
    setState(() => _zoomed = zoomed);
    widget.onZoomChanged(zoomed);
  }

  /// Yakinlasmisken 1x'e dondurur.
  ///
  /// 1x IKEN HICBIR SEY YAPMAZ. Bu bilincli: dokunulan noktayi odak alan
  /// bir matris hesaplamak ayri bir is ve bu kartta yok. Sessiz kalmak,
  /// kullanicinin bakmadigi bir yere ziplamaktan iyi.
  void _onDoubleTap() {
    if (!_zoomed) return;
    // Dinleyici zaten calisip _zoomed'i ve ust ekrani duzeltiyor.
    _transformation.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final Photo photo = widget.photo;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Tam boy varsa o; yoksa kucugu. Listedeki listImage'in TERSI sira:
    // orada 96 piksellik hucre icin kucugu tercih ediliyor, burada ekrani
    // dolduracak en iyi gorsel isteniyor.
    final String? url = photo.image ?? photo.thumbnail;

    final DateTime? takenAt = photo.takenAt;
    // Birlestirme mantigi joinMeta'da; burada yalnizca hangi parcalarin
    // girdigi duruyor. Ikisi de bossa satir hic cizilmez.
    final String metaLine = joinMeta([
      photo.location,
      takenAt == null ? null : formatTurkishDate(takenAt),
    ]);

    final String? kategori = photo.category;

    return SingleChildScrollView(
      // Yakinlastirilmisken dikey kaydirma da susar: parmak fotografi
      // gezdirsin, sayfayi degil.
      physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.only(
        top: _PhotoPage._ustBosluk,
        bottom: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // YALNIZCA GORSEL sariliyor. Kunye ve EXIF izgarasi sarmalin
          // disinda kaliyor; yazilar yakinlasmiyor.
          GestureDetector(
            // Cift dokunma InteractiveViewer'da yok, distan ekleniyor.
            // Icteki jest katmani opaque oldugu icin deferToChild yeterli;
            // dokunma tum gorsel kutusunda algilaniyor.
            onDoubleTap: _onDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformation,
              minScale: 1.0,
              maxScale: _PhotoPage._maxScale,
              // 1x'te KAPALI: iki parmakla suruklemede olcek taniyicisi
              // jesti kazanir, acik olsaydi gorsel bosuna kayardi.
              // >1x'te ACIK, cunku o an surukleme taniyicilari
              // NeverScrollableScrollPhysics ile arenadan cikmis oluyor.
              panEnabled: _zoomed,
              child: _PhotoFrame(
                url: url,
                title: photo.title,
                // Yakinlasma bu kutunun ICINDE olur: InteractiveViewer
                // kisitlari oldugu gibi geciriyor ve cocugun boyutuna
                // kirpiyor. Oran degismiyor.
                maxHeight:
                    MediaQuery.sizeOf(context).height *
                    _PhotoPage._gorselYukseklikOrani,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori null gelebilir; sunucu bos "" de dondurebilir.
                if (kategori != null && kategori.isNotEmpty) ...[
                  Text(
                    key: PhotoViewerScreen.categoryKey,
                    // Sunucudan gelen metin: kaynakta buyuk yazamayiz,
                    // Dart'in toUpperCase'i de Turkce bilmez.
                    turkishUpper(kategori),
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.faint,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  photo.title,
                  style: textTheme.titleLarge?.copyWith(color: AppColors.paper),
                ),
                if (metaLine.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    metaLine,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.faint,
                    ),
                  ),
                ],
                _ExifGrid(rows: _exifRows(photo)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gorselin cercevesi: yukleniyor, hata ve gorsel yok durumlariyla.
///
/// KIRPILMAZ: BoxFit.contain, sitedeki object-fit: contain kararinin
/// aynisi (liste ogesinde de ayni tercih yapilmisti, KB-87).
class _PhotoFrame extends StatelessWidget {
  const _PhotoFrame({
    required this.url,
    required this.title,
    required this.maxHeight,
  });

  final String? url;
  final String title;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final String? gorsel = url;

    if (gorsel == null) {
      return _PhotoNotice(
        height: maxHeight,
        message: 'Görsel yok',
        title: title,
      );
    }

    return ConstrainedBox(
      // maxHeight, sabit height DEGIL: kisa bir gorsel bosuna 55%
      // kaplamasin, uzun olan da orayi asmasin.
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Image.network(
        gorsel,
        width: double.infinity,
        fit: BoxFit.contain,
        loadingBuilder:
            (BuildContext context, Widget child, ImageChunkEvent? progress) {
              if (progress == null) return child;
              // Yuklenirken gorselin yuksekligi 0; gostergenin duracagi
              // bir kutu olmali, yoksa duzen yukleme bitince ziplar.
              return SizedBox(
                height: maxHeight,
                width: double.infinity,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.paper),
                ),
              );
            },
        // SESSIZCE BOS KALMAZ: hangi fotografin yuklenemedigi yazilir.
        errorBuilder: (_, _, _) => _PhotoNotice(
          height: maxHeight,
          message: 'Görsel yüklenemedi',
          title: title,
        ),
      ),
    );
  }
}

/// Gorselin yerine gecen bilgi kutusu.
///
/// Basligi kunye de basiyor; burada tekrar edilmesi bilincli. Kullanici
/// bos bir dikdortgene degil, hangi kaydin gorselinin gelmedigine bakar.
class _PhotoNotice extends StatelessWidget {
  const _PhotoNotice({
    required this.height,
    required this.message,
    required this.title,
  });

  final double height;
  final String message;
  final String title;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.faint,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.faint),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: AppColors.paper),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fotografin EXIF satirlari.
///
/// ETIKETLER kaynakta dogrudan buyuk harfle yazilir; turkishUpper
/// cagrilmaz — o yalnizca sunucudan gelen metin icin.
List<(String, String)> _exifRows(Photo photo) => <(String, String)>[
  ('KAMERA', photo.camera),
  ('LENS', photo.lens),
  ('ISO', photo.iso),
  ('ENSTANTANE', photo.shutterSpeed),
  ('DİYAFRAM', photo.aperture),
  ('ODAK', photo.focalLength),
];

/// EXIF kunyesi: iki kolonlu izgara, ustunde ayrac.
///
/// CreditsBlock KULLANILMIYOR, iki olculen sebeple:
///
///   (a) Bu ekranin zemini KOYU. CreditsBlock'un renkleri acik zemine
///       gore sabit yazili (etiket AppColors.secondary, deger
///       bodyMedium'un varsayilan rengi olan AppColors.body); ikisi de
///       AppColors.ink uzerinde okunmaz.
///   (b) EXIF degerleri kisa: "f/2.8", "1/250", "35 mm". CreditsBlock'un
///       dikey duzeni uzun isim listeleri icin secilmisti ("OYUNCULAR:
///       alti kisi · virgullerle"); kisa degerlerde ekranin yarisini
///       bosa harciyor.
///
/// CreditsBlock'taki "Sitedeki IZGARA DEGIL" karari film ve kitap kunyesi
/// icin gecerli, degismiyor. Bu izgara PRIVATE kalir, ortak widget'a
/// terfi ettirilmez.
///
/// BOS ALAN HIC CIZILMEZ — etiketi de. Alti alanin hepsi bossa izgara ve
/// USTUNDEKI AYRAC da cizilmez; bos bir cizgi kalmaz.
class _ExifGrid extends StatelessWidget {
  const _ExifGrid({required this.rows});

  /// (etiket, deger) ciftleri. EXIF alanlari String; sunucu bos ""
  /// donduruyor, null degil — eleme isNotEmpty ile yapilir.
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> dolu = rows
        .where(((String, String) row) => row.$2.isNotEmpty)
        .toList();

    if (dolu.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, thickness: 1, color: AppColors.faint),
          const SizedBox(height: 16),
          // Ikiserli satirlar. Tek sayida hucre kalirsa sagdaki bos
          // Expanded yerinde durur, soldaki hucre satiri kaplayip
          // hizalamayi bozmasin.
          for (int i = 0; i < dolu.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ExifCell(label: dolu[i].$1, value: dolu[i].$2),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: i + 1 < dolu.length
                        ? _ExifCell(
                            label: dolu[i + 1].$1,
                            value: dolu[i + 1].$2,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Izgaranin tek hucresi: etiket ustte, deger altta.
class _ExifCell extends StatelessWidget {
  const _ExifCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.faint,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.paper),
        ),
      ],
    );
  }
}
