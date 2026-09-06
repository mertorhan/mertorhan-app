import 'api_exception.dart';

/// Sayfalanmis bir listenin uygulamaya lazim olan kismi.
///
/// Dort ucun (blog, movies, books, photos) sarmali ayni:
/// {count, next, previous, results}. Ayni ayristirma dort kez yazilmasin
/// diye tek yerde toplandi.
class PagedResponse<T> {
  const PagedResponse({
    required this.items,
    required this.hasNextPage,
    required this.totalCount,
  });

  final List<T> items;

  /// Sarmaldaki `next` dolu mu.
  final bool hasNextPage;

  /// Sarmaldaki `count`: tum sayfalardaki toplam kayit sayisi.
  final int totalCount;
}

/// Sarmali cozer, her kaydi [itemFromJson] ile modele cevirir.
///
/// [label] yalnizca hata mesajlarinda gecer; hangi ucun yanitinin bozuk
/// oldugunu soyler.
PagedResponse<T> parsePagedResponse<T>(
  Map<String, dynamic> json,
  T Function(Map<String, dynamic>) itemFromJson, {
  required String label,
}) {
  final Object? results = json['results'];
  if (results is! List) {
    throw ApiException.parse(
      "$label: 'results' liste bekleniyordu, ${results.runtimeType} geldi",
    );
  }

  final List<T> items = [];
  for (final (int index, Object? item) in results.indexed) {
    if (item is! Map<String, dynamic>) {
      throw ApiException.parse(
        '$label: results[$index] JSON nesnesi degil: ${item.runtimeType}',
      );
    }
    items.add(itemFromJson(item));
  }

  final Object? count = json['count'];
  if (count is! int) {
    throw ApiException.parse(
      "$label: 'count' sayi bekleniyordu, ${count.runtimeType} geldi",
    );
  }

  return PagedResponse<T>(
    items: items,
    // next null ise son sayfadayiz.
    hasNextPage: json['next'] != null,
    totalCount: count,
  );
}
