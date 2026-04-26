import '../../domain/entities/touch_control_entity.dart';

/// Data-layer model: knows how to deserialise from the Touch Controls JSON.
class TouchControlModel {
  const TouchControlModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.downloadUrl,
    required this.addedAt,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final String downloadUrl;
  final String addedAt;

  factory TouchControlModel.fromJson(String id, Map<String, dynamic> json) {
    return TouchControlModel(
      id: id,
      title: json['title'] as String? ?? 'N/A',
      imageUrl: json['image_url'] as String?,
      downloadUrl: json['download_url'] as String? ?? '',
      addedAt: json['added_at'] as String? ?? '',
    );
  }

  TouchControlEntity toEntity() => TouchControlEntity(
    id: id,
    title: title,
    imageUrl: imageUrl,
    downloadUrl: downloadUrl,
    addedAt: addedAt,
  );
}
