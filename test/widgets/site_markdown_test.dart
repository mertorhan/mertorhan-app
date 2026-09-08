import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/theme/app_colors.dart';
import 'package:mertorhan_app/theme/app_theme.dart';
import 'package:mertorhan_app/widgets/site_markdown.dart';

/// Bu dosyadaki hicbir test aga cikmaz; SiteMarkdown saf gorunum ve
/// gorseller imageBuilder yuzunden hic kurulmuyor.
///
/// Iki kume var: sitede ACIK olan kurallarin calistigi, KAPALI olanlarin
/// govde paragrafina indirgendigi.

Widget _wrap(String text) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: SiteMarkdown(text: text)),
);

/// Kapali kural testlerinde yanina konan govde paragrafi.
///
/// Punto ve font karsilastirmalari MUTLAK deger yazilarak degil, ayni
/// ekrandaki bu paragrafa karsi yapiliyor; depodaki goreli dogrulama
/// aliskanligi (blog_detail_screen_test.dart:140) boyle.
const String _referans = 'Duz paragraf.';

/// MarkdownBody metni Text.rich ile ciziyor: data null, textSpan dolu.
/// imageBuilder'in dondurdugu duz Text'te ise tersi; ikisi de karsilanir.
TextStyle? _stil(WidgetTester tester, String metin) {
  final Text w = tester.widget<Text>(find.text(metin));
  return w.textSpan?.style ?? w.style;
}

/// SiteMarkdown altindaki TUM span stilleri (kok ve cocuklar).
List<TextStyle> _tumStiller(WidgetTester tester) {
  final List<TextStyle> stiller = <TextStyle>[];
  final Iterable<Text> metinler = tester.widgetList<Text>(
    find.descendant(of: find.byType(SiteMarkdown), matching: find.byType(Text)),
  );

  for (final Text w in metinler) {
    final TextStyle? duz = w.style;
    if (duz != null) stiller.add(duz);
    w.textSpan?.visitChildren((InlineSpan span) {
      final TextStyle? s = span.style;
      if (s != null) stiller.add(s);
      return true;
    });
  }
  return stiller;
}

/// Ekranda baglanti gibi cizilmis bir parca var mi.
///
/// Duz find.text yetmez: otomatik baglanti acik olsaydi paragrafin DUZ
/// METNI ayni kalir, yalnizca ic span baglanti stili alirdi. O yuzden
/// stillere bakiliyor.
bool _baglantiStiliVar(WidgetTester tester) => _tumStiller(tester).any(
  (TextStyle s) =>
      s.decoration == TextDecoration.underline ||
      s.color == AppColors.terracotta,
);

/// Rengi ya da kenarligi olan bezemeler.
///
/// Kod blogu, cit, yatay cizgi ve alinti duzlestirilince Container /
/// DecoratedBox agacta kaliyor ama bezemesi bos oluyor; burada bos
/// olanlar elenip yalnizca GORUNUR olanlar toplaniyor.
List<BoxDecoration> _gorunurBezemeler(WidgetTester tester) {
  Iterable<Decoration?> topla<T extends Widget>(
    Decoration? Function(T) oku,
  ) => tester
      .widgetList<T>(
        find.descendant(of: find.byType(SiteMarkdown), matching: find.byType(T)),
      )
      .map(oku);

  return <Decoration?>[
    ...topla<Container>((Container c) => c.decoration),
    ...topla<DecoratedBox>((DecoratedBox d) => d.decoration),
  ].whereType<BoxDecoration>().where((BoxDecoration d) {
    return d.color != null || d.border != null;
  }).toList();
}

void main() {
  testWidgets('bos metin istisna atmiyor, widget ciziliyor', (tester) async {
    // 2. adimda bos blok gelebilir; widget yorumu "bos gelebilir" diyor,
    // kaniti burada.
    await tester.pumpWidget(_wrap(''));

    expect(tester.takeException(), isNull);
    expect(find.byType(SiteMarkdown), findsOneWidget);
  });

  // =================== ACIK KUME ===================

  testWidgets('kalin isleniyor', (tester) async {
    await tester.pumpWidget(_wrap('Bu **kalin** bir metin.'));

    // Yildizlar ekranda kalmamali.
    expect(find.text('Bu kalin bir metin.'), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
    expect(
      _tumStiller(tester).any((TextStyle s) => s.fontWeight == FontWeight.bold),
      isTrue,
    );
  });

  testWidgets('italik isleniyor', (tester) async {
    await tester.pumpWidget(_wrap('Bu *italik* bir metin.'));

    expect(find.text('Bu italik bir metin.'), findsOneWidget);
    expect(
      _tumStiller(
        tester,
      ).any((TextStyle s) => s.fontStyle == FontStyle.italic),
      isTrue,
    );
  });

  testWidgets('sirasiz liste isleniyor', (tester) async {
    await tester.pumpWidget(_wrap('- birinci\n- ikinci'));

    // Tire ekranda kalmiyor; madde isareti paket ciziyor.
    expect(find.text('birinci'), findsOneWidget);
    expect(find.text('ikinci'), findsOneWidget);
    expect(find.textContaining('- birinci'), findsNothing);
  });

  testWidgets('sirali liste isleniyor', (tester) async {
    await tester.pumpWidget(_wrap('1. birinci\n2. ikinci'));

    expect(find.text('birinci'), findsOneWidget);
    expect(find.text('ikinci'), findsOneWidget);
    expect(find.textContaining('1. birinci'), findsNothing);
  });

  testWidgets('baglanti metni isleniyor ve baglanti stili aliyor', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap('[bag](https://ornek.com)'));

    // Koseli parantez ve adres ekranda kalmiyor.
    expect(find.text('bag'), findsOneWidget);
    expect(find.textContaining('https://'), findsNothing);

    final TextStyle? stil = _stil(tester, 'bag');
    expect(stil?.decoration, TextDecoration.underline);
    expect(stil?.color, AppColors.terracotta);
    // Alt cizgi kalinligi sitedeki gibi 1; OFFSET degerinin Flutter'da
    // karsiligi yok, TextStyle offset tasimiyor.
    expect(stil?.decorationThickness, 1);
  });

  testWidgets('tek satir sonu satir sonu olarak ciziliyor', (tester) async {
    // Sitedeki breaks=True karsiligi (softLineBreak).
    await tester.pumpWidget(_wrap('birinci\nikinci'));

    expect(find.text('birinci\nikinci'), findsOneWidget);
    // Iki satir tek paragrafta birlesip bosluga donusmedi.
    expect(find.text('birinci ikinci'), findsNothing);
  });

  testWidgets('ustu cizili isleniyor', (tester) async {
    await tester.pumpWidget(_wrap('~~silindi~~'));

    expect(find.text('silindi'), findsOneWidget);
    expect(find.textContaining('~~'), findsNothing);
    // Mutlak stil dogrulamasi: del paketin varsayilaninda birakildi,
    // dogru davrandigini gostermenin baska yolu yok.
    expect(_stil(tester, 'silindi')?.decoration, TextDecoration.lineThrough);
  });

  // =================== KAPALI KUME ===================

  testWidgets('h1..h6 ALTISI da punto olarak govde paragrafiyla ayni', (
    tester,
  ) async {
    // Altisi ayri stil alani (h1..h6). Yalnizca ucunu sinamak, ornegin
    // h3: body satirinin silinmesini hicbir testin yakalamamasi demek.
    final String kaynak = <String>[
      for (int i = 1; i <= 6; i++) '${'#' * i} Seviye$i',
      _referans,
    ].join('\n\n');

    await tester.pumpWidget(_wrap(kaynak));

    final double? govde = _stil(tester, _referans)?.fontSize;
    final String? govdeFont = _stil(tester, _referans)?.fontFamily;
    expect(govde, isNotNull);

    for (int i = 1; i <= 6; i++) {
      final TextStyle? stil = _stil(tester, 'Seviye$i');
      expect(stil?.fontSize, govde, reason: 'h$i puntosu govdeden farkli');
      // Font ailesi de ayni; baslik serif katmanina kacmiyor.
      expect(stil?.fontFamily, govdeFont, reason: 'h$i fontu govdeden farkli');
    }
  });

  testWidgets('lheading punto olarak govde paragrafiyla ayni', (tester) async {
    // ATX ile ayni stil alanlarindan geciyor ama ayri bir kural; ayri
    // olcum olmadan "duzlesti" denemez.
    await tester.pumpWidget(_wrap('Baslik\n=======\n\n$_referans'));

    expect(
      _stil(tester, 'Baslik')?.fontSize,
      _stil(tester, _referans)?.fontSize,
    );
  });

  testWidgets('satir ici kod govde fontunda: BILINCLI AYRISMA', (tester) async {
    // Bu bir "kapali kural duzlesti" testi DEGIL. Sitede <code> icin hic
    // CSS yok, yani tarayici varsayilani tek arali font veriyor; burada
    // govde fontuna indirildi. Ayrisma BILEREK secildi:
    //
    // MarkdownStyleSheet'te TEK bir `code` alani var ve hem satir ici
    // kodu hem kod blogunun icerigini besliyor. Tek arali yapsak, dort
    // boslukla girintilenmis siradan bir paragraf da kod gibi gorunurdu —
    // sitenin "code" blok kuralini kapatarak onledigi sey tam olarak bu.
    // Icerik kaybi yok, yalnizca yazi tipi farki.
    //
    // Bezeme taramasi burayi GOREMEZ: satir ici kod zemini
    // TextStyle.backgroundColor'da tasiniyor, Container bezemesinde degil.
    await tester.pumpWidget(_wrap('`kod`\n\n$_referans'));

    final TextStyle? stil = _stil(tester, 'kod');
    expect(stil?.backgroundColor, isNull);
    expect(stil?.fontFamily, _stil(tester, _referans)?.fontFamily);
    expect(stil?.fontSize, _stil(tester, _referans)?.fontSize);
  });

  testWidgets('dort bosluk girintili kod kutusuz ve govde puntosunda', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap('    kodblok\n\n$_referans'));

    expect(_gorunurBezemeler(tester), isEmpty);
    expect(
      _stil(tester, 'kodblok')?.fontSize,
      _stil(tester, _referans)?.fontSize,
    );
    expect(_stil(tester, 'kodblok')?.backgroundColor, isNull);
  });

  testWidgets('citli blok sitedekiyle ayni: isaretler yutulur, kutu yok', (
    tester,
  ) async {
    // PARITE testi. Sitede kapali olan "fence" BLOK kuralidir; ters
    // tirnak ("backticks") ayri bir SATIR ICI kuraldir ve sitede ACIK.
    // Yani "```" isaretleri sitede de yutuluyor:
    //   "```\nkodblok\n```"  ->  "<p><code>kodblok</code></p>"
    //
    // Fenced blok ayristirmasi extensionSet'ten cikarilinca mobil de tam
    // buraya geliyor: isaretler yutulur, icerik satir ici kod olur, pre
    // kutusu hic olusmaz.
    //
    // Cevre metin BILEREK var: cit isaretleri iki ayri sekilde de
    // yutulabilir — satir ici kod araligi olarak (bizim durum) ya da
    // fenced BLOK olarak (paketin varsayilani). Ikisini ayirt eden sey
    // parcalanma: satir ici kalirsa uc satir TEK metin parcasi olur,
    // blok olsaydi "once" / "kodblok" / "sonra" diye UC ayri parcaya
    // bolunurdu. Cevre metin olmadan test bu ikisini ayirt edemiyordu.
    await tester.pumpWidget(_wrap('once\n```\nkodblok\n```\nsonra'));

    expect(find.text('once\nkodblok\nsonra'), findsOneWidget);
    // Isaretler ekranda YOK — sitede de yok.
    expect(find.textContaining('```'), findsNothing);
    // pre kutusu olusmadi.
    expect(_gorunurBezemeler(tester), isEmpty);
  });

  testWidgets('satir ici HTML harfiyen gorunuyor, bicimlendirmiyor', (
    tester,
  ) async {
    // Sitede html: false; "<b>" ekranda harfiyen gorunuyor.
    await tester.pumpWidget(_wrap('metin <b>kalin</b> devam'));

    expect(find.text('metin <b>kalin</b> devam'), findsOneWidget);
    // Etiket bicimlendirmeye donusmedi.
    expect(
      _tumStiller(tester).any((TextStyle s) => s.fontWeight == FontWeight.bold),
      isFalse,
    );
  });

  testWidgets('yatay cizgi cizilmiyor', (tester) async {
    await tester.pumpWidget(_wrap('---\n\n$_referans'));

    expect(_gorunurBezemeler(tester), isEmpty);
    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('alinti kutusuz ve kenarliksiz', (tester) async {
    await tester.pumpWidget(_wrap('> alinti\n\n$_referans'));

    expect(_gorunurBezemeler(tester), isEmpty);
    expect(
      _stil(tester, 'alinti')?.fontSize,
      _stil(tester, _referans)?.fontSize,
    );
  });

  testWidgets('gorsel cizilmez, alt metni duz metin olarak gorunur', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap('![Kapak](https://ornek/1.png)'));

    // Sessizce kaybolan icerik teshis edilemez; alt metin basiliyor.
    expect(find.byType(Image), findsNothing);
    expect(find.text('Kapak'), findsOneWidget);
  });

  testWidgets('alt metni bos gorselde ne gorsel ne metin var', (tester) async {
    await tester.pumpWidget(_wrap('![](https://ornek/1.png)'));

    expect(find.byType(Image), findsNothing);
    expect(find.text(''), findsNothing);
  });

  testWidgets('tablo ayristirilmiyor, boru isaretleri duz metin', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap('| a | b |\n| --- | --- |\n| 1 | 2 |'));

    expect(find.byType(Table), findsNothing);
    expect(find.textContaining('| a | b |'), findsOneWidget);
  });

  testWidgets('bare URL otomatik baglantiya donmuyor', (tester) async {
    await tester.pumpWidget(_wrap('Bak https://ornek.com adresine'));

    expect(find.text('Bak https://ornek.com adresine'), findsOneWidget);
    // Duz metin oldugunu ancak stil kanitlar: otolink acik olsaydi duz
    // metin yine ayni kalirdi, yalnizca ic span baglanti stili alirdi.
    expect(_baglantiStiliVar(tester), isFalse);
  });

  testWidgets('www adresi otomatik baglantiya donmuyor', (tester) async {
    await tester.pumpWidget(_wrap('www.ornek.com'));

    expect(find.text('www.ornek.com'), findsOneWidget);
    expect(_baglantiStiliVar(tester), isFalse);
  });

  testWidgets('emoji kisayolu harfiyen gorunuyor', (tester) async {
    await tester.pumpWidget(_wrap('merhaba :smile:'));

    expect(find.text('merhaba :smile:'), findsOneWidget);
  });

  testWidgets('tanimsiz dipnot harfiyen gorunuyor', (tester) async {
    // PARITE ama DUYARSIZ: tanim satiri olmadan "[^1]" paketin
    // varsayilan kumesinde de harfiyen kaliyor, cunku gitHubFlavored'in
    // satir ici kumesinde dipnot sozdizimi yok — FootnoteDefSyntax bir
    // BLOK kurali ve yalnizca tanim satirini ayristiriyor. Yani bu test
    // dogru bir sey soyluyor ama extensionSet'i korumuyor; onu asagidaki
    // tanimli test yapiyor.
    await tester.pumpWidget(_wrap('metin[^1]'));

    expect(find.text('metin[^1]'), findsOneWidget);
  });

  testWidgets('dipnot TANIMI ile birlikte: BILINEN AYRISMA', (tester) async {
    // Sitede iki satir da harfiyen gorunuyor (hem footnote hem reference
    // kapali). Burada oyle degil ve OLAMAZ: tanim satirini cekirdek
    // LinkReferenceDefinitionSyntax yutuyor, "[^1]" de referans baglantisi
    // olarak cozuluyor. Yani bu, A maddesindeki reference ayrismasinin
    // dipnot kiligindaki hali; ayri bir kusur degil.
    //
    // Olculen davranis civileniyor:
    //   bizim kume      -> "metin^1", tanim satiri yok
    //   gitHubFlavored  -> "metin1" + "1." + "aciklama ↩" (uc parca)
    // Ikisi farkli oldugu icin bu test extensionSet'i GERCEKTEN koruyor.
    await tester.pumpWidget(_wrap('metin[^1]\n\n[^1]: aciklama'));

    // Koseli parantezler tuketildi, geriye etiket kaldi.
    expect(find.text('metin^1'), findsOneWidget);
    expect(_baglantiStiliVar(tester), isTrue);
    // Tanim satiri yutuldu; dipnot listesi de olusmadi.
    expect(find.textContaining('aciklama'), findsNothing);
    expect(find.textContaining('↩'), findsNothing);
  });

  testWidgets('reference baglantisi BILINEN AYRISMA', (tester) async {
    // Sitede "[bag][1]" ve "[1]: https://ornek.com" satirlarinin IKISI DE
    // duz metin olarak GORUNUYOR (reference kapali).
    //
    // Mobilde ilki baglanti olur, ikinci satir tamamen YUTULUR — ekranda
    // hic gorunmez. Kapatilamiyor: CommonMark cekirdeginde, ExtensionSet
    // ile cikarilamiyor.
    //
    // Test bu davranisi civiliyor; paket surumu degistirirse haberimiz
    // olsun.
    await tester.pumpWidget(_wrap('[bag][1]\n\n[1]: https://ornek.com'));

    expect(find.text('bag'), findsOneWidget);
    expect(_baglantiStiliVar(tester), isTrue);
    // Tanim satiri yutuldu.
    expect(find.textContaining('[1]:'), findsNothing);
  });
}
