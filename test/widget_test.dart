import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/blog_api.dart';
import 'package:mertorhan_app/api/paged_response.dart';
import 'package:mertorhan_app/models/blog_post.dart';
import 'package:mertorhan_app/models/filter_options.dart';
import 'package:mertorhan_app/models/filter_selection.dart';
import 'package:mertorhan_app/navigation/home_shell.dart';
import 'package:mertorhan_app/screens/publications_screen.dart';
import 'package:mertorhan_app/theme/app_theme.dart';

/// Sahte uygulama: Yayinlar sekmesi artik gercek ekrana bagli, yani sahte
/// verilmezse bu testler gercek istek atardi. Aga cikan test internet
/// yavassa kirmizi olur ve kodda hata varmis gibi gorunur.
class _FakeBlogApi extends BlogApi {
  @override
  Future<PagedResponse<BlogPost>> fetchPosts({int page = 1, FilterSelection? selection}) async =>
      const PagedResponse<BlogPost>(items: [], hasNextPage: false, totalCount: 0);

  /// fetchFilterOptions ezilmezse uretim govdesi calisir ve test GERCEK
  /// aga cikar; sahte API gercek sinifi extend ediyor. Blog ve galeri
  /// ekrani secenekleri ACILISTA cektigi icin bu kacinilmaz.
  @override
  Future<FilterOptions> fetchFilterOptions() async =>
      const FilterOptions.empty();

}

/// Sekme adi ayni anda navigasyon cubugunda ve AppBar'da gecer. Duz
/// find.text birden fazla eslesme dondurur; AppBar'a daraltmak hangi
/// ekranin acik oldugunu kesin sekilde soyler.
Finder _appBarTitle(String title) => find.descendant(
  of: find.byType(AppBar),
  matching: find.text(title),
);

Widget _wrap() => MaterialApp(
  theme: AppTheme.light,
  home: HomeShell(
    publicationsApis: PublicationsApis(blog: _FakeBlogApi()),
  ),
);

void main() {
  testWidgets('Acilista Yayinlar sekmesi gorunur', (WidgetTester tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(_appBarTitle('Yayınlar'), findsOneWidget);
  });

  testWidgets('Profil sekmesine dokununca Profil ekrani gelir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    // Ikon yalnizca navigasyon cubugunda var, tek eslesme.
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(_appBarTitle('Profil'), findsOneWidget);
    expect(_appBarTitle('Yayınlar'), findsNothing);
  });
}
