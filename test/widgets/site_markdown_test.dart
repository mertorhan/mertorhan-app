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

  testWidgets('h1 ve h6 punto olarak govde paragrafiyla ayni', (tester) async {
    await tester.pumpWidget(_wrap('# Buyuk\n\n###### Kucuk\n\n$_referans'));

    final double? govde = _stil(tester, _referans)?.fontSize;
    expect(govde, isNotNull);
    expect(_stil(tester, 'Buyuk')?.fontSize, govde);
    expect(_stil(tester, 'Kucuk')?.fontSize, govde);
    // Font ailesi de ayni; baslik serif katmanina kacmiyor.
    expect(
      _stil(tester, 'Buyuk')?.fontFamily,
      _stil(tester, _referans)?.fontFamily,
    );
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

  testWidgets('satir ici kod zeminsiz ve govde fontunda', (tester) async {
    await tester.pumpWidget(_wrap('`kod`\n\n$_referans'));

    // Bezeme taramasi bunu GOREMEZ: satir ici kod zemini
    // TextStyle.backgroundColor'da tasiniyor, Container bezemesinde degil.
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

  testWidgets('citli blok kutusuz ve govde puntosunda', (tester) async {
    // Girintili koddan AYRI kural, ayri stil alani; biri duzlesti diye
    // digeri duzlesmis sayilmaz.
    await tester.pumpWidget(_wrap('```\nkodblok\n```\n\n$_referans'));

    expect(_gorunurBezemeler(tester), isEmpty);
    expect(
      _stil(tester, 'kodblok')?.fontSize,
      _stil(tester, _referans)?.fontSize,
    );
    expect(_stil(tester, 'kodblok')?.backgroundColor, isNull);
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

  testWidgets('dipnot harfiyen gorunuyor', (tester) async {
    await tester.pumpWidget(_wrap('metin[^1]'));

    expect(find.text('metin[^1]'), findsOneWidget);
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
