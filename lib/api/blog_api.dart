import '../models/blog_post.dart';
import '../models/blog_post_detail.dart';
import '../models/filter_options.dart';
import '../models/filter_selection.dart';
import 'api_client.dart';
import 'paged_response.dart';
import 'query.dart';

/// Blog uclarini cagiran katman.
class BlogApi {
  BlogApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// [page] 1'den baslar; DRF'nin sayfalama parametresi.
  ///
  /// [selection] verilmezse filtre parametresi yazilmaz ve adres eskisiyle
  /// birebir ayni kalir.
  Future<PagedResponse<BlogPost>> fetchPosts({
    int page = 1,
    FilterSelection? selection,
  }) async {
    final String path = buildPath('blog/', page: page, selection: selection);
    final Map<String, dynamic> json = await _client.getJson(path);
    return parsePagedResponse(json, BlogPost.fromJson, label: 'blog/');
  }

  /// Blog listesinin filtre secenekleri. Tek grup: category.
  Future<FilterOptions> fetchFilterOptions() async {
    final Map<String, dynamic> json = await _client.getJson('filters/blog/');
    return FilterOptions.fromJson(json);
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
