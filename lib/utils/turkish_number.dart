/// Puani ekranda gosterilecek metne cevirir.
///
/// Ondalik ayraci virgul: ekranda gorunen metinler Turkce.
/// Tam degerler ondaliksiz basilir (4.0 -> "4").
///
/// OLCEK YAZILMAZ. API puanin 5'lik mi 10'luk mu oldugunu soylemiyor;
/// canli veride 1.5 ve 4.5 gorunuyor ama bu bilgi sozlesmede yok.
/// Uydurmak yerine yalin sayi basiliyor.
String formatRating(num rating) {
  if (rating == rating.roundToDouble()) return rating.round().toString();
  return rating.toString().replaceAll('.', ',');
}
