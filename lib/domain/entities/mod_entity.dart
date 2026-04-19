/// Pure domain entity — no Flutter / JSON imports.
class ModEntity {
  const ModEntity({
    required this.id,
    required this.url,
    required this.title,
    required this.version,
    required this.author,
    required this.description,
    required this.tags,
    required this.isFeatured,
    this.imageUrl,
    required this.descriptionImages,
    required this.downloads,
    required this.views,
    this.rating,
    required this.ratingCount,
    required this.reviewCount,
    required this.updateCount,
    this.firstRelease,
    this.lastUpdate,
    required this.downloadUrls,
    required this.updates,
    required this.extractedAt,
  });

  final String   id;
  final String   url;
  final String   title;
  final String   version;
  final String   author;
  final String   description;
  final List<String> tags;
  final bool     isFeatured;
  final String?  imageUrl;
  final List<String> descriptionImages;
  final int      downloads;
  final int      views;
  final double?  rating;
  final int      ratingCount;
  final int      reviewCount;
  final int      updateCount;
  final String?  firstRelease;
  final String?  lastUpdate;
  final List<String>      downloadUrls;
  final List<ModUpdate>   updates;
  final String   extractedAt;

  @override
  bool operator ==(Object other) => other is ModEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ModUpdate {
  const ModUpdate({
    this.title,
    this.date,
    required this.changelog,
  });

  final String? title;
  final String? date;
  final String  changelog;
}
