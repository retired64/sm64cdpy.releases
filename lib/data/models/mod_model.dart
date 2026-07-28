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
  final List<String>         downloadUrls;
  final List<ModUpdateModel> updates;
  final String   extractedAt;
  final List<ModVersionModel> versions;

  factory ModModel.fromJson(String id, Map<String, dynamic> json) {
    return ModModel(
      id:                id,
      url:               json['url'] as String? ?? json['mod_page_url'] as String? ?? '',
      title:             json['title'] as String? ?? json['name'] as String? ?? 'N/A',
      version:           json['version'] as String? ?? 'N/A',
      author:            json['author'] as String? ?? 'N/A',
      description:       json['description'] as String? ?? '',
      tags:              _strings(json['tags']),
      isFeatured:        json['is_featured'] == true || json['is_featured'] == 1 ||
                         json['featured'] == true || json['featured'] == 1,
      imageUrl:          json['image_url'] as String? ?? json['icon_url'] as String?,
      descriptionImages: _strings(json['description_images']),
      downloads:         (json['downloads'] as num?)?.toInt() ?? 0,
      views:             (json['views'] as num?)?.toInt() ?? 0,
      rating:            (json['rating'] as num?)?.toDouble() ??
                         (json['rating_value'] as num?)?.toDouble(),
      ratingCount:       (json['rating_count'] as num?)?.toInt() ?? 0,
      reviewCount:       (json['review_count'] as num?)?.toInt() ??
                         (json['reviews_count'] as num?)?.toInt() ?? 0,
      updateCount:       (json['update_count'] as num?)?.toInt() ??
                         (json['updates_count'] as num?)?.toInt() ?? 0,
      firstRelease:      json['first_release'] as String?,
      lastUpdate:        json['last_update'] as String?,
      downloadUrls:      _extractDownloadUrls(json),
      updates:           _updates(json['updates']),
      extractedAt:       json['extracted_at'] as String? ?? '',
      versions:          _extractVersions(json['versions']),
    );
  }

  static List<String> _strings(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static List<String> _extractDownloadUrls(Map<String, dynamic> json) {
    if (json['download_urls'] != null) return _fixDownloadUrls(_strings(json['download_urls']));
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
    return value
        .whereType<Map<String, dynamic>>()
        .map((v) => ModVersionModel(
              version: v['version'] as String? ?? '',
              releaseDate: v['release_date'] as String? ?? '',
              downloads: (v['downloads'] as num?)?.toInt() ?? 0,
              files: _extractFiles(v['files']),
            ))
        .toList();
  }

  static List<ModFileModel> _extractFiles(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((f) => ModFileModel(
              filename: f['filename'] as String? ?? '',
              downloadUrl: f['download_url'] as String? ?? '',
            ))
        .toList();
  }

  ModEntity toEntity() => ModEntity(
        id:                id,
        url:               url,
        title:             title,
        version:           version,
        author:            author,
        description:       description,
        tags:              tags,
        isFeatured:        isFeatured,
        imageUrl:          imageUrl,
        descriptionImages: descriptionImages,
        downloads:         downloads,
        views:             views,
        rating:            rating,
        ratingCount:       ratingCount,
        reviewCount:       reviewCount,
        updateCount:       updateCount,
        firstRelease:      firstRelease,
        lastUpdate:        lastUpdate,
        downloadUrls:      downloadUrls,
        updates:           updates.map((u) => u.toEntity()).toList(),
        extractedAt:       extractedAt,
        versions:          versions.map((v) => v.toEntity()).toList(),
      );
}

class ModUpdateModel {
  const ModUpdateModel({this.title, this.date, required this.changelog});

  final String? title;
  final String? date;
  final String  changelog;

  factory ModUpdateModel.fromJson(Map<String, dynamic> json) =>
      ModUpdateModel(
        title:     json['title'] as String?,
        date:      json['date'] as String?,
        changelog: json['changelog'] as String? ?? '',
      );

  ModUpdate toEntity() => ModUpdate(title: title, date: date, changelog: changelog);
}

class ModVersionModel {
  const ModVersionModel({
    required this.version,
    required this.releaseDate,
    required this.downloads,
    required this.files,
  });

  final String version;
  final String releaseDate;
  final int downloads;
  final List<ModFileModel> files;

  ModVersionEntity toEntity() => ModVersionEntity(
        version: version,
        releaseDate: releaseDate,
        downloads: downloads,
        files: files.map((f) => f.toEntity()).toList(),
      );
}

class ModFileModel {
  const ModFileModel({
    required this.filename,
    required this.downloadUrl,
  });

  final String filename;
  final String downloadUrl;

  ModFileEntity toEntity() => ModFileEntity(
        filename: filename,
        downloadUrl: downloadUrl,
      );
}
