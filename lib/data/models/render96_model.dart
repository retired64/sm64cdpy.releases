import '../../domain/entities/render96_entity.dart';

class Render96Model {
  const Render96Model({
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

  factory Render96Model.fromJson(Map<String, dynamic> json) {
    return Render96Model(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'N/A',
      category: json['category'] as String? ?? 'N/A',
      repo: json['repo'] as String? ?? '',
      youtube: json['youtube'] as String?,
      notes: json['notes'] as String?,
      description: json['description'] as String?,
      downloadUrl: json['download_url'] as String? ?? '',
      version: json['version'] as String?,
      author: json['author'] as String?,
      imageUrl: json['image_url'] as String?,
      installDestination: json['install_destination'] as String? ?? 'mods',
    );
  }

  Render96Entity toEntity() => Render96Entity(
        id: id,
        name: name,
        category: category,
        repo: repo,
        youtube: youtube,
        notes: notes,
        description: description,
        downloadUrl: downloadUrl,
        version: version,
        author: author,
        imageUrl: imageUrl,
        installDestination: installDestination,
      );
}
