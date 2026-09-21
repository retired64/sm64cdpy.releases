import 'mod_entity.dart';

/// A downloadable file together with the stable indexes used by the
/// download/install operation key.
class ResolvedModFile {
  const ResolvedModFile({
    required this.versionIndex,
    required this.fileIndex,
    required this.file,
  });

  final int versionIndex;
  final int fileIndex;
  final ModFileEntity file;

  String get operationFileKey => 'version-$versionIndex-file-$fileIndex';
}

/// The canonical current release shown by both the detail screen and overlay.
class ResolvedModVersion {
  const ResolvedModVersion({
    required this.versionIndex,
    required this.version,
    required this.files,
  });

  final int versionIndex;
  final ModVersionEntity version;
  final List<ResolvedModFile> files;
}

/// Selects the newest downloadable release without relying on API ordering.
///
/// Release date wins when it can be parsed. Version-number components are the
/// fallback, and source order is the final stable tie-breaker. Versions with no
/// usable download are ignored.
ResolvedModVersion? resolveLatestDownloadableVersion(
  List<ModVersionEntity> versions,
) {
  ResolvedModVersion? best;

  for (final entry in versions.asMap().entries) {
    final files = entry.value.files
        .asMap()
        .entries
        .where((file) => file.value.downloadUrl.trim().isNotEmpty)
        .map(
          (file) => ResolvedModFile(
            versionIndex: entry.key,
            fileIndex: file.key,
            file: file.value,
          ),
        )
        .toList(growable: false);
    if (files.isEmpty) continue;

    final candidate = ResolvedModVersion(
      versionIndex: entry.key,
      version: entry.value,
      files: files,
    );
    if (best == null || _compareVersions(candidate, best) > 0) {
      best = candidate;
    }
  }

  return best;
}

int _compareVersions(ResolvedModVersion left, ResolvedModVersion right) {
  final leftDate = DateTime.tryParse(left.version.releaseDate.trim());
  final rightDate = DateTime.tryParse(right.version.releaseDate.trim());
  if (leftDate != null && rightDate != null) {
    final comparison = leftDate.compareTo(rightDate);
    if (comparison != 0) return comparison;
  } else if (leftDate != null) {
    return 1;
  } else if (rightDate != null) {
    return -1;
  }

  final comparison = _compareVersionLabels(
    left.version.version,
    right.version.version,
  );
  if (comparison != 0) return comparison;

  // Earlier source entries win ties because catalogues normally list newest
  // first, while the checks above protect us when they do not.
  return right.versionIndex.compareTo(left.versionIndex);
}

int _compareVersionLabels(String left, String right) {
  final leftParts = RegExp(
    r'\d+',
  ).allMatches(left).map((m) => int.parse(m[0]!));
  final rightParts = RegExp(
    r'\d+',
  ).allMatches(right).map((m) => int.parse(m[0]!));
  final leftValues = leftParts.toList(growable: false);
  final rightValues = rightParts.toList(growable: false);
  final length = leftValues.length > rightValues.length
      ? leftValues.length
      : rightValues.length;

  for (var i = 0; i < length; i++) {
    final leftValue = i < leftValues.length ? leftValues[i] : 0;
    final rightValue = i < rightValues.length ? rightValues[i] : 0;
    if (leftValue != rightValue) return leftValue.compareTo(rightValue);
  }
  return 0;
}
