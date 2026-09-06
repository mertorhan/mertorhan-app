import 'package:flutter/material.dart';

import '../models/blog_post.dart';
import '../theme/app_colors.dart';
import '../utils/post_meta.dart';

/// Yayinlar listesindeki tek bir yazi.
///
/// Duzen:
///   [80x80 gorsel]  Kategori · 19 Ağustos 2026 · 9 dk
///                   Yazinin basligi
///                   Ozet en fazla iki satir...
class BlogPostTile extends StatelessWidget {
  const BlogPostTile({required this.post, this.onTap, super.key});

  static const double _imageSize = 96;

  final BlogPost post;

  /// Dokunma davranisini cagiran belirler; navigasyon bu widgetin isi
  /// degil, boylece aptal kalir ve testi kolaylasir.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Cover(url: post.coverImage),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    postMetaLine(post),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.title,
                    style: textTheme.titleMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Bos ozet gecerli bir degerdir; o durumda alan hic cizilmez
                  // ve kart kisalir. null kontrolu yetmez, isEmpty gerekir.
                  if (post.summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.summary,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 96x96 kapak gorseli, yoksa ayni olcude yer tutucu.
///
/// Gorsel BoxFit.contain ile yerlestirilir: kirpilmaz, tamami gorunur.
/// Site tarafindaki kararla (KB-87) ayni. Contain nedeniyle kalan bosluk
/// yer tutucuyla ayni zemini alir, boylece kapakli ve kapaksiz kayitlar
/// ayni aileden gorunur ve liste hizalamasi bozulmaz.
class _Cover extends StatelessWidget {
  const _Cover({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      // Zemin tek yerden boyanir: hem contain boslugu hem yer tutucu.
      child: ColoredBox(
        color: AppColors.card,
        child: SizedBox(
          width: BlogPostTile._imageSize,
          height: BlogPostTile._imageSize,
          child: url == null
              ? const _CoverPlaceholder()
              : Image.network(
                  url!,
                  fit: BoxFit.contain,
                  // Olu URL de ayni yer tutucuya duser, duzen bozulmaz.
                  errorBuilder: (_, _, _) => const _CoverPlaceholder(),
                ),
        ),
      ),
    );
  }
}

/// Zemini _Cover boyar; burada yalnizca ikon var.
class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.image_outlined, color: AppColors.faint, size: 28),
    );
  }
}
