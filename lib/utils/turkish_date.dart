/// Ay adlari. Indeks 0 kullanilmaz; DateTime.month 1-12 arasi.
///
/// intl paketi eklenmedi: uygulama tek dilli, bir liste icin paket
/// bagimliligi tasimaya degmez.
const List<String> _aylar = [
  '',
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

/// '19 Ağustos 2026' bicimi.
String formatTurkishDate(DateTime date) =>
    '${date.day} ${_aylar[date.month]} ${date.year}';

/// 'Mart 2026' bicimi: gun YOK.
///
/// Kitabin okunma tarihi icin. Gun basmak "bu kitabi su gun bitirdim"
/// demek olurdu; veri o kadar kesin degil, ay yeterli.
String formatTurkishMonthYear(DateTime date) =>
    '${_aylar[date.month]} ${date.year}';
