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
      // Zemin card; govde paper oldugu icin ust cubuk ekrandan ayrisir.
      // Alt cizgi yok, ayrim zeminle kuruluyor.
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.ink,
      ),
      navigationBarTheme: _navigationBarTheme,
    );
  }

  /// Alt cubuk.
  ///
  /// M3 varsayilani tohum renginden pembemsi bir yuzey uretiyor ve krem
  /// zeminle uyusmuyordu; zemin AppColors.card'a sabitlendi.
  ///
  /// Secili gosterge, vurgu renginin 0.12 saydamlikli hali. Deger
  /// uydurma degil: mertorhan.com'da yesil haplar
  /// `rgba(94, 139, 90, 0.12)` zemin kullaniyor (style.css:1699). Ayni
  /// desen terracotta icin uygulaniyor.
  ///
  /// elevation 0 + saydam tint/golge: M3'un varsayilan yuksekligi yuzeye
  /// tint bindiriyor. Ikisi birlikte zemini duz birakir.
  static NavigationBarThemeData get _navigationBarTheme =>
      NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.terracotta.withValues(alpha: 0.12),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      );

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
  /// TextTheme.apply'in gercek eslemesi (kaynak: Flutter text_theme.dart):
  ///   displayColor -> display*, headlineLarge, headlineMedium, bodySmall
  ///   bodyColor    -> headlineSmall, title*, bodyLarge, bodyMedium, label*
  ///
  /// Iki katman bu eslemeyle istedigimiz rengi almiyor, o yuzden apply'in
  /// davranisina birakilmayip acikca sabitleniyorlar:
  ///   headlineSmall serif bir basliktir, ailenin geri kalani gibi ink alir.
  ///   bodySmall govde metnidir (liste ogesindeki ozet buradan gelir);
  ///   apply'in ona ink vermesi sezgiye aykiri, dogrusu body.
  static TextTheme get _textTheme {
    final TextTheme serif = GoogleFonts.newsreaderTextTheme();
    final TextTheme sans = GoogleFonts.hankenGroteskTextTheme();

    final TextTheme applied = sans
        .copyWith(
          displayLarge: serif.displayLarge,
          displayMedium: serif.displayMedium,
          displaySmall: serif.displaySmall,
          headlineLarge: serif.headlineLarge,
          headlineMedium: serif.headlineMedium,
          headlineSmall: serif.headlineSmall,
        )
        .apply(displayColor: AppColors.ink, bodyColor: AppColors.body);

    return applied.copyWith(
      headlineSmall: applied.headlineSmall?.copyWith(color: AppColors.ink),
      bodySmall: applied.bodySmall?.copyWith(color: AppColors.body),
    );
  }
}
