# mertorhan-app — Proje Rehberi

Bu dosya Claude Code içindir. Projeye dair kalıcı bilgiler ve kurallar burada.

## 🔴 ÖNCE BUNU OKU: Bu depo Django değil

`mertorhan-site` deposuyla kardeş ama ayrı bir kod tabanı. Buraya Django
alışkanlıklarını taşıma:

- `manage.py`, `settings.py`, migration, `venv/` **yok**
- Şablon yerine Dart kodu, CSS yerine `ThemeData`
- Sanal ortam yok; Flutter SDK sistemde kurulu

İki depo aynı markaya hizmet eder, aynı kurallarla çalışır, ama kodları
birbirine benzemez.

## Dil
Benimle **Türkçe** konuş. Kod, sınıf ve değişken isimleri İngilizce;
ekranda görünen metinler Türkçe.

## Proje nedir
mertorhan.com'un mobil uygulaması. Flutter ile yazılıyor.
Uygulama bir vitrin/rehber — reklam panosu değil.

**Marka pusulası: "SAT DEĞİL, GÖSTER."**
- Billboard/slogan/pazarlama dili yasak.
- Dürüstlük > estetik.
- Kimlik: kuran/üreten bağımsız biri. "İş arayan" tonu kullanma.
- **Karşılama/tanıtım ekranı yok.** Sistem açılış ekranında sadece MO işareti;
  metin veya slogan eklenmez.

## Teknik künye
- Flutter 3.47.2 (stable) · Dart 3.13.2
- Yerel: `~/Desktop/mertorhan-app`
- Depo: github.com/mertorhan/mertorhan-app (ana dal: `main`, **public**)
- Hedef platformlar: Android + iOS. Web/masaüstü klasörleri bilerek üretilmedi.

## 🔒 KİMLİKLER — DEĞİŞTİRİLEMEZ

| Ne | Değer | Nerede |
|---|---|---|
| Bundle id / applicationId | `com.mertorhan.app` | `build.gradle.kts:18`, `project.pbxproj` (6 satır) |
| Kod namespace | `com.mertorhan.mertorhan_app` | `build.gradle.kts:8` |
| Dart paket adı | `mertorhan_app` | `pubspec.yaml:1` |
| Görünen ad | `Mert Orhan` | `AndroidManifest.xml`, `Info.plist` |

Bundle id mağazaya çıkıldıktan sonra değiştirilemez — değiştirilirse mağaza
uygulamayı bambaşka bir uygulama sayar.

`namespace` ile `applicationId` **bilerek farklıdır.** namespace kod kimliğidir
ve `MainActivity.kt`'nin klasör yoluyla eşleşmek zorundadır; applicationId
mağaza kimliğidir. İkisini "tutarlılık" adına eşitleme.

**Bu dört değerin hiçbirine dokunma.** Gerekiyorsa önce bana sor.

## Tasarım
Renkler ve fontlar `mertorhan.com` ile aynı olacak. Henüz `ThemeData`
kurulmadı — `lib/` şu an `flutter create` demo kodudur.

- Zemin `#f4f1e9` · Kart `#fbf9f3`
- Metin `#232019` · Gövde `#332f29` · İkincil `#5f5a4f`
- Vurgu `#b4533a` (terracotta) · Durum `#5e8b5a` (yeşil)
- Font: Newsreader (serif) · Hanken Grotesk (sans)

Tema kurulduğunda renkler **tek yerde** tanımlanır; widget içine sabit renk
değeri yazılmaz.

## API
Taban adres: `https://mertorhan.com/api/v1/`
Hepsi salt okunur. Mevcut uçlar: `/blog/`, `/movies/`, `/books/`, `/photos/`.
Rota (`/routes/`) ucu **henüz yok.**

⚠️ Sözleşme pürüzleri — model sınıfları yazılırken bilinmeli:

- Boş metin alanları `""` döner, `null` değil. Dart'ta `isNotEmpty` gerekir.
- `iso` bir metin alanıdır: `"100"` string döner.
- `rating` sayı döner, string değil.
- `image_width`, `image_height`, `thumbnail` eski kayıtlarda `null` olabilir.
- `content_type` ham değer döner (`"film"`), görünen etiket değil.
- Künye ad listeleri alfabetik döner; başrol sırası korunmaz.
- `/photos/` için detay ucu yok.
- Sıralama garantisi yok: `published_at` gün hassasiyetlidir.

Adresler İngilizce, site adresleri Türkçe. API makine yüzü, site insan yüzü.

## Sık komutlar
```bash
flutter run          # emülatörde çalıştır (r: hot reload, q: çık)
flutter analyze      # statik kontrol
flutter test         # testler
flutter pub get      # bağımlılıkları çek
```

## JIRA
İşler Jira'da takip edilir. Proje anahtarı: **KB**
Kartlar `KB-12` gibi numaralanır. Mobil işler `KB-9` epic'i altında.

Bir işe başlarken sana kart numarasını veririm. Numara verilmediyse **sor** —
kartsız iş yapmıyoruz.

## ÇALIŞMA KURALLARI

1. **Önce plan, sonra kod.** Dosyaya dokunmadan önce ne yapacağını maddeler
   hâlinde söyle ve onayımı bekle.
2. **Küçük adımlar.** Aynı anda tek konu.
3. **Nedenini açıkla.** Bu proje aynı zamanda benim öğrenme sürecim.
   Ezber yaptırma.
4. **Varsayım yapma.** Emin değilsen sor. Dosyayı okumadan "muhtemelen
   şöyledir" deme.
5. İş bitince **rapor formatına göre** özet ver.

## KAPSAM FRENİ

Sana verilen kartın dışına çıkma. Bu kural diğer her şeyin üstündedir.

- Yolda başka bir sorun görürsen **düzeltme.** Bana söyle, kart açayım.
- "Zaten oradaydım, hazır düzelttim" yapma. Küçük de olsa yapma.
- Bir iş için birden fazla dosya değişmesi normaldir; birden fazla **konu**
  değişmesi normal değildir.

Neden: aynı anda iki iş yaparsan, bir şey kırıldığında hangisinin kırdığı
belli olmaz.

## DAL (BRANCH) DÜZENİ

**Kural: `main` üzerinde iş yapılmaz.** Her iş kendi dalında yürür.

### Başlarken
1. `git status` ile çalışma alanının temiz olduğunu doğrula.
2. Kirliyse **bana sor** — kendi kararınla temizleme.
3. Dalı aç:
```bash
   git checkout main
   git pull
   git checkout -b is/KB-12-kisa-aciklama
```

### Dal isimlendirme (Türkçe karakter ve boşluk YOK)
Kalıp: `tur/KB-<numara>-kisa-aciklama`
- Geliştirme → `is/KB-98-yayinlar-listesi`
- Hata düzeltme → `duzeltme/KB-99-liste-kaymasi`

Kart numarası dal adında **zorunlu.**

### Biterken
1. `flutter analyze` çalıştır. Uyarı varsa önce onu çöz.
2. **Commit at.** Mantıksal olarak ayrı değişiklikler ayrı commit'lere bölünür.
3. **Push etme.** Merge ve push kararı bana ait.
4. Raporunu aşağıdaki formatta ver.

### Rapor formatı

    KART:     KB-12
    DAL:      is/KB-12-kisa-aciklama
    COMMIT:   <commit mesaji/mesajlari>
    DEGISEN:  <dosya listesi, her biri icin tek satir neden>
    RISK:     <ne kirilabilir, neyi kacirmis olabilirim>
    TEST:     <benim emulatorde ne kontrol etmem gerekiyor, madde madde>

`RISK` satırını boş bırakma. "Risk yok" diyeceksen bile neden olmadığını yaz.

### İstisna
Tek commit'lik ufak işlerde (ör. bu dosyayı güncellemek) dal şart değil.
Emin değilsen dal aç — maliyeti sıfır.

## GIT KURALLARI
- `git push` **yapma** — push'u ben yaparım.
- `git merge` / `git rebase` **yapma**.
- `git reset --hard`, `git clean` gibi yıkıcı komutları **asla** çalıştırma.
- Commit mesajları Türkçe ama **Türkçe karakter kullanmadan** yazılır ve
  kart numarasıyla başlar: `KB-96: Bundle id duzeltmesi`
- Depo public — koda hiçbir sır, şifre, anahtar, e-posta gömülmez.
  API anahtarları koda yazılmaz, `--dart-define` ile dışarıdan verilir.

## DOKUNMA
- `android/key.properties`, `*.jks`, `*.keystore` — imzalama anahtarları.
  Sızarsa uygulamanın kimliği çalınır, geri dönüşü yoktur.
- `build/`, `.dart_tool/`, `ios/Pods/` — üretilen dosyalar
- `.vscode/` — kişiye özel editör ayarları
- `android/.gitignore` ve `ios/.gitignore` — ikisi de incelendi, doğru
- `.gitignore` içeriğini onayım olmadan değiştirme

## ⚠️ ÇALIŞTIRMA
- `flutter create` komutunu bu klasörde **tekrar çalıştırma.** Üzerine yazar.
- `flutter clean` çalıştırma — gerekiyorsa bana söyle.
- `flutter pub upgrade` çalıştırma. `pubspec.yaml` bağımlılık değişikliği
  onaya tabidir.
- Yeni paket eklemeden önce **sor.** Her bağımlılık kalıcı bir yüktür.
