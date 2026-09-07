/// Kullanicinin sectigi filtreler.
///
/// DEGISMEZ (immutable): [toggle] ve [clear] mevcut nesneyi degistirmez,
/// yeni bir nesne dondurur. Sebep: Flutter'da durum degisikligi setState
/// ile bildiriliyor ve widget'lar "eski deger != yeni deger" karsilastirmasi
/// yapiyor. Yerinde degisen bir nesnede eski ve yeni AYNI nesne olurdu,
/// yani "degisti mi" sorusu cevaplanamaz hale gelirdi.
///
/// Bu yuzden ham kurucu private: gecersiz bir durum (bos kumeli anahtar)
/// disaridan kurulamasin. Nesne yalnizca empty()'den baslayip toggle ile
/// buyur.
class FilterSelection {
  const FilterSelection._(this.values);

  /// Hicbir sey secili degil.
  const FilterSelection.empty() : values = const {};

  /// Sorgu parametresi adi -> secili degerler.
  ///
  /// Anahtarlar FilterOptions'takilerle ayni: 'author', 'year', 'rating'...
  /// Bos kumeli anahtar BULUNMAZ; son deger kaldirilinca anahtar da duser
  /// (bkz. [toggle]).
  final Map<String, Set<String>> values;

  bool get isEmpty => values.isEmpty;

  bool get isNotEmpty => values.isNotEmpty;

  /// Tum gruplardaki secili deger sayisi. Rozet ("3 filtre") icin.
  int get count =>
      values.values.fold(0, (int toplam, Set<String> s) => toplam + s.length);

  bool isSelected(String key, String value) =>
      values[key]?.contains(value) ?? false;

  /// Degeri seciliyse cikarir, degilse ekler. YENI nesne dondurur.
  ///
  /// Bir anahtarin son degeri cikarilinca anahtar da silinir. Aksi halde
  /// {'author': {}} ile "author hic secilmemis" ayirt edilemezdi; isEmpty,
  /// == ve toQueryParameters uclu birden yaniltici olurdu.
  FilterSelection toggle(String key, String value) {
    final Map<String, Set<String>> next = <String, Set<String>>{
      for (final MapEntry<String, Set<String>> e in values.entries)
        e.key: Set<String>.of(e.value),
    };

    final Set<String> group = next.putIfAbsent(key, () => <String>{});
    // remove false donduyse deger zaten yoktu; o halde ekleme.
    if (!group.remove(value)) group.add(value);
    if (group.isEmpty) next.remove(key);

    return FilterSelection._(_kilitle(next));
  }

  FilterSelection clear() => const FilterSelection.empty();

  /// Sorgu dizesine yazilacak hali.
  ///
  /// Anahtarlar ve her anahtarin degerleri SIRALI dondurulur. Sebep:
  /// Set ve Map ekleme sirasini tasir, yani "once 2 sonra 1 sectim" ile
  /// "once 1 sonra 2 sectim" ayni secim oldugu halde farkli adres
  /// uretirdi. Sirasiz bir adres ne onbelleklenebilir ne de test edilebilir.
  Map<String, List<String>> toQueryParameters() {
    final List<String> keys = values.keys.toList()..sort();
    return <String, List<String>>{
      for (final String key in keys) key: (values[key]!.toList()..sort()),
    };
  }

  /// Disaridan degistirilemesin diye map ve icindeki kumeler kilitlenir.
  static Map<String, Set<String>> _kilitle(Map<String, Set<String>> source) {
    return Map<String, Set<String>>.unmodifiable(<String, Set<String>>{
      for (final MapEntry<String, Set<String>> e in source.entries)
        e.key: Set<String>.unmodifiable(e.value),
    });
  }

  /// Derin karsilastirma.
  ///
  /// Elle yazildi: DeepCollectionEquality icin package:collection gerekir,
  /// o ise yalnizca dolayli bagimlilik — depend_on_referenced_packages
  /// lint'i import'u reddeder ve pubspec'e paket eklemek bu kartin isi
  /// degil. Zaten iki dongu kadar is.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilterSelection) return false;
    if (values.length != other.values.length) return false;

    for (final MapEntry<String, Set<String>> entry in values.entries) {
      final Set<String>? digeri = other.values[entry.key];
      if (digeri == null || digeri.length != entry.value.length) return false;
      if (!entry.value.every(digeri.contains)) return false;
    }
    return true;
  }

  /// Anahtar ve deger sirasindan BAGIMSIZ olmali: ayni secim, hangi sirayla
  /// kurulursa kurulsun ayni hash'i vermeli. XOR bunu sagliyor.
  @override
  int get hashCode {
    int sonuc = 0;
    for (final MapEntry<String, Set<String>> entry in values.entries) {
      int icerik = 0;
      for (final String value in entry.value) {
        icerik ^= value.hashCode;
      }
      sonuc ^= Object.hash(entry.key, icerik);
    }
    return sonuc;
  }

  @override
  String toString() => 'FilterSelection(${toQueryParameters()})';
}
