import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// mertorhan.com API'sine GET atan ince istemci.
///
/// Tek isi: istegi yapmak, hatalari [ApiException]'a cevirmek, govdeyi JSON
/// olarak cozmek. Alan bilgisi tasimaz; modelleri cagiran taraf kurar.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Taban adres.
  ///
  /// Apex alan adi (mertorhan.com) API'yi sunmuyor ve www'ye yonlendirmiyor;
  /// dogrulandi, /api/... orada 404 donuyor. Bu yuzden adres www ile yazili.
  static const String baseUrl = 'https://www.mertorhan.com/api/v1/';

  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  /// [path] taban adrese eklenir, ornegin 'blog/'.
  ///
  /// Basarili yanitta cozulmus JSON nesnesini dondurur.
  Future<Map<String, dynamic>> getJson(String path) async {
    final Uri uri = Uri.parse('$baseUrl$path');

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException catch (e) {
      throw ApiException.timeout(detail: '$uri: $e');
    } on SocketException catch (e) {
      throw ApiException.network(detail: '$uri: $e');
    } on http.ClientException catch (e) {
      throw ApiException.network(detail: '$uri: $e');
    }

    if (response.statusCode != 200) {
      throw ApiException.server(response.statusCode, detail: '$uri');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw ApiException.parse('$uri: govde JSON degil: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw ApiException.parse(
        '$uri: JSON nesnesi bekleniyordu, ${decoded.runtimeType} geldi',
      );
    }
    return decoded;
  }

  /// Uygulama kapanirken veya istemci artik kullanilmayacakken cagrilir.
  void close() => _client.close();
}
