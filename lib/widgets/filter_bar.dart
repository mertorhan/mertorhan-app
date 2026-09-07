import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Film ve kitap listelerinin ustundeki filtre satiri.
///
/// Iki liste ekrani ayni satiri cizdigi icin kopyalanmadi — QuoteBox'taki
/// gerekcenin aynisi: biri degisirse digeri kaymasin.
///
/// Blog ve galeride KULLANILMAZ: onlarin tek grubu var, panel yerine hap
/// sirasi ciziliyor (bkz. FilterChipRow).
///
/// TEMIZLE, secim yokken HIC CIZILMEZ. Isleyecek bir sey olmayan dugme
/// gostermek, kullaniciya yapabilecegi bir sey varmis gibi soylemek olur.
class FilterBar extends StatelessWidget {
  const FilterBar({
    required this.selectedCount,
    required this.onOpen,
    required this.onClear,
    super.key,
  });

  /// Secili deger sayisi; 0 ise yalnizca "Filtrele" yazar.
  final int selectedCount;

  final VoidCallback onOpen;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool seciliVar = selectedCount > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.tune, size: 18),
                label: Text(
                  seciliVar ? 'Filtrele ($selectedCount)' : 'Filtrele',
                ),
              ),
              const Spacer(),
              if (seciliVar)
                TextButton(onPressed: onClear, child: const Text('Temizle')),
            ],
          ),
        ),
        // Listeden ayiran ince cizgi; liste ogeleri arasindaki ayracla
        // ayni aileden.
        const Divider(height: 1, color: AppColors.faint),
      ],
    );
  }
}
