import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Detay ekranlarinin ortak hata gorunumu: mesaj + "Tekrar dene".
///
/// Blog ve kitap detayi bunu birebir ayni sekilde iki kez tasiyordu;
/// film detayi ucuncu kopyayi uretecekti. QuoteBox'taki gerekcenin
/// aynisi: ayni seyi cizen ekranlar kopyalanmaz, biri degisirse digeri
/// kaymasin.
///
/// PagedListView'daki _MessageView bununla BIRLESTIRILMEDI: o
/// kaydirilabilir (RefreshIndicator ancak kaydirilabilir bir cocukla
/// calisiyor) ve bos durum mesajini da tasiyor. Farkli bir sey.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, required this.onRetry, super.key});

  /// Kullaniciya gosterilecek metin; ApiException.userMessage'dan gelir.
  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
