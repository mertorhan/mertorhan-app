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
/// 1. extensionSet — AYRISTIRICI katmani. Tablo, emoji, dipnot ve
///    bare-URL otomatik baglanti stil tablosuyla kapatilamaz, cunku
///    metin daha ayristirilirken elemente donusuyor. CommonMark tabani
///    bunlarin dordunu de zaten ayristirmiyor; uzerine yalnizca ustu
///    cizili ekleniyor.
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
/// KAPATILAMAYAN TEK KURAL: reference. Sitede "[bag][1]" ve
/// "[1]: https://ornek.com" satirlarinin ikisi de duz metin gorunuyor;
/// burada ilki baglanti olur, ikinci satir yutulur. CommonMark bunu
/// cekirdekte ayristiriyor, ExtensionSet'ten cikarilamiyor. Davranis
/// testle civilendi (site_markdown_test.dart, "bilinen ayrisma").
///
/// KENDI KAYDIRMASINI YAPMAZ: cagiran taraf zaten kaydirilabilir bir
/// govdenin icinde (blog detayi bir ListView).
class SiteMarkdown extends StatelessWidget {
  const SiteMarkdown({required this.text, super.key});

  /// Ham markdown. Bos "" gelebilir; paket bos govdeyi sorunsuz ciziyor.
  final String text;

  /// CommonMark tabani + YALNIZCA ustu cizili.
  ///
  /// Paketin varsayilani md.ExtensionSet.gitHubFlavored; o tabloyu,
  /// dipnotu ve bare-URL otomatik baglantiyi aciyor. commonMark ise
  /// yalnizca cit ile kod blogu ve satir ici HTML tasiyor.
  ///
  /// static: her build'de yeniden kurulmasin, ayristirici kumesi sabit.
  static final md.ExtensionSet _extensionSet = md.ExtensionSet(
    md.ExtensionSet.commonMark.blockSyntaxes,
    <md.InlineSyntax>[
      ...md.ExtensionSet.commonMark.inlineSyntaxes,
      md.StrikethroughSyntax(),
    ],
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
