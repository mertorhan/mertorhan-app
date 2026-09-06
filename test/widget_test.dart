import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mertorhan_app/api/blog_api.dart';
import 'package:mertorhan_app/navigation/home_shell.dart';
import 'package:mertorhan_app/theme/app_theme.dart';

/// Sahte uygulama: Yayinlar sekmesi artik gercek ekrana bagli, yani sahte
/// verilmezse bu testler gercek istek atardi. Aga cikan test internet
/// yavassa kirmizi olur ve kodda hata varmis gibi gorunur.
class _FakeBlogApi extends BlogApi {
  @override
  Future<BlogPage> fetchPosts({int page = 1}) async =>
      const BlogPage(posts: [], hasNextPage: false, totalCount: 0);
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
  home: HomeShell(blogApi: _FakeBlogApi()),
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
