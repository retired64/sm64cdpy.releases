import '../../domain/entities/mod_entity.dart';

/// Data-layer model: knows how to deserialise from the scraper JSON.
class ModModel {
  const ModModel({
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
  final String description;
  final List<String> tags;
  final bool isFeatured;
  final String? imageUrl;
  final List<String> descriptionImages;
  final int downloads;
  final int views;
  final double? rating;
  final int ratingCount;
  final int reviewCount;
  final int updateCount;
  final String? firstRelease;
  final String? lastUpdate;
  final List<String> downloadUrls;
  final List<ModUpdateModel> updates;
  final String extractedAt;
  final List<ModVersionModel> versions;
  final String slug;
  final String authorUrl;
  final String category;
  final String threadUrl;
  final String downloadDomainHint;

  factory ModModel.fromJson(String id, Map<String, dynamic> json) {
    return ModModel(
      id: id,
      url: json['url'] as String? ?? json['mod_page_url'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? 'N/A',
      version: json['version'] as String? ?? 'N/A',
      author: json['author'] as String? ?? 'N/A',
      description: json['description'] as String? ?? '',
      tags: _strings(json['tags']),
      isFeatured:
          json['is_featured'] == true ||
          json['is_featured'] == 1 ||
          json['featured'] == true ||
          json['featured'] == 1,
      imageUrl: json['image_url'] as String? ?? json['icon_url'] as String?,
      descriptionImages: _strings(json['description_images']),
      downloads: (json['downloads'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      rating:
          (json['rating'] as num?)?.toDouble() ??
          (json['rating_value'] as num?)?.toDouble(),
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      reviewCount:
          (json['review_count'] as num?)?.toInt() ??
          (json['reviews_count'] as num?)?.toInt() ??
          0,
      updateCount:
          (json['update_count'] as num?)?.toInt() ??
          (json['updates_count'] as num?)?.toInt() ??
          0,
      firstRelease: json['first_release'] as String?,
      lastUpdate: json['last_update'] as String?,
      downloadUrls: _extractDownloadUrls(json),
      updates: _updates(json['updates']),
      extractedAt: json['extracted_at'] as String? ?? '',
      versions: _extractVersions(json['versions']),
      slug: json['slug'] as String? ?? '',
      authorUrl: json['author_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
      threadUrl: json['thread_url'] as String? ?? '',
      downloadDomainHint: json['download_domain_hint'] as String? ?? '',
    );
  }

  static List<String> _strings(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<String> _extractDownloadUrls(Map<String, dynamic> json) {
    if (json['download_urls'] != null) {
      return _fixDownloadUrls(_strings(json['download_urls']));
    }
    final versions = json['versions'];
    if (versions is List) {
      final urls = <String>{};
      for (final v in versions) {
        if (v is Map<String, dynamic>) {
          final files = v['files'];
          if (files is List) {
            for (final f in files) {
              if (f is Map<String, dynamic> && f['download_url'] != null) {
                urls.add(f['download_url'].toString());
              }
            }
          }
        }
      }
      return _fixDownloadUrls(urls.toList());
    }
    return [];
  }

  static List<String> _fixDownloadUrls(List<String> urls) {
    return urls.map((url) {
      if (url.endsWith('/') && !url.contains('/download')) {
        return '${url}download';
      }
      return url;
    }).toList();
  }

  static List<ModUpdateModel> _updates(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(ModUpdateModel.fromJson)
          .toList();
    }
    return [];
  }

  static List<ModVersionModel> _extractVersions(dynamic value) {
    if (value is! List) return [];
    return value.whereType<Map<String, dynamic>>().map((v) {
      final pageUrl = v['version_page_url'] as String? ?? '';
      final version = v['version'] as String? ?? '';
      final releaseDate = v['release_date'] as String? ?? '';
      return ModVersionModel(
        id: _versionId(v['version_id'], pageUrl, version, releaseDate),
        version: version,
        releaseDate: releaseDate,
        downloads: _intValue(v['downloads']),
        files: _extractFiles(v['files']),
        rating: _doubleValue(v['rating']),
        ratingCount: _intValue(v['rating_count']),
        pageUrl: pageUrl,
        primaryDownloadUrl: v['download_url'] as String? ?? '',
        primaryFilename: v['filename'] as String? ?? '',
        resolutionSource: v['resolution_source'] as String? ?? '',
        isResolved: v['resolved'] == true || v['resolved'] == 1,
        folderUrl: v['folder_url'] as String? ?? '',
        failureReason: v['reason'] as String? ?? '',
      );
    }).toList();
  }

  static List<ModFileModel> _extractFiles(dynamic value) {
    if (value is! List) return [];
    return value.whereType<Map<String, dynamic>>().map((f) {
      final filename = f['filename'] as String? ?? '';
      final url = f['download_url'] as String? ?? '';
      return ModFileModel(
        id: _fileId(f['file_id'], f['source_url'], url, filename),
        filename: filename,
        downloadUrl: url,
        sourceUrl: f['source_url'] as String? ?? '',
        resolutionSource: f['resolution_source'] as String? ?? '',
      );
    }).toList();
  }

  static int _intValue(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(
          value?.toString().replaceAll(RegExp(r'[^0-9-]'), '') ?? '',
        ) ??
        0;
  }

  static double? _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(
      RegExp(
            r'-?\d+(?:\.\d+)?',
          ).firstMatch(value?.toString() ?? '')?.group(0) ??
          '',
    );
  }

  static String _versionId(
    dynamic explicit,
    String pageUrl,
    String version,
    String releaseDate,
  ) {
    final supplied = explicit?.toString().trim() ?? '';
    if (supplied.isNotEmpty) return supplied;
    final match = RegExp(r'/version/(\d+)').firstMatch(pageUrl);
    if (match != null) return 'source:${match.group(1)}';
    return 'legacy:${Uri.encodeComponent('$version|$releaseDate')}';
  }

  static String _fileId(
    dynamic explicit,
    dynamic sourceUrlValue,
    String downloadUrl,
    String filename,
  ) {
    final supplied = explicit?.toString().trim() ?? '';
    if (supplied.isNotEmpty) return supplied;
    final sourceUrl = sourceUrlValue?.toString().trim() ?? '';
    final candidate = sourceUrl.isNotEmpty ? sourceUrl : downloadUrl;
    final uri = Uri.tryParse(candidate);
    final sourceFileId = uri?.queryParameters['file']?.trim() ?? '';
    if (sourceFileId.isNotEmpty) return 'source:$sourceFileId';
    final stableFallback = filename.trim().isNotEmpty
        ? filename.trim().toLowerCase()
        : candidate;
    return 'legacy:${Uri.encodeComponent(stableFallback)}';
  }

  ModEntity toEntity() => ModEntity(
    id: id,
    url: url,
    title: title,
    version: version,
    author: author,
    description: description,
    tags: tags,
    isFeatured: isFeatured,
    imageUrl: imageUrl,
    descriptionImages: descriptionImages,
    downloads: downloads,
    views: views,
    rating: rating,
    ratingCount: ratingCount,
    reviewCount: reviewCount,
    updateCount: updateCount,
    firstRelease: firstRelease,
    lastUpdate: lastUpdate,
    downloadUrls: downloadUrls,
    updates: updates.map((u) => u.toEntity()).toList(),
    extractedAt: extractedAt,
    versions: versions.map((v) => v.toEntity()).toList(),
    slug: slug,
    authorUrl: authorUrl,
    category: category,
    threadUrl: threadUrl,
    downloadDomainHint: downloadDomainHint,
  );
}

class ModUpdateModel {
  const ModUpdateModel({this.title, this.date, required this.changelog});

  final String? title;
  final String? date;
  final String changelog;

  factory ModUpdateModel.fromJson(Map<String, dynamic> json) => ModUpdateModel(
    title: json['title'] as String?,
    date: json['date'] as String?,
    changelog: json['changelog'] as String? ?? '',
  );

  ModUpdate toEntity() =>
      ModUpdate(title: title, date: date, changelog: changelog);
}

class ModVersionModel {
  const ModVersionModel({
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
  final List<ModFileModel> files;
  final double? rating;
  final int ratingCount;
  final String pageUrl;
  final String primaryDownloadUrl;
  final String primaryFilename;
  final String resolutionSource;
  final bool isResolved;
  final String folderUrl;
  final String failureReason;

  ModVersionEntity toEntity() => ModVersionEntity(
    id: id,
    version: version,
    releaseDate: releaseDate,
    downloads: downloads,
    files: files.map((f) => f.toEntity()).toList(),
    rating: rating,
    ratingCount: ratingCount,
    pageUrl: pageUrl,
    primaryDownloadUrl: primaryDownloadUrl,
    primaryFilename: primaryFilename,
    resolutionSource: resolutionSource,
    isResolved: isResolved,
    folderUrl: folderUrl,
    failureReason: failureReason,
  );
}

class ModFileModel {
  const ModFileModel({
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

  ModFileEntity toEntity() => ModFileEntity(
    id: id,
    filename: filename,
    downloadUrl: downloadUrl,
    sourceUrl: sourceUrl,
    resolutionSource: resolutionSource,
  );
}
