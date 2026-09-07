import 'package:flutter/material.dart';

import '../models/filter_option.dart';
import '../theme/app_colors.dart';

/// Blog ve galeri icin yatay kaydirilan hap sirasi.
///
/// Bu iki ucun tek grubu var (category). Panel actirmak, tek bir listeyi
/// gormek icin iki dokunus fazla olurdu; sitedeki ayrimin aynisi.
///
/// TEK SECIM: sitedeki blog/galeri davranisi boyle. Ayni hapa tekrar
/// basmak secimi kaldirir, yani "Tumu"ye doner.
///
/// Cok gruplu turler (film, kitap) bunun yerine FilterBar + FilterSheet
/// kullanir.
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    super.key,
  });

  final List<FilterOption> options;

  /// null ise "Tumu" etkin.
  final String? selectedValue;

  /// Secim kalkinca null gelir.
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              _Chip(
                label: 'Tümü',
                selected: selectedValue == null,
                // Zaten "Tumu" seciliyken tekrar basmak bir sey
                // degistirmemeli.
                onTap: selectedValue == null ? null : () => onSelected(null),
              ),
              for (final FilterOption option in options) ...[
                const SizedBox(width: 8),
                _Chip(
                  label: '${option.label} (${option.count})',
                  selected: selectedValue == option.value,
                  onTap: () => onSelected(
                    // Ayni hapa tekrar basmak secimi kaldirir.
                    selectedValue == option.value ? null : option.value,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.faint),
      ],
    );
  }
}

/// Tek hap.
///
/// Renkler AppColors'tan: secili hap vurgu zeminli, digerleri kart
/// yuzeyinde ince kenarlikli.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? AppColors.terracotta : AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.terracotta : AppColors.faint,
            ),
          ),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.paper : AppColors.body,
            ),
          ),
        ),
      ),
    );
  }
}
