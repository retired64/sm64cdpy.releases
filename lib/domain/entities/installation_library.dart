enum InstallationPackageShape {
  looseFile('loose_file'),
  singleRoot('single_root'),
  multipleRoots('multiple_roots'),
  rootFiles('root_files');

  const InstallationPackageShape(this.wireValue);
  final String wireValue;

  static InstallationPackageShape parse(String value) => values.firstWhere(
    (shape) => shape.wireValue == value,
    orElse: () => throw FormatException('Unknown package shape: $value'),
  );
}

class InstallationSentinel {
  const InstallationSentinel({required this.relativePath, this.kind = 'file'});

  factory InstallationSentinel.fromMap(Map<dynamic, dynamic> map) {
    final path = map['relativePath'];
    final kind = map['kind'];
    if (path is! String || path.isEmpty || kind != 'file') {
      throw const FormatException('Invalid installation sentinel');
    }
    return InstallationSentinel(relativePath: path, kind: kind as String);
  }

  final String relativePath;
  final String kind;

  Map<String, dynamic> toMap() => {'relativePath': relativePath, 'kind': kind};
}

class InstallationRecord {
  const InstallationRecord({
    required this.contentKey,
    required this.artifactKey,
    required this.operationKey,
    required this.section,
    required this.contentId,
    required this.artifactId,
    required this.destination,
    required this.installedAt,
    required this.installWorkerId,
    required this.eventKind,
    required this.fileCount,
    required this.sentinels,
    required this.source,
    required this.title,
    required this.packageShape,
    this.versionLabel,
    this.filename,
  });

  factory InstallationRecord.fromMap(Map<dynamic, dynamic> map) {
    if (map['schemaVersion'] != 1) {
      throw const FormatException('Unsupported installation receipt schema');
    }
    String requiredString(String key) {
      final value = map[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing receipt field: $key');
      }
      return value;
    }

    final display = map['displaySnapshot'];
    final sentinelValues = map['sentinels'];
    if (display is! Map || sentinelValues is! List) {
      throw const FormatException('Invalid installation receipt payload');
    }
    final installedAt = DateTime.parse(requiredString('installedAt')).toUtc();
    final fileCount = map['fileCount'];
    if (fileCount is! int || fileCount <= 0) {
      throw const FormatException('Invalid receipt file count');
    }
    final sentinels = sentinelValues
        .map((value) => InstallationSentinel.fromMap(value as Map))
        .toList(growable: false);
    if (sentinels.isEmpty || sentinels.length > 32) {
      throw const FormatException('Invalid receipt sentinel count');
    }
    return InstallationRecord(
      contentKey: requiredString('contentKey'),
      artifactKey: requiredString('artifactKey'),
      operationKey: requiredString('operationKey'),
      section: requiredString('section'),
      contentId: requiredString('contentId'),
      artifactId: requiredString('artifactId'),
      destination: requiredString('destination'),
      installedAt: installedAt,
      installWorkerId: requiredString('installWorkerId'),
      eventKind: requiredString('eventKind'),
      fileCount: fileCount,
      sentinels: sentinels,
      source: requiredString('source'),
      title: _displayString(display, 'title', required: true)!,
      versionLabel: _displayString(display, 'versionLabel'),
      filename: _displayString(display, 'filename'),
      packageShape: InstallationPackageShape.parse(
        requiredString('packageShape'),
      ),
    );
  }

  static String? _displayString(
    Map<dynamic, dynamic> map,
    String key, {
    bool required = false,
  }) {
    final value = map[key];
    if (value == null && !required) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Invalid display field: $key');
    }
    return value;
  }

  final String contentKey;
  final String artifactKey;
  final String operationKey;
  final String section;
  final String contentId;
  final String artifactId;
  final String destination;
  final DateTime installedAt;
  final String installWorkerId;
  final String eventKind;
  final int fileCount;
  final List<InstallationSentinel> sentinels;
  final String source;
  final String title;
  final String? versionLabel;
  final String? filename;
  final InstallationPackageShape packageShape;
}

class InstallationLibraryIssue {
  const InstallationLibraryIssue({required this.file, required this.reason});

  factory InstallationLibraryIssue.fromMap(Map<dynamic, dynamic> map) =>
      InstallationLibraryIssue(
        file: map['file'] as String? ?? 'unknown',
        reason: map['reason'] as String? ?? 'Unknown library issue',
      );

  final String file;
  final String reason;
}

enum InstallationVerificationStatus {
  present,
  missing,
  unknown,
  folderNotSelected,
  permissionRevoked;

  static InstallationVerificationStatus parse(String value) =>
      values.firstWhere(
        (status) => status.name == value,
        orElse: () => throw FormatException(
          'Unknown installation verification status: $value',
        ),
      );
}

class InstallationVerification {
  const InstallationVerification({
    required this.artifactKey,
    required this.status,
    required this.verifiedAt,
    this.missingPath,
  });

  factory InstallationVerification.fromMap(
    Map<dynamic, dynamic> map,
    DateTime fallbackVerifiedAt,
  ) {
    final artifactKey = map['artifactKey'];
    final status = map['status'];
    final missingPath = map['missingPath'];
    final verifiedAtValue = map['verifiedAt'];
    if (artifactKey is! String || artifactKey.isEmpty || status is! String) {
      throw const FormatException('Invalid installation verification');
    }
    if (missingPath != null && missingPath is! String) {
      throw const FormatException('Invalid missing sentinel path');
    }
    return InstallationVerification(
      artifactKey: artifactKey,
      status: InstallationVerificationStatus.parse(status),
      verifiedAt: verifiedAtValue is String
          ? DateTime.parse(verifiedAtValue).toUtc()
          : fallbackVerifiedAt.toUtc(),
      missingPath: missingPath as String?,
    );
  }

  final String artifactKey;
  final InstallationVerificationStatus status;
  final DateTime verifiedAt;
  final String? missingPath;
}

class InstallationLibrarySnapshot {
  const InstallationLibrarySnapshot({
    required this.receipts,
    required this.history,
    required this.issues,
    this.verifications = const {},
  });

  final List<InstallationRecord> receipts;
  final List<InstallationRecord> history;
  final List<InstallationLibraryIssue> issues;
  final Map<String, InstallationVerification> verifications;

  bool get isPartial => issues.isNotEmpty;
}
