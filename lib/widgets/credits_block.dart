import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Detay ekranlarinin ortak kunye blogu: dikey liste.
///
/// Sitedeki IZGARA DEGIL. Dar ekranda yan yana hucre okunmaz; etiket
/// ustte, deger altta.
///
/// Kitap detayi icin yazilmisti, film detayi ikinci kullanici olacakti.
/// QuoteBox'taki gerekcenin aynisi: ayni seyi cizen ekranlar kopyalanmaz,
/// biri degisirse digeri kaymasin.
///
/// BOS ALAN HIC BASILMAZ, hicbir alan kalmazsa blok HIC gorunmez —
/// sitedeki kuralin aynisi. Cagiran taraf ham listeyi verir, eleme
/// burada yapilir; boylece her ekran ayni kurali yeniden yazmaz.
///
/// ETIKETLER kaynakta dogrudan buyuk harfle yazilir; toUpperCase
/// cagrilmaz. Turkce'de 'i' buyuyunce 'İ' olmali, Dart'in varsayilani
/// 'I' verir. API'den GELEN metinlerde ise kaynakta duzeltme sansi yok;
/// onlar icin turkish_case.dart'taki turkishUpper kullanilir.
class CreditsBlock extends StatelessWidget {
  const CreditsBlock({required this.rows, super.key});

  /// (etiket, deger) ciftleri. Degeri bos olanlar cizilmez.
  ///
  /// Coklu degerler cagiran tarafta joinMeta ile ' · ' birlestirilmis
  /// halde gelir.
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> dolu = rows
        .where(((String, String) row) => row.$2.isNotEmpty)
        .toList();

    if (dolu.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (String label, String value) in dolu)
            _CreditRow(label: label, value: value),
        ],
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  const _CreditRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
