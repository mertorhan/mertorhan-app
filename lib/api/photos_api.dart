import '../models/photo.dart';
import 'api_client.dart';
import 'paged_response.dart';

/// Galeri fotograflari.
///
/// Detay ucu yok: Photo modelinde slug yok, tekil kayda gidilemiyor.
class PhotosApi {
  PhotosApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<PagedResponse<Photo>> fetchPhotos({int page = 1}) async {
    final String path = page <= 1 ? 'photos/' : 'photos/?page=$page';
    final Map<String, dynamic> json = await _client.getJson(path);
    return parsePagedResponse(json, Photo.fromJson, label: 'photos/');
  }
}
