import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../theme/app_colors.dart';

/// Sitedeki markdown kumesini mobilde ayni sekilde cizer.
///
/// Site blog govdesini markdown-it ile isliyor ve KURALLARIN BIR KISMINI
/// KAPATIYOR. Buradaki is o kumeyi birebir karsilamak; paketin
/// varsayilani (GitHub flavored) fazlasini aciyor.
///
/// ACIK: kalin, italik, sirasiz liste, sirali liste, baglanti, ustu
/// cizili, ve tek satir sonunun satir sonu sayilmasi.
///
/// KAPALI kurallar UC AYRI MEKANIZMAYLA duzlestiriliyor; hangisinin neden
/// secildigi asagida:
///
/// 1. extensionSet — AYRISTIRICI katmani. Tablo, emoji, dipnot,
///    bare-URL otomatik baglanti, CIT ILE KOD BLOGU ve SATIR ICI HTML
///    stil tablosuyla kapatilamaz, cunku metin daha ayristirilirken
///    elemente donusuyor. Kume sifirdan kuruluyor: bos listeden baslanip
///    yalnizca ustu cizili ekleniyor.
///
///    CIT: sitede kapali olan "fence" BLOK kuralidir; ters tirnak
///    ("backticks") ayri bir SATIR ICI kuraldir ve sitede ACIK. Yani
///    "```" isaretleri sitede de yutuluyor, icerik satir ici koda
///    donusuyor: "```\nkodblok\n```" -> "<p><code>kodblok</code></p>".
///    Fenced blok ayristirmasini kaldirmak bizi tam oraya getiriyor —
///    isaretler yutulur, pre kutusu olusmaz. Bu ayrisma degil, PARITE.
///
///    SATIR ICI HTML: sitede kapali (html: false). Kaldirildi; olcum
///    zaten kaldirmadan once de "<b>" harfiyen goruntugunu gosterdi,
///    cunku InlineHtmlSyntax bir gecirgen. Yine de acikca disarida
///    birakildi: niyet okunsun ve paket bunu ileride bir elemente
///    cevirirse bizi korusun.
///
/// 2. MarkdownStyleSheet — CIZIM katmani. Baslik, kod, kod blogu, yatay
///    cizgi ve alinti ayristiriliyor ama govde paragrafiyla ayni stile
///    indirgeniyor, yani ekranda ayirt edilemiyorlar.
///
/// 3. imageBuilder — gorsel icin. Stil tablosunda gorseli gizleyecek bir
///    alan YOK (img yalnizca bir TextStyle). Bu, MarkdownElementBuilder
///    degil, paketin ayri bir ilk sinif parametresi.
///
/// GORSELDE ALT METIN BASILIR, gorsel sessizce yutulmaz. Sessizce
/// kaybolan icerik teshis edilemez; sitede ayni yer "![alt](url)" diye
/// ham gorunuyor, alt metin bunun en yakin karsiligi. Alt metin bossa
/// basilacak bir sey de yok, o zaman hic cizilmez.
///
/// BILINEN AYRISMALAR — ikisi de testle civilendi, sessizce kaymasin:
///
/// A. reference. Sitede "[bag][1]" ve "[1]: https://ornek.com"
///    satirlarinin ikisi de duz metin gorunuyor; burada ilki baglanti
///    olur, ikinci satir yutulur. CommonMark bunu cekirdekte
///    ayristiriyor, ExtensionSet'ten cikarilamiyor. KAPATILAMIYOR.
///
/// B. Satir ici kodun YAZI TIPI. Sitede <code> icin hic CSS yok, yani
///    tarayici varsayilani tek arali fontu veriyor. Burada code alani
///    govde stiline indirgendi, tek arali degil.
///
///    Duzlestirme BILEREK kaliyor. Sebep: MarkdownStyleSheet'te TEK bir
///    `code` alani var ve o alan hem satir ici kodu HEM kod blogunun
///    icerigini besliyor. Tek arali yapsak, dort boslukla girintilenmis
///    siradan bir paragraf da kod gibi gorunurdu — sitenin "code" blok
///    kuralini kapatarak onledigi sey tam olarak bu. Iki ayrismadan az
///    zararlisi secildi: icerik kaybi yok, yalnizca yazi tipi farki.
///
/// KENDI KAYDIRMASINI YAPMAZ: cagiran taraf zaten kaydirilabilir bir
/// govdenin icinde (blog detayi bir ListView).
class SiteMarkdown extends StatelessWidget {
  const SiteMarkdown({required this.text, super.key});

  /// Ham markdown. Bos "" gelebilir; paket bos govdeyi sorunsuz ciziyor.
  final String text;

  /// SIFIRDAN kuruluyor: hicbir hazir kume devralinmiyor, uzerine
  /// YALNIZCA ustu cizili ekleniyor.
  ///
  /// Neden devral-buda degil: commonMark tam olarak iki sey tasiyor —
  /// FencedCodeBlockSyntax ve InlineHtmlSyntax (olculdu, paket kaynagi).
  /// Ikisi de sitede KAPALI. Devralinsaydi ikisini de ayrica cikarmak
  /// gerekirdi; bos listeden baslamak niyeti dogrudan yaziyor.
  ///
  /// Bu kume md.ExtensionSet.none + ustu cizili ile ayni; none'in kendi
  /// belgesi de "fenced code block ve inline HTML olmadan CommonMark"
  /// diyor. Acikca yazildi ki neyin neden disarida oldugu okunsun.
  ///
  /// ExtensionSet yalnizca EKLER; cekirdek sozdizimleri (vurgu, kod,
  /// baglanti, satir sonu, baslik, liste, alinti, yatay cizgi, girintili
  /// kod) bundan bagimsiz ve bos kume onlari dusurmuyor. Acik kumenin
  /// yedisi de bu yuzden ayakta.
  ///
  /// static: her build'de yeniden kurulmasin, ayristirici kumesi sabit.
  static final md.ExtensionSet _extensionSet = md.ExtensionSet(
    <md.BlockSyntax>[],
    <md.InlineSyntax>[md.StrikethroughSyntax()],
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? body = theme.textTheme.bodyLarge;

    return MarkdownBody(
      data: text,
      extensionSet: _extensionSet,
      // Sitedeki breaks=True karsiligi: tek satir sonu satir sonu cizilir.
      softLineBreak: true,
      imageBuilder: (_, _, String? alt) {
        final String altText = alt ?? '';
        if (altText.isEmpty) return const SizedBox.shrink();
        return Text(altText, style: body);
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        // --- ACIK KURALLAR ---
        p: body,
        listBullet: body,
        // Sitedeki bag stili (style.css:2505): vurgu rengi + alt cizgi.
        // Alt cizginin OFFSET degerinin Flutter'da karsiligi yok;
        // TextStyle kalinlik ve renk tasiyor, offset tasimiyor.
        a: body?.copyWith(
          color: AppColors.terracotta,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.terracotta,
          decorationThickness: 1,
        ),
        // em / strong / del paketin varsayilaninda birakiliyor; ucu de
        // sitede acik ve varsayilanlari dogru (italik, kalin, ustu cizili).

        // --- KAPALI KURALLAR: govde paragrafina indirgeniyor ---
        h1: body,
        h2: body,
        h3: body,
        h4: body,
        h5: body,
        h6: body,
        blockquote: body,
        blockquoteDecoration: const BoxDecoration(),
        blockquotePadding: EdgeInsets.zero,
        // Varsayilan code'un tek aralikli fontu, kucultulmus puntosu ve
        // kart renginde zemini var; ucu de dusuyor.
        code: body,
        codeblockDecoration: const BoxDecoration(),
        codeblockPadding: EdgeInsets.zero,
        horizontalRuleDecoration: const BoxDecoration(),
        // Tablo icin duzlestirme YOK: commonMark tabloyu hic
        // ayristirmiyor, boru isaretleri duz metin kaliyor.
      ),
    );
  }
}
