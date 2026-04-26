import '../../domain/entities/vip_mod_entity.dart';

/// Data-layer model: knows how to deserialise from the VIP JSON.
class VipModModel {
  const VipModModel({
    required this.id,
    required this.title,
    required this.version,
    required this.recommendedVersion,
    required this.author,
    required this.description,
    this.imageUrl,
    required this.downloadUrl,
    required this.tags,
    this.rating,
    required this.ratingCount,
    required this.isFeatured,
    required this.addedAt,
  });

  final String id;
  final String title;
  final String version;
  final String recommendedVersion;
  final String author;
  final String description;
  final String? imageUrl;
  final String downloadUrl;
  final List<String> tags;
  final double? rating;
  final int ratingCount;
  final bool isFeatured;
  final String addedAt;

  factory VipModModel.fromJson(String id, Map<String, dynamic> json) {
    return VipModModel(
      id: id,
      title: json['title'] as String? ?? 'N/A',
      version: json['version'] as String? ?? 'N/A',
      recommendedVersion: json['recommended_version'] as String? ?? 'N/A',
      author: json['author'] as String? ?? 'N/A',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      downloadUrl: json['download_url'] as String? ?? '',
      tags: _strings(json['tags']),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      addedAt: json['added_at'] as String? ?? '',
    );
  }

  static List<String> _strings(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  VipModEntity toEntity() => VipModEntity(
    id: id,
    title: title,
    version: version,
    recommendedVersion: recommendedVersion,
    author: author,
    description: description,
    imageUrl: imageUrl,
    downloadUrl: downloadUrl,
    tags: tags,
    rating: rating,
    ratingCount: ratingCount,
    isFeatured: isFeatured,
    addedAt: addedAt,
  );
}
