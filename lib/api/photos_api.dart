import '../models/filter_options.dart';
import '../models/filter_selection.dart';
import '../models/photo.dart';
import 'api_client.dart';
import 'paged_response.dart';
import 'query.dart';

/// Galeri fotograflari.
///
/// Detay ucu yok: Photo modelinde slug yok, tekil kayda gidilemiyor.
class PhotosApi {
  PhotosApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// [selection] verilmezse filtre parametresi yazilmaz ve adres eskisiyle
  /// birebir ayni kalir.
  Future<PagedResponse<Photo>> fetchPhotos({
    int page = 1,
    FilterSelection? selection,
  }) async {
    final String path = buildPath('photos/', page: page, selection: selection);
    final Map<String, dynamic> json = await _client.getJson(path);
    return parsePagedResponse(json, Photo.fromJson, label: 'photos/');
  }

  /// Galeri listesinin filtre secenekleri. Tek grup: category.
  Future<FilterOptions> fetchFilterOptions() async {
    final Map<String, dynamic> json = await _client.getJson('filters/photos/');
    return FilterOptions.fromJson(json);
  }
}
