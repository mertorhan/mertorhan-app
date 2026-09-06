/// API katmaninin firlattigi tek hata turu.
///
/// Cagiran taraf `kind`'a bakarak davranis secebilir (ornegin yalnizca
/// `network` ve `timeout` icin "Tekrar dene" dugmesi gostermek gibi).
/// Ekrana basilacak metin `userMessage`'dan gelir; `detail` teknik ayrinti
/// tasir ve kullaniciya gosterilmez.
library;

/// Hatanin kaynagi.
enum ApiErrorKind {
  /// Ag yok, sunucuya hic ulasilamadi.
  network,

  /// Sunucu zamaninda yanit vermedi.
  timeout,

  /// Sunucu yanit verdi ama durum kodu 200 degil.
  server,

  /// Yanit alindi ama cozumlenemedi: bozuk JSON, beklenen alan yok,
  /// alanin tipi beklenenden farkli.
  parse,
}

class ApiException implements Exception {
  const ApiException(this.kind, {this.statusCode, this.detail});

  /// Sunucuya hic ulasilamadi.
  const ApiException.network({String? detail})
    : this(ApiErrorKind.network, detail: detail);

  /// Istek zaman asimina ugradi.
  const ApiException.timeout({String? detail})
    : this(ApiErrorKind.timeout, detail: detail);

  /// 200 disi durum kodu. Kod raporlanir.
  const ApiException.server(int statusCode, {String? detail})
    : this(ApiErrorKind.server, statusCode: statusCode, detail: detail);

  /// Yanit beklenen bicimde degil.
  const ApiException.parse(String detail)
    : this(ApiErrorKind.parse, detail: detail);

  final ApiErrorKind kind;

  /// Yalnizca [ApiErrorKind.server] icin dolu.
  final int? statusCode;

  /// Teknik ayrinti. Log ve hata ayiklama icin; ekranda gosterilmez.
  final String? detail;

  /// Ekranda gosterilecek Turkce mesaj.
  String get userMessage => switch (kind) {
    ApiErrorKind.network =>
      'İnternet bağlantısı kurulamadı. Bağlantını kontrol edip tekrar dene.',
    ApiErrorKind.timeout =>
      'Sunucu zamanında yanıt vermedi. Biraz sonra tekrar dene.',
    ApiErrorKind.server =>
      'Sunucuya ulaşılamadı (hata kodu $statusCode). Biraz sonra tekrar dene.',
    ApiErrorKind.parse =>
      'Sunucudan beklenmeyen bir yanıt geldi. Sorun bizde, bakacağım.',
  };

  @override
  String toString() {
    final buffer = StringBuffer('ApiException(${kind.name}');
    if (statusCode != null) buffer.write(', status: $statusCode');
    if (detail != null) buffer.write(', detail: $detail');
    buffer.write(')');
    return buffer.toString();
  }
}
