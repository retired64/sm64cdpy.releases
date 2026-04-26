import '../../domain/entities/dynos_entity.dart';

/// Data-layer model: knows how to deserialise from the DynOS JSON.
class DynosModel {
  const DynosModel({
    required this.id,
    required this.title,
    required this.version,
    required this.author,
    required this.description,
    this.imageUrl,
    required this.downloadUrl,
    required this.tags,
    this.rating,
    required this.ratingCount,
    required this.addedAt,
  });

  final String id;
  final String title;
  final String version;
  final String author;
  final String description;
  final String? imageUrl;
  final String downloadUrl;
  final List<String> tags;
  final double? rating;
  final int ratingCount;
  final String addedAt;

  factory DynosModel.fromJson(String id, Map<String, dynamic> json) {
    return DynosModel(
      id: id,
      title: json['title'] as String? ?? 'N/A',
      version: json['version'] as String? ?? 'N/A',
      author: json['author'] as String? ?? 'N/A',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      downloadUrl: json['download_url'] as String? ?? '',
      tags: _strings(json['tags']),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      addedAt: json['added_at'] as String? ?? '',
    );
  }

  static List<String> _strings(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  DynosEntity toEntity() => DynosEntity(
    id: id,
    title: title,
    version: version,
    author: author,
    description: description,
    imageUrl: imageUrl,
    downloadUrl: downloadUrl,
    tags: tags,
    rating: rating,
    ratingCount: ratingCount,
    addedAt: addedAt,
  );
}
