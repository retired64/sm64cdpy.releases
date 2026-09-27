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

  Map<String, dynamic> toMap() => {
    'schemaVersion': 1,
    'contentKey': contentKey,
    'artifactKey': artifactKey,
    'operationKey': operationKey,
    'section': section,
    'contentId': contentId,
    'artifactId': artifactId,
    'destination': destination,
    'installedAt': installedAt.toUtc().toIso8601String(),
    'installWorkerId': installWorkerId,
    'eventKind': eventKind,
    'fileCount': fileCount,
    'sentinels': sentinels.map((sentinel) => sentinel.toMap()).toList(),
    'source': source,
    'displaySnapshot': {
      'title': title,
      if (versionLabel != null) 'versionLabel': versionLabel,
      if (filename != null) 'filename': filename,
    },
    'packageShape': packageShape.wireValue,
  };
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

  Map<String, dynamic> toMap() => {'file': file, 'reason': reason};
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

  Map<String, dynamic> toMap() => {
    'artifactKey': artifactKey,
    'status': status.name,
    'verifiedAt': verifiedAt.toUtc().toIso8601String(),
    if (missingPath != null) 'missingPath': missingPath,
  };
}

enum InstallationDiscoveryConfidence {
  exact,
  probable,
  unlinked;

  static InstallationDiscoveryConfidence parse(String value) =>
      values.firstWhere(
        (confidence) => confidence.name == value,
        orElse: () => throw FormatException(
          'Unknown installation discovery confidence: $value',
        ),
      );
}

/// Content observed in a selected SAF folder without a durable installation
/// receipt. This is discovery evidence only and never a catalog identity.
class DiscoveredInstallation {
  const DiscoveredInstallation({
    required this.discoveryKey,
    required this.destination,
    required this.entryPath,
    required this.displayName,
    required this.sourceType,
    required this.confidence,
    required this.detectedAt,
    this.versionLabel,
    this.category,
    this.author,
  });

  factory DiscoveredInstallation.fromMap(Map<dynamic, dynamic> map) {
    if (map['schemaVersion'] != 1) {
      throw const FormatException('Unsupported discovery schema');
    }
    String requiredString(String key) {
      final value = map[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing discovery field: $key');
      }
      return value;
    }

    String? optionalString(String key) {
      final value = map[key];
      if (value == null) return null;
      if (value is! String || value.trim().isEmpty) return null;
      return value.trim();
    }

    final destination = requiredString('destination');
    if (destination != 'mods' && destination != 'dynos') {
      throw const FormatException('Invalid discovery destination');
    }
    return DiscoveredInstallation(
      discoveryKey: requiredString('discoveryKey'),
      destination: destination,
      entryPath: requiredString('entryPath'),
      displayName: requiredString('displayName'),
      versionLabel: optionalString('versionLabel'),
      category: optionalString('category'),
      author: optionalString('author'),
      sourceType: requiredString('sourceType'),
      confidence: InstallationDiscoveryConfidence.parse(
        requiredString('confidence'),
      ),
      detectedAt: DateTime.parse(requiredString('detectedAt')).toUtc(),
    );
  }

  final String discoveryKey;
  final String destination;
  final String entryPath;
  final String displayName;
  final String? versionLabel;
  final String? category;
  final String? author;
  final String sourceType;
  final InstallationDiscoveryConfidence confidence;
  final DateTime detectedAt;
}

class InstallationLibrarySnapshot {
  const InstallationLibrarySnapshot({
    required this.receipts,
    required this.history,
    required this.issues,
    this.verifications = const {},
    this.discoveries = const [],
    this.discoveryScannedAt,
    this.discoveryTruncated = false,
  });

  final List<InstallationRecord> receipts;
  final List<InstallationRecord> history;
  final List<InstallationLibraryIssue> issues;
  final Map<String, InstallationVerification> verifications;
  final List<DiscoveredInstallation> discoveries;
  final DateTime? discoveryScannedAt;
  final bool discoveryTruncated;

  bool get isPartial => issues.isNotEmpty;

  /// Compact, versioned projection sent to the independent overlay engine.
  ///
  /// History is intentionally omitted: the overlay only needs the latest
  /// receipt per artifact and its SAF verification to run the canonical
  /// action selector. Native receipts and SAF remain the authorities.
  Map<String, dynamic> toOverlayMap() => {
    'schemaVersion': 1,
    'receipts': receipts.map((record) => record.toMap()).toList(),
    'issues': issues.map((issue) => issue.toMap()).toList(),
    'verificationResults': verifications.values
        .map((verification) => verification.toMap())
        .toList(),
  };

  factory InstallationLibrarySnapshot.fromOverlayMap(
    Map<dynamic, dynamic> map,
  ) {
    if (map['schemaVersion'] != 1) {
      throw const FormatException('Unsupported overlay library schema');
    }

    final receipts = <InstallationRecord>[];
    for (final value in map['receipts'] as List? ?? const []) {
      if (value is! Map) {
        throw const FormatException('Overlay receipt is not a map');
      }
      receipts.add(InstallationRecord.fromMap(value));
    }

    final issues = <InstallationLibraryIssue>[];
    for (final value in map['issues'] as List? ?? const []) {
      if (value is! Map) {
        throw const FormatException('Overlay issue is not a map');
      }
      issues.add(InstallationLibraryIssue.fromMap(value));
    }

    final verifications = <String, InstallationVerification>{};
    for (final value in map['verificationResults'] as List? ?? const []) {
      if (value is! Map) {
        throw const FormatException('Overlay verification is not a map');
      }
      final verification = InstallationVerification.fromMap(
        value,
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
      verifications[verification.artifactKey] = verification;
    }

    return InstallationLibrarySnapshot(
      receipts: List.unmodifiable(receipts),
      history: const [],
      issues: List.unmodifiable(issues),
      verifications: Map.unmodifiable(verifications),
      discoveries: const [],
    );
  }
}
