import '../models/blog_post.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Bir sayfalik blog listesi.
///
/// Sarmalin ({count, next, previous, results}) uygulamaya lazim olan kismi.
/// [hasNextPage] KB-101'de sonsuz kaydirma icin gerekecek.
class BlogPage {
  const BlogPage({
    required this.posts,
    required this.hasNextPage,
    required this.totalCount,
  });

  final List<BlogPost> posts;

  /// Sarmaldaki `next` dolu mu.
  final bool hasNextPage;

  /// Sarmaldaki `count`: tum sayfalardaki toplam yazi sayisi.
  final int totalCount;
}

/// Blog uclarini cagiran katman.
class BlogApi {
  BlogApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  /// [page] 1'den baslar; DRF'nin sayfalama parametresi.
  Future<BlogPage> fetchPosts({int page = 1}) async {
    final String path = page <= 1 ? 'blog/' : 'blog/?page=$page';
    final Map<String, dynamic> json = await _client.getJson(path);

    final Object? results = json['results'];
    if (results is! List) {
      throw ApiException.parse(
        "blog/: 'results' liste bekleniyordu, ${results.runtimeType} geldi",
      );
    }

    final List<BlogPost> posts = [];
    for (final (int index, Object? item) in results.indexed) {
      if (item is! Map<String, dynamic>) {
        throw ApiException.parse(
          'blog/: results[$index] JSON nesnesi degil: ${item.runtimeType}',
        );
      }
      posts.add(BlogPost.fromJson(item));
    }

    final Object? count = json['count'];
    if (count is! int) {
      throw ApiException.parse(
        "blog/: 'count' sayi bekleniyordu, ${count.runtimeType} geldi",
      );
    }

    return BlogPage(
      posts: posts,
      // next null ise son sayfadayiz.
      hasNextPage: json['next'] != null,
      totalCount: count,
    );
  }
}
