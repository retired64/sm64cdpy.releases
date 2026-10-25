/// Pure domain entity — no Flutter / JSON imports.
class TouchControlEntity {
  const TouchControlEntity({
    required this.id,
    required this.title,
    this.author = 'Release Soon',
    this.imageUrl,
    required this.downloadUrl,
    required this.addedAt,
  });

  final String id;
  final String title;
  final String author;
  final String? imageUrl;
  final String downloadUrl;
  final String addedAt;

  @override
  bool operator ==(Object other) =>
      other is TouchControlEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
