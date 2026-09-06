import 'package:flutter/painting.dart';

/// mertorhan.com ile ortak marka paleti.
///
/// Uygulamadaki her renk buradan gelir. Widget icine sabit renk degeri
/// (`Color(0x...)`, `Colors.*`) yazilmaz; boylece palet tek yerden degisir.
abstract final class AppColors {
  /// Ekran zemini.
  static const Color paper = Color(0xFFF4F1E9);

  /// Zeminden bir ton acik kart yuzeyi.
  static const Color card = Color(0xFFFBF9F3);

  /// Baslik metni.
  static const Color ink = Color(0xFF232019);

  /// Govde metni.
  static const Color body = Color(0xFF332F29);

  /// Ikincil / destekleyici metin.
  static const Color secondary = Color(0xFF5F5A4F);

  /// Ayrac ve kenarlik.
  static const Color faint = Color(0xFF9A9282);

  /// Vurgu rengi.
  static const Color terracotta = Color(0xFFB4533A);

  /// Durum rengi.
  static const Color green = Color(0xFF5E8B5A);
}
