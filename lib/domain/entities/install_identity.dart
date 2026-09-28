import 'dart:convert';

import 'package:crypto/crypto.dart';

enum InstallSection {
  mods('mods'),
  vip('vip'),
  dynos('dynos'),
  touchControls('touch_controls'),
  omm('omm'),
  render96('render96');

  const InstallSection(this.wireName);

  final String wireName;

  static InstallSection? tryParse(String? value) {
    for (final section in values) {
      if (section.wireName == value) return section;
    }
    return null;
  }
}

/// Stable catalogue identity carried from Flutter to both WorkManager workers.
///
/// Display titles, filenames and URLs are snapshots only. They never determine
/// [contentKey] or [operationKey] after the identity has been constructed.
class InstallIdentity {
  const InstallIdentity._({
    required this.section,
    required this.contentId,
    required this.artifactId,
    required this.contentKey,
    required this.artifactKey,
    required this.operationKey,
    required this.versionLabel,
    required this.fileName,
  });

  static const schemaVersion = 1;
  static const contractVersion = 'v1';

  factory InstallIdentity.forCatalogArtifact({
    required InstallSection section,
    required Object contentId,
    required String downloadUrl,
    String? versionLabel,
    String? fileName,
    String? explicitVersionId,
    String? explicitFileId,
  }) {
    final normalizedContentId = contentId.toString().trim();
    if (normalizedContentId.isEmpty) {
      throw ArgumentError.value(contentId, 'contentId', 'Must not be empty');
    }

    final normalizedVersion = _nullableTrimmed(versionLabel);
    final normalizedFileName = _nullableTrimmed(fileName);
    final artifactId = _resolveArtifactId(
      downloadUrl: downloadUrl,
      versionLabel: normalizedVersion,
      fileName: normalizedFileName,
      explicitVersionId: explicitVersionId,
      explicitFileId: explicitFileId,
    );
    final contentKey = [
      contractVersion,
      section.wireName,
      _encodeComponent(normalizedContentId),
    ].join('|');
    final artifactKey = '$contentKey|${_encodeComponent(artifactId)}';

    return InstallIdentity._(
      section: section,
      contentId: normalizedContentId,
      artifactId: artifactId,
      contentKey: contentKey,
      artifactKey: artifactKey,
      operationKey: artifactKey,
      versionLabel: normalizedVersion,
      fileName: normalizedFileName,
    );
  }

  factory InstallIdentity.fromMap(Map<dynamic, dynamic> map) {
    final schema = map['identitySchemaVersion'];
    if (schema != schemaVersion) {
      throw FormatException('Unsupported install identity schema: $schema');
    }
    final section = InstallSection.tryParse(map['section'] as String?);
    final contentId = (map['contentId'] as String?)?.trim() ?? '';
    final artifactId = (map['artifactId'] as String?)?.trim() ?? '';
    final contentKey = map['contentKey'] as String? ?? '';
    final artifactKey = map['artifactKey'] as String? ?? '';
    final operationKey = map['operationKey'] as String? ?? '';
    if (section == null || contentId.isEmpty || artifactId.isEmpty) {
      throw const FormatException('Incomplete install identity');
    }

    final expectedContentKey = [
      contractVersion,
      section.wireName,
      _encodeComponent(contentId),
    ].join('|');
    final expectedArtifactKey =
        '$expectedContentKey|${_encodeComponent(artifactId)}';
    if (contentKey != expectedContentKey ||
        artifactKey != expectedArtifactKey ||
        operationKey != expectedArtifactKey) {
      throw const FormatException('Install identity keys do not match fields');
    }

    return InstallIdentity._(
      section: section,
      contentId: contentId,
      artifactId: artifactId,
      contentKey: contentKey,
      artifactKey: artifactKey,
      operationKey: operationKey,
      versionLabel: _nullableTrimmed(map['versionLabel'] as String?),
      fileName: _nullableTrimmed(map['identityFileName'] as String?),
    );
  }

  final InstallSection section;
  final String contentId;
  final String artifactId;
  final String contentKey;
  final String artifactKey;
  final String operationKey;
  final String? versionLabel;
  final String? fileName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstallIdentity &&
          artifactKey == other.artifactKey &&
          versionLabel == other.versionLabel &&
          fileName == other.fileName;

  @override
  int get hashCode => Object.hash(artifactKey, versionLabel, fileName);

  Map<String, Object> toMap() {
    final result = <String, Object>{
      'identitySchemaVersion': schemaVersion,
      'section': section.wireName,
      'contentId': contentId,
      'artifactId': artifactId,
      'contentKey': contentKey,
      'artifactKey': artifactKey,
      'operationKey': operationKey,
    };
    final version = versionLabel;
    final filename = fileName;
    if (version != null) result['versionLabel'] = version;
    if (filename != null) result['identityFileName'] = filename;
    return result;
  }

  static String _resolveArtifactId({
    required String downloadUrl,
    required String? versionLabel,
    required String? fileName,
    required String? explicitVersionId,
    required String? explicitFileId,
  }) {
    final versionId = _nullableTrimmed(explicitVersionId);
    final fileId = _nullableTrimmed(explicitFileId);
    if (fileId != null) {
      return versionId == null
          ? 'file:$fileId'
          : 'version:$versionId:file:$fileId';
    }

    final uri = Uri.tryParse(downloadUrl.trim());
    if (uri != null) {
      final segments = uri.pathSegments;
      final versionSegment = segments.indexOf('version');
      final sourceVersionId =
          versionSegment >= 0 &&
              versionSegment + 1 < segments.length &&
              RegExp(r'^\d+$').hasMatch(segments[versionSegment + 1])
          ? segments[versionSegment + 1]
          : null;
      if (sourceVersionId != null) {
        final sourceFileId = uri.queryParameters['file'];
        return sourceFileId == null || sourceFileId.trim().isEmpty
            ? 'version:$sourceVersionId:file:primary'
            : 'version:$sourceVersionId:file:${sourceFileId.trim()}';
      }
    }

    final canonical = jsonEncode(<String, String>{
      'downloadUrl': downloadUrl.trim(),
      'filename': fileName ?? '',
      'versionLabel': versionLabel ?? '',
    });
    return 'sha256:${sha256.convert(utf8.encode(canonical))}';
  }

  static String _encodeComponent(String value) {
    final bytes = utf8.encode(value);
    final output = StringBuffer();
    for (final byte in bytes) {
      final isUnreserved =
          (byte >= 0x41 && byte <= 0x5A) ||
          (byte >= 0x61 && byte <= 0x7A) ||
          (byte >= 0x30 && byte <= 0x39) ||
          byte == 0x2D ||
          byte == 0x2E ||
          byte == 0x5F ||
          byte == 0x7E;
      if (isUnreserved) {
        output.writeCharCode(byte);
      } else {
        output.write(
          '%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}',
        );
      }
    }
    return output.toString();
  }

  static String? _nullableTrimmed(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
