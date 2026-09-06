import '../models/blog_post.dart';
import '../models/blog_post_detail.dart';
import 'api_client.dart';
import 'paged_response.dart';

/// Blog uclarini cagiran katman.
class BlogApi {
  BlogApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// [page] 1'den baslar; DRF'nin sayfalama parametresi.
  Future<PagedResponse<BlogPost>> fetchPosts({int page = 1}) async {
    final String path = page <= 1 ? 'blog/' : 'blog/?page=$page';
    final Map<String, dynamic> json = await _client.getJson(path);
    return parsePagedResponse(json, BlogPost.fromJson, label: 'blog/');
  }

  /// Tek bir yazinin detayi.
  ///
  /// Olmayan slug icin sunucu 404 doner; ApiClient durum kodu 200 degilse
  /// zaten ApiException.server(404) firlatiyor, burada ek kod gerekmiyor.
  Future<BlogPostDetail> fetchPost(String slug) async {
    final Map<String, dynamic> json = await _client.getJson('blog/$slug/');
    return BlogPostDetail.fromJson(json);
  }
}
