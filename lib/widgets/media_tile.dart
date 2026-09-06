import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Dort turun ortak liste ogesi.
///
/// Duzen:
///   [96x96 gorsel]  Ust satir · parcalarla
///                   Baslik
///                   Ozet en fazla iki satir...
///
/// Blog, film, kitap ve galeri ayni kalibi kullanir; dort kopya yazilmaz.
class MediaTile extends StatelessWidget {
  const MediaTile({
    required this.imageUrl,
    required this.metaLine,
    required this.title,
    this.summary = '',
    this.onTap,
    super.key,
  });

  static const double _imageSize = 96;

  /// null ise yer tutucu cizilir; bosluk birakilmaz.
  final String? imageUrl;

  final String metaLine;
  final String title;

  /// Bos ise ozet satiri HIC cizilmez ve kart kisalir. Bos metin gecerli
  /// bir degerdir; null kontrolu yetmez.
  final String summary;

  /// Verilmezse oge dokunulabilir gorunmez. Film, kitap ve galeride
  /// detay ekrani yok, bu yuzden onTap gecilmiyor.
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
            _Cover(url: imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (metaLine.isNotEmpty) ...[
                    Text(
                      metaLine,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    title,
                    style: textTheme.titleMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      summary,
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
/// Gorsel BoxFit.contain ile yerlestirilir: kirpilmaz, tamami gorunur
/// (KB-87 karari). Contain nedeniyle kalan bosluk yer tutucuyla ayni
/// zemini alir, boylece gorselli ve gorselsiz kayitlar ayni aileden
/// gorunur ve liste hizalamasi bozulmaz.
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
          width: MediaTile._imageSize,
          height: MediaTile._imageSize,
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
