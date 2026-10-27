import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/data/datasource/remote_json_datasource.dart';
import 'package:sm64cdpy/data/models/mod_model.dart';
import 'package:sm64cdpy/domain/entities/mod_entity.dart';
import 'package:sm64cdpy/domain/entities/mod_version_resolver.dart';

void main() {
  test('bundled production catalog parses completely', () async {
    final raw = await File('assets/db/database_sm64coopdx.json').readAsString();
    final models = listOrMapJsonParser<ModModel>(
      raw,
      'mods',
      ModModel.fromJson,
    );

    expect(models, isNotEmpty);
    expect(models.map((model) => model.id).toSet(), hasLength(models.length));
    expect(
      models
          .expand((model) => model.versions)
          .every((version) => !version.isResolved || version.files.isNotEmpty),
      isTrue,
    );
  });

  Map<String, dynamic> version({
    required String id,
    required String label,
    required String fileId,
  }) => <String, dynamic>{
    'version_id': id,
    'version': label,
    'release_date': '2026-09-27',
    'resolved': true,
    'version_page_url': 'https://mods.sm64coopdx.com/version/$id/download',
    'files': <Map<String, dynamic>>[
      <String, dynamic>{
        'file_id': fileId,
        'filename': '$label.zip',
        'download_url': 'https://example.test/$label.zip',
        'source_url':
            'https://mods.sm64coopdx.com/version/$id/download?file=$fileId',
        'resolution_source': 'test',
        'display_name': 'Example package',
        'role': 'primary',
        'recommended': true,
        'requires_primary': false,
        'artifact_description': 'Complete main package.',
        'requested_url':
            'https://mods.sm64coopdx.com/version/$id/download?file=$fileId',
        'final_url': 'https://example.test/$label.zip',
        'size_bytes': 2048,
        'sha256': 'sha256:test',
        'version_consistency': 'match',
        'verification_status': 'metadata_only',
        'mirror_url': 'https://mods-cdn.sm64cdpy.org/mods/42/100/900/v2.zip',
        'mirror_status': 'available',
        'mirror_priority': 'fallback',
        'mirror_size_bytes': 2048,
      },
    ],
  };

  test('parses the complete v2 scraper contract', () {
    final model = ModModel.fromJson('42', <String, dynamic>{
      'id': 42,
      'slug': 'example',
      'mod_page_url': 'https://mods.sm64coopdx.com/mods/example.42/',
      'name': 'Example',
      'version': 'v2',
      'author': 'Author',
      'author_url': 'https://example.test/author',
      'category': 'Gameplay',
      'thread_url': 'https://example.test/thread',
      'download_domain_hint': 'MediaFire',
      'description_images': <String>[
        'https://mods.sm64coopdx.com/attachments/preview-png.1/',
      ],
      'description_videos': <Map<String, dynamic>>[
        <String, dynamic>{
          'provider': 'youtube',
          'video_id': 'qTkWn9PrSSA',
          'url': 'https://www.youtube.com/watch?v=qTkWn9PrSSA',
          'thumbnail_url': 'https://i.ytimg.com/vi/qTkWn9PrSSA/hqdefault.jpg',
        },
      ],
      'versions': <Map<String, dynamic>>[
        version(id: '100', label: 'v2', fileId: '900'),
      ],
    });

    final entity = model.toEntity();
    expect(entity.slug, 'example');
    expect(entity.authorUrl, 'https://example.test/author');
    expect(entity.category, 'Gameplay');
    expect(entity.threadUrl, 'https://example.test/thread');
    expect(entity.downloadDomainHint, 'MediaFire');
    expect(entity.descriptionImages, <String>[
      'https://mods.sm64coopdx.com/attachments/preview-png.1/',
    ]);
    expect(entity.descriptionVideos, hasLength(1));
    expect(entity.descriptionVideos.single.isYouTube, isTrue);
    expect(
      entity.descriptionVideos.single.url,
      'https://www.youtube.com/watch?v=qTkWn9PrSSA',
    );
    expect(entity.versions.single.id, '100');
    expect(entity.versions.single.files.single.id, '900');
    expect(entity.versions.single.isResolved, isTrue);
    expect(entity.versions.single.files.single.resolutionSource, 'test');
    final artifact = entity.versions.single.files.single;
    expect(artifact.displayName, 'Example package');
    expect(artifact.role, 'primary');
    expect(artifact.recommended, isTrue);
    expect(artifact.requiresPrimary, isFalse);
    expect(artifact.sizeBytes, 2048);
    expect(artifact.versionConsistency, 'match');
    expect(artifact.hasAvailableMirror, isTrue);
    expect(
      artifact.mirrorUrl,
      'https://mods-cdn.sm64cdpy.org/mods/42/100/900/v2.zip',
    );
  });

  test('old and incomplete mirror metadata stays compatible', () {
    final old = ModModel.fromJson('old', <String, dynamic>{
      'name': 'Old',
      'versions': <Map<String, dynamic>>[
        <String, dynamic>{
          'version_id': '1',
          'resolved': true,
          'files': <Map<String, dynamic>>[
            <String, dynamic>{
              'file_id': '1',
              'filename': 'old.zip',
              'download_url': 'https://example.test/old.zip',
            },
          ],
        },
      ],
    }).toEntity().versions.single.files.single;
    expect(old.hasAvailableMirror, isFalse);

    final unavailable = ModFileEntity(
      id: '2',
      filename: 'mod.zip',
      downloadUrl: 'https://example.test/mod.zip',
      mirrorUrl: 'https://mods-cdn.sm64cdpy.org/mod.zip',
      mirrorStatus: 'unavailable',
      mirrorPriority: 'fallback',
      mirrorSizeBytes: 100,
    );
    expect(unavailable.hasAvailableMirror, isFalse);
  });

  test('description translations are optional and keep the English source', () {
    final oldModel = ModModel.fromJson('old', <String, dynamic>{
      'name': 'Old catalog',
      'description': 'English only',
    });
    expect(oldModel.descriptionTranslations, isEmpty);
    expect(oldModel.description, 'English only');
    expect(oldModel.toEntity().descriptionTranslations, isEmpty);

    final enriched = ModModel.fromJson('new', <String, dynamic>{
      'name': 'Enriched catalog',
      'description': 'Original English description',
      'description_source_hash': 'sha256:abc',
      'description_translations': <String, dynamic>{
        'es': 'Descripción en español',
        'pt_BR': 'Descrição em português',
        'fr': 'Description française',
        'it': 'Descrizione italiana',
      },
      'description_images': <String>['https://example.test/image.png'],
      'description_videos': <Map<String, dynamic>>[
        <String, dynamic>{
          'provider': 'youtube',
          'video_id': 'abc',
          'url': 'https://www.youtube.com/watch?v=abc',
        },
      ],
    });
    expect(enriched.description, 'Original English description');
    expect(enriched.descriptionTranslations, <String, String>{
      'es': 'Descripción en español',
      'pt_BR': 'Descrição em português',
      'fr': 'Description française',
      'it': 'Descrizione italiana',
    });

    final entity = enriched.toEntity();
    expect(entity.description, 'Original English description');
    expect(entity.descriptionTranslations['es'], 'Descripción en español');
    expect(entity.descriptionImages, <String>[
      'https://example.test/image.png',
    ]);
    expect(entity.descriptionVideos.single.videoId, 'abc');
    expect(
      () => entity.descriptionTranslations['es'] = 'mutated',
      throwsUnsupportedError,
    );
  });

  test('invalid translation entries are ignored without losing valid ones', () {
    final model = ModModel.fromJson('mixed', <String, dynamic>{
      'name': 'Mixed',
      'description': 'Source',
      'description_translations': <dynamic, dynamic>{
        'es': 'Válida',
        'pt_BR': 42,
        'fr': null,
        'it': <String>['no'],
        7: 'clave no textual',
        '': 'clave vacía',
      },
    });
    expect(model.descriptionTranslations, <String, String>{'es': 'Válida'});
    expect(model.description, 'Source');

    final listValue = ModModel.fromJson('list', <String, dynamic>{
      'name': 'List',
      'description_translations': <String>['es'],
    });
    final stringValue = ModModel.fromJson('string', <String, dynamic>{
      'name': 'String',
      'description_translations': 'es',
    });
    expect(listValue.descriptionTranslations, isEmpty);
    expect(stringValue.descriptionTranslations, isEmpty);
  });

  test('artifact identity remains stable when a newer version is inserted', () {
    final oldModel = ModModel.fromJson('42', <String, dynamic>{
      'name': 'Example',
      'versions': <Map<String, dynamic>>[
        version(id: '100', label: 'v2', fileId: '900'),
      ],
    }).toEntity();
    final refreshedModel = ModModel.fromJson('42', <String, dynamic>{
      'name': 'Example',
      'versions': <Map<String, dynamic>>[
        version(id: '101', label: 'v3', fileId: '901'),
        version(id: '100', label: 'v2', fileId: '900'),
      ],
    }).toEntity();

    final before = resolveLatestDownloadableVersion(
      oldModel.versions,
    )!.files.single;
    final after = resolveLatestDownloadableVersion(
      refreshedModel.versions.skip(1).toList(growable: false),
    )!.files.single;

    expect(after.operationVersionKey, before.operationVersionKey);
    expect(after.operationFileKey, before.operationFileKey);
  });
}
