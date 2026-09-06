import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Uygulamanin tek tema tanimi.
///
/// Material 3 varsayilani korunur; uzerine marka rolleri ve tipografi
/// sabitlenir.
abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme colorScheme = _colorScheme;

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
      ),
    );
  }

  /// Tohum renkten uretilen M3 semasi; marka rolleri elle sabitlenir.
  ///
  /// Elle vermedigimiz rolleri (govde tonlari, durum renkleri) `fromSeed`
  /// tutarli sekilde uretsin diye taban olarak birakiliyor.
  static ColorScheme get _colorScheme => ColorScheme.fromSeed(
    seedColor: AppColors.terracotta,
  ).copyWith(
    primary: AppColors.terracotta,
    onPrimary: AppColors.paper,
    secondary: AppColors.green,
    onSecondary: AppColors.paper,
    surface: AppColors.paper,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.secondary,
    surfaceContainerLow: AppColors.card,
    outlineVariant: AppColors.faint,
  );

  /// Basliklar Newsreader (serif), geri kalani Hanken Grotesk (sans).
  ///
  /// `displayColor` display/headline/title katmanlarina, `bodyColor`
  /// body/label katmanlarina uygulanir.
  static TextTheme get _textTheme {
    final TextTheme serif = GoogleFonts.newsreaderTextTheme();
    final TextTheme sans = GoogleFonts.hankenGroteskTextTheme();

    return sans
        .copyWith(
          displayLarge: serif.displayLarge,
          displayMedium: serif.displayMedium,
          displaySmall: serif.displaySmall,
          headlineLarge: serif.headlineLarge,
          headlineMedium: serif.headlineMedium,
          headlineSmall: serif.headlineSmall,
        )
        .apply(displayColor: AppColors.ink, bodyColor: AppColors.body);
  }
}
