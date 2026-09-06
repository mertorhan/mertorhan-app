import 'package:flutter/material.dart';

import '../models/blog_post.dart';
import '../theme/app_colors.dart';
import '../utils/turkish_date.dart';

/// Yayinlar listesindeki tek bir yazi.
///
/// Duzen:
///   [80x80 gorsel]  Kategori · 19 Ağustos 2026 · 9 dk
///                   Yazinin basligi
///                   Ozet en fazla iki satir...
class BlogPostTile extends StatelessWidget {
  const BlogPostTile({required this.post, super.key});

  static const double _imageSize = 80;

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
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
                  _metaLine(post),
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
    );
  }
}

/// Ust satir: kategori · tarih · okuma suresi.
///
/// Parcalar once listeye toplanir, sonra birlestirilir. Boylece category
/// null oldugunda ayraci da dusmus olur; satir " · " ile baslayamaz.
String _metaLine(BlogPost post) {
  final List<String> parts = [
    if (post.category != null) post.category!,
    formatTurkishDate(post.publishedAt),
    '${post.readingTime} dk',
  ];
  return parts.join(' · ');
}

/// 80x80 kapak gorseli, yoksa ayni olcude yer tutucu.
///
/// Yer tutucu bosluk birakmaz; liste hizalamasi kapakli ve kapaksiz
/// kayitlarda ayni kalir.
class _Cover extends StatelessWidget {
  const _Cover({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: BlogPostTile._imageSize,
        height: BlogPostTile._imageSize,
        child: url == null
            ? const _CoverPlaceholder()
            : Image.network(
                url!,
                fit: BoxFit.cover,
                // Olu URL de ayni yer tutucuya duser, duzen bozulmaz.
                errorBuilder: (_, _, _) => const _CoverPlaceholder(),
              ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.card,
      child: Center(
        child: Icon(Icons.image_outlined, color: AppColors.faint, size: 28),
      ),
    );
  }
}
