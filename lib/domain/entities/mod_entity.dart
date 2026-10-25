/// Pure domain entity — no Flutter / JSON imports.
class ModEntity {
  const ModEntity({
    required this.id,
    required this.url,
    required this.title,
    required this.version,
    required this.author,
    required this.description,
    this.descriptionTranslations = const {},
    required this.tags,
    required this.isFeatured,
    this.imageUrl,
    required this.descriptionImages,
    this.descriptionVideos = const [],
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
    this.versions = const [],
    this.slug = '',
    this.authorUrl = '',
    this.category = '',
    this.threadUrl = '',
    this.downloadDomainHint = '',
  });

  final String id;
  final String url;
  final String title;
  final String version;
  final String author;

  /// Original English description. Translated text is only read from
  /// [descriptionTranslations] for display.
  final String description;
  final Map<String, String> descriptionTranslations;
  final List<String> tags;
  final bool isFeatured;
  final String? imageUrl;
  final List<String> descriptionImages;
  final List<ModVideoEntity> descriptionVideos;
  final int downloads;
  final int views;
  final double? rating;
  final int ratingCount;
  final int reviewCount;
  final int updateCount;
  final String? firstRelease;
  final String? lastUpdate;
  final List<String> downloadUrls;
  final List<ModUpdate> updates;
  final String extractedAt;
  final List<ModVersionEntity> versions;
  final String slug;
  final String authorUrl;
  final String category;
  final String threadUrl;
  final String downloadDomainHint;

  @override
  bool operator ==(Object other) => other is ModEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ModVideoEntity {
  const ModVideoEntity({
    required this.provider,
    required this.url,
    this.videoId = '',
    this.thumbnailUrl = '',
  });

  final String provider;
  final String url;
  final String videoId;
  final String thumbnailUrl;

  bool get isYouTube => provider == 'youtube' && videoId.isNotEmpty;
}

class ModUpdate {
  const ModUpdate({this.title, this.date, required this.changelog});

  final String? title;
  final String? date;
  final String changelog;
}

class ModVersionEntity {
  const ModVersionEntity({
    required this.id,
    required this.version,
    required this.releaseDate,
    required this.downloads,
    required this.files,
    this.rating,
    this.ratingCount = 0,
    this.pageUrl = '',
    this.primaryDownloadUrl = '',
    this.primaryFilename = '',
    this.resolutionSource = '',
    this.isResolved = false,
    this.folderUrl = '',
    this.failureReason = '',
  });

  final String id;
  final String version;
  final String releaseDate;
  final int downloads;
  final List<ModFileEntity> files;
  final double? rating;
  final int ratingCount;
  final String pageUrl;
  final String primaryDownloadUrl;
  final String primaryFilename;
  final String resolutionSource;
  final bool isResolved;
  final String folderUrl;
  final String failureReason;
}

class ModFileEntity {
  const ModFileEntity({
    required this.id,
    required this.filename,
    required this.downloadUrl,
    this.sourceUrl = '',
    this.resolutionSource = '',
  });

  final String id;
  final String filename;
  final String downloadUrl;
  final String sourceUrl;
  final String resolutionSource;
}
