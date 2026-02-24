import 'package:equatable/equatable.dart';

class GalleryModel extends Equatable {
  final String? galleryId;
  final String? timestamp;
  final String? name;
  final String? smallUrl;
  final String? mediumUrl;
  final String? largeUrl;

  const GalleryModel({
    this.galleryId,
    this.timestamp,
    this.name,
    this.smallUrl,
    this.mediumUrl,
    this.largeUrl,
  });

  static String? _ensureHttps(String? url) {
    if (url == null) return null;
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    final urlData = json['url'] as Map<String, dynamic>?;
    return GalleryModel(
      galleryId: json['galleryid'] as String?,
      timestamp: json['timestamp'] as String?,
      name: json['name'] as String?,
      smallUrl: _ensureHttps(urlData?['small'] as String?),
      mediumUrl: _ensureHttps(urlData?['medium'] as String?),
      largeUrl: _ensureHttps(urlData?['large'] as String?),
    );
  }

  @override
  List<Object?> get props => [
    galleryId,
    timestamp,
    name,
    smallUrl,
    mediumUrl,
    largeUrl,
  ];
}
