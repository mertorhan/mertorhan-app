import '../models/filter_options.dart';
import '../models/filter_selection.dart';
import '../models/review.dart';
import '../models/review_detail.dart';
import 'api_client.dart';
import 'paged_response.dart';
import 'query.dart';

/// Film ve dizi degerlendirmeleri.
///
/// En zengin filtre setine sahip uc: year, watched_year, director,
/// screenwriter, actor, genre, rating, content_type.
class MoviesApi {
  MoviesApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// [selection] verilmezse filtre parametresi yazilmaz ve adres eskisiyle
  /// birebir ayni kalir.
  Future<PagedResponse<Review>> fetchReviews({
    int page = 1,
    FilterSelection? selection,
  }) async {
    final String path = buildPath('movies/', page: page, selection: selection);
    final Map<String, dynamic> json = await _client.getJson(path);
    return parsePagedResponse(json, Review.fromJson, label: 'movies/');
  }

  /// Film listesinin filtre secenekleri.
  Future<FilterOptions> fetchFilterOptions() async {
    final Map<String, dynamic> json = await _client.getJson('filters/movies/');
    return FilterOptions.fromJson(json);
  }

  /// Tek bir film veya dizinin detayi.
  ///
  /// Olmayan slug icin sunucu 404 doner; ApiClient durum kodu 200 degilse
  /// zaten ApiException.server(404) firlatiyor, burada ek kod gerekmiyor.
  Future<ReviewDetail> fetchReview(String slug) async {
    final Map<String, dynamic> json = await _client.getJson('movies/$slug/');
    return ReviewDetail.fromJson(json);
  }
}
