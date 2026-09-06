import '../models/review.dart';
import 'api_client.dart';
import 'paged_response.dart';

/// Film ve dizi degerlendirmeleri.
///
/// FILTRE YOK: API filtre parametresi kabul etmiyor (views.py'de
/// filter_backends tanimli degil). Once sunucu tarafi gerekiyor, ayri kart.
class MoviesApi {
  MoviesApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<PagedResponse<Review>> fetchReviews({int page = 1}) async {
    final String path = page <= 1 ? 'movies/' : 'movies/?page=$page';
    final Map<String, dynamic> json = await _client.getJson(path);
    return parsePagedResponse(json, Review.fromJson, label: 'movies/');
  }
}
