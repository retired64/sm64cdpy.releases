/// Pure domain entity — no Flutter / JSON imports.
class DynosEntity {
  const DynosEntity({
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

  @override
  bool operator ==(Object other) => other is DynosEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
