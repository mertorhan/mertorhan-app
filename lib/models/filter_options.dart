import '../api/api_exception.dart';
import 'filter_option.dart';

/// Bir liste ucunun filtre secenekleri.
///
/// Anahtarlar, liste ucunun SORGU PARAMETRE adlariyla birebir ayni
/// ('author', 'year', 'rating' ...). Bu bilincli: secenegi secime cevirmek
/// icin ad donusumu gerekmiyor.
///
/// Secenegi olmayan anahtar yanitta HIC YOK — bos dizi degil, anahtarin
/// kendisi yok. Ucun tamami bos olabilir: canlida /filters/books/ su an
/// `{}` donduruyor, cunku kitap kunyeleri henuz girilmemis. Bu hata degil.
class FilterOptions {
  const FilterOptions({required this.groups});

  const FilterOptions.empty() : groups = const {};

  static const String _label = 'FilterOptions';

  /// Sorgu parametresi adi -> secenekler.
  ///
  /// Sunucunun anahtar sirasi korunur. Grup basliklari ve gosterim sirasi
  /// arayuz karari; bu katman yalnizca sunucunun verdigini tasir.
  final Map<String, List<FilterOption>> groups;

  /// Bir grubun secenekleri; anahtar yoksa bos liste.
  ///
  /// Cagiran taraf null kontrolu yapmasin diye var.
  List<FilterOption> optionsFor(String key) => groups[key] ?? const [];

  bool get isEmpty => groups.isEmpty;

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    final Map<String, List<FilterOption>> groups = {};

    for (final MapEntry<String, dynamic> entry in json.entries) {
      final String key = entry.key;
      final Object? raw = entry.value;

      if (raw is! List) {
        throw ApiException.parse(
          "$_label: '$key' liste bekleniyordu, ${raw.runtimeType} geldi",
        );
      }

      // Sunucu bos grup gondermiyor; yine de gelirse anahtari hic acmayiz,
      // boylece "grup var ama secenek yok" diye bir ara durum olusmaz.
      if (raw.isEmpty) continue;

      final List<FilterOption> options = [];
      for (final (int index, Object? item) in raw.indexed) {
        if (item is! Map<String, dynamic>) {
          throw ApiException.parse(
            '$_label: $key[$index] JSON nesnesi degil: ${item.runtimeType}',
          );
        }
        options.add(FilterOption.fromJson(item));
      }
      groups[key] = options;
    }

    return FilterOptions(groups: groups);
  }

  @override
  String toString() => 'FilterOptions(${groups.keys.join(', ')})';
}
