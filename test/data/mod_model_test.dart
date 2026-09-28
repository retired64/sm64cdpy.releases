import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/data/datasource/remote_json_datasource.dart';
import 'package:sm64cdpy/data/models/mod_model.dart';
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
    expect(entity.versions.single.id, '100');
    expect(entity.versions.single.files.single.id, '900');
    expect(entity.versions.single.isResolved, isTrue);
    expect(entity.versions.single.files.single.resolutionSource, 'test');
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
