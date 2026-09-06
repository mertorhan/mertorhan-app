import 'package:flutter/material.dart';

import '../api/blog_api.dart';
import '../api/books_api.dart';
import '../api/movies_api.dart';
import '../api/photos_api.dart';
import 'blog_list_screen.dart';
import 'book_list_screen.dart';
import 'movie_list_screen.dart';
import 'photo_list_screen.dart';

/// Testlerde sahte uygulamalari asagi gecirmek icin tasiyici.
///
/// Uretimde hicbiri verilmez; her liste ekrani kendi istemcisini kurar.
class PublicationsApis {
  const PublicationsApis({this.blog, this.movies, this.books, this.photos});

  final BlogApi? blog;
  final MoviesApi? movies;
  final BooksApi? books;
  final PhotosApi? photos;
}

/// Yayinlar sekmesi: dort tur ust sekme halinde.
///
/// Ust sekmeler YALNIZCA burada; Gezi, Rotalarim ve Profil yer tutucu.
/// Sekme renkleri temadan gelir, sabit renk yazilmaz.
class PublicationsScreen extends StatelessWidget {
  const PublicationsScreen({this.apis = const PublicationsApis(), super.key});

  final PublicationsApis apis;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yayınlar'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Blog'),
              Tab(text: 'Film ve dizi'),
              Tab(text: 'Kitap'),
              Tab(text: 'Galeri'),
            ],
          ),
        ),
        // TabBarView cocuklari tembel kurar: acilista dort istek birden
        // atilmaz, yalnizca gorunen sekme ceker. Bir kez cekildikten sonra
        // PagedListView durumu koruyor (AutomaticKeepAliveClientMixin).
        body: TabBarView(
          children: [
            BlogListScreen(api: apis.blog),
            MovieListScreen(api: apis.movies),
            BookListScreen(api: apis.books),
            PhotoListScreen(api: apis.photos),
          ],
        ),
      ),
    );
  }
}
