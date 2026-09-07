import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Blog ve kitap detayinin ortak alinti kutusu.
///
/// Stil tek yerde: zemin kart rengi, solda vurgu cizgisi, govde italik.
/// Iki ekran ayni kutuyu cizdigi icin kopyalanmadi — biri degisirse
/// digeri kaymasin.
///
/// DIS BOSLUK VERMEZ: cagiran taraf verir. Blog detayinda bloklarin ortak
/// _Block boslugu var, kitapta yerlesim farkli.
class QuoteBox extends StatelessWidget {
  const QuoteBox({required this.text, required this.source, super.key});

  final String text;

  /// Blogda alintinin kaynagi, kitapta sayfa bilgisi.
  ///
  /// Bos "" gelebilir; o zaman satir HIC cizilmez. Bos metin gecerli bir
  /// degerdir, null kontrolu yetmez.
  final String source;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(left: BorderSide(color: AppColors.terracotta, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
          ),
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
