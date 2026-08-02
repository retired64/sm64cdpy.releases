class Render96Entity {
  const Render96Entity({
    required this.id,
    required this.name,
    required this.category,
    required this.repo,
    this.youtube,
    this.notes,
    this.description,
    required this.downloadUrl,
    this.version,
    this.author,
    this.imageUrl,
    required this.installDestination,
  });

  final String id;
  final String name;
  final String category;
  final String repo;
  final String? youtube;
  final String? notes;
  final String? description;
  final String downloadUrl;
  final String? version;
  final String? author;
  final String? imageUrl;
  final String installDestination;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Render96Entity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
