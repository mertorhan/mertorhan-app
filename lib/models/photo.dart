import 'json_parse.dart';

/// Galerideki tek bir fotograf.
///
/// DETAY UCU YOK: Photo modelinde slug yok, tekil kayda gidilemiyor.
class Photo {
  const Photo({
    required this.id,
    required this.title,
    required this.image,
    required this.thumbnail,
    required this.imageWidth,
    required this.imageHeight,
    required this.category,
    required this.location,
    required this.camera,
    required this.lens,
    required this.iso,
    required this.shutterSpeed,
    required this.aperture,
    required this.focalLength,
    required this.takenAt,
    required this.order,
  });

  static const String _label = 'Photo';

  final int id;
  final String title;

  /// null gelebilir.
  final String? image;

  /// Eski kayitlarda uretilmemis olabilir -> null.
  final String? thumbnail;

  /// Eski kayitlarda null gelebilir.
  final int? imageWidth;
  final int? imageHeight;

  /// null gelebilir.
  final String? category;

  /// Bos "" gelebilir.
  final String location;
  final String camera;
  final String lens;

  /// METIN alan: "100" gelir, sayi degil (modelde CharField).
  /// Bilerek int'e cevrilmiyor.
  final String iso;

  /// Bos "" gelebilir.
  final String shutterSpeed;
  final String aperture;
  final String focalLength;

  /// null gelebilir.
  final DateTime? takenAt;

  final int order;

  /// Listede gosterilecek gorsel: kucugu varsa o, yoksa tam boy.
  /// Ikisi de yoksa null — cagiran yer tutucu cizer.
  String? get listImage => thumbnail ?? image;

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: requireInt(json, 'id', _label),
      title: requireString(json, 'title', _label),
      image: optionalString(json, 'image', _label),
      thumbnail: optionalString(json, 'thumbnail', _label),
      imageWidth: optionalInt(json, 'image_width', _label),
      imageHeight: optionalInt(json, 'image_height', _label),
      category: optionalString(json, 'category', _label),
      location: requireString(json, 'location', _label),
      camera: requireString(json, 'camera', _label),
      lens: requireString(json, 'lens', _label),
      iso: requireString(json, 'iso', _label),
      shutterSpeed: requireString(json, 'shutter_speed', _label),
      aperture: requireString(json, 'aperture', _label),
      focalLength: requireString(json, 'focal_length', _label),
      takenAt: optionalDate(json, 'taken_at', _label),
      order: requireInt(json, 'order', _label),
    );
  }

  @override
  String toString() => 'Photo($id, $title)';
}
