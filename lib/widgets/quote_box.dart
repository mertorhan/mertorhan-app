import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'site_markdown.dart';

/// Blog ve kitap detayinin ortak alinti kutusu.
///
/// Stil tek yerde: zemin kart rengi, solda vurgu cizgisi, govde italik.
/// Iki ekran ayni kutuyu cizdigi icin kopyalanmadi — biri degisirse
/// digeri kaymasin.
///
/// DIS BOSLUK VERMEZ: cagiran taraf verir. Blog detayinda bloklarin ortak
/// _Block boslugu var, kitapta yerlesim farkli.
///
/// METNIN CIZIMI CAGIRANA GORE DEGISIR, kutu stili degismez. Sitede
/// markdown yalnizca blog bloklarinda calisiyor; kitap alintisi
/// linebreaksbr'den geciyor, yani ham metin. [markdown] bu ayrimi
/// tasiyor ve VARSAYILANI YOK: iki cagiran da niyetini acikca yazsin,
/// sessiz varsayilan yanlis tarafa kaymayi kolaylastirir.
class QuoteBox extends StatelessWidget {
  const QuoteBox({
    required this.text,
    required this.source,
    required this.markdown,
    super.key,
  });

  final String text;

  /// Blogda alintinin kaynagi, kitapta sayfa bilgisi.
  ///
  /// Bos "" gelebilir; o zaman satir HIC cizilmez. Bos metin gecerli bir
  /// degerdir, null kontrolu yetmez.
  final String source;

  /// Metin markdown olarak mi cizilsin.
  ///
  /// true  -> blog alintisi; sitede {{ section.text|markdown }}
  /// false -> kitap alintisi; sitede {{ quote.text|linebreaksbr }}
  final bool markdown;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? govde = textTheme.bodyLarge?.copyWith(
      fontStyle: FontStyle.italic,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(left: BorderSide(color: AppColors.terracotta, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Metin(text: text, markdown: markdown, govde: govde),
          if (source.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              source,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Alintinin govdesi: markdown ya da duz metin.
///
/// ITALIK NASIL TASINIYOR (olculdu, uydurulmadi):
///   - Ciplak SiteMarkdown            -> fontStyle null, italik KAYIP
///   - DefaultTextStyle(italic) sarma -> fontStyle null, ETKISIZ
///   - Tema bodyLarge italige cevrili -> fontStyle italic, CALISIYOR
///
/// Sebep: SiteMarkdown kendi stil tablosunu Theme'den kuruyor ve ortam
/// DefaultTextStyle'ini hic okumuyor. Bu yuzden italik, temanin bodyLarge
/// katmani uzerinden geciriliyor.
///
/// Sarma YALNIZCA markdown govdesini kapsiyor; kaynak satiri labelMedium
/// kullandigi icin etkilenmiyor.
///
/// Ayni [govde] stili iki dala da gidiyor: italik pariteyi yorum degil,
/// yapinin kendisi garanti ediyor.
class _Metin extends StatelessWidget {
  const _Metin({
    required this.text,
    required this.markdown,
    required this.govde,
  });

  final String text;
  final bool markdown;
  final TextStyle? govde;

  @override
  Widget build(BuildContext context) {
    if (!markdown) return Text(text, style: govde);

    final ThemeData theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(bodyLarge: govde),
      ),
      child: SiteMarkdown(text: text),
    );
  }
}
