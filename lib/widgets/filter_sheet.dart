import 'package:flutter/material.dart';

import '../models/filter_option.dart';
import '../models/filter_options.dart';
import '../models/filter_selection.dart';
import '../theme/app_colors.dart';
import '../utils/filter_labels.dart';

/// Film ve kitap icin cok gruplu filtre paneli.
///
/// Alttan acilan tam boy sayfa; iki liste ekrani ayni paneli kullaniyor.
///
/// SECIM PANEL ICINDE GECICI TUTULUR. "Uygula"ya basilana kadar cagiran
/// taraf hicbir sey gormez; ✕ ya da geri ile kapatilirsa null doner ve
/// liste oldugu gibi kalir. Sebep: her kutucukta istek atmak, kullanici
/// aklini degistirdiginde bosa giden istekler uretirdi.
///
/// Secenegi olmayan grup HIC CIZILMEZ (bkz. visibleGroups).
///
/// [current] degistirilmez; FilterSelection zaten degismez bir nesne,
/// panel kendi kopyasi uzerinde calisir.
Future<FilterSelection?> showFilterSheet({
  required BuildContext context,
  required FilterOptions options,
  required FilterSelection current,
  required FilterGroups groups,
}) {
  return showModalBottomSheet<FilterSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    builder: (_) =>
        _FilterSheet(options: options, current: current, groups: groups),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.options,
    required this.current,
    required this.groups,
  });

  final FilterOptions options;
  final FilterSelection current;
  final FilterGroups groups;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  /// Panel kapanana kadar yasayan gecici secim.
  late FilterSelection _temp = widget.current;

  @override
  Widget build(BuildContext context) {
    final FilterGroups gorunur = visibleGroups(widget.groups, widget.options);

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: SafeArea(
        child: Column(
          children: [
            _Header(count: _temp.count),
            const Divider(height: 1, color: AppColors.faint),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  for (final (String key, String label) in gorunur)
                    _Group(
                      label: label,
                      options: widget.options.optionsFor(key),
                      selection: _temp,
                      groupKey: key,
                      onToggle: (String value) => setState(() {
                        _temp = _temp.toggle(key, value);
                      }),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.faint),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  // Paneli KAPATMAZ, yalnizca gecici secimi bosaltir;
                  // kullanici bastan secmek isteyebilir.
                  TextButton(
                    onPressed: _temp.isEmpty
                        ? null
                        : () => setState(() => _temp = _temp.clear()),
                    child: const Text('Temizle'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_temp),
                    child: const Text('Uygula'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Text(
            count > 0 ? 'Filtrele ($count)' : 'Filtrele',
            style: textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            // Deger vermeden kapanir: cagiran taraf null alir ve hicbir
            // sey degistirmez.
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Kapat',
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.label,
    required this.options,
    required this.selection,
    required this.groupKey,
    required this.onToggle,
  });

  final String label;
  final List<FilterOption> options;
  final FilterSelection selection;
  final String groupKey;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int secili = options
        .where((FilterOption o) => selection.isSelected(groupKey, o.value))
        .length;

    return ExpansionTile(
      title: Text(label, style: textTheme.titleSmall),
      subtitle: secili == 0
          ? null
          : Text(
              '$secili seçili',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.terracotta,
              ),
            ),
      children: [
        for (final FilterOption option in options)
          CheckboxListTile(
            value: selection.isSelected(groupKey, option.value),
            onChanged: (_) => onToggle(option.value),
            title: Text(
              '${option.label} (${option.count})',
              style: textTheme.bodyMedium,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
      ],
    );
  }
}
