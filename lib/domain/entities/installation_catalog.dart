import 'install_identity.dart';
import 'installation_action.dart';
import 'installation_library.dart';

/// Canonical downloadable artifact currently exposed by a catalog section.
class InstallationCatalogTarget {
  const InstallationCatalogTarget({
    required this.identity,
    required this.title,
    required this.route,
  });

  final InstallIdentity identity;
  final String title;
  final String route;
}

class InstallationUpdateCandidate {
  const InstallationUpdateCandidate({
    required this.installed,
    required this.available,
  });

  final InstallationRecord installed;
  final InstallationCatalogTarget available;
}

/// Matches current native receipts to canonical catalog artifacts without
/// guessing between multi-file variants.
class InstallationCatalogMatcher {
  const InstallationCatalogMatcher._();

  static List<InstallationUpdateCandidate> updates({
    required InstallationLibrarySnapshot library,
    required Iterable<InstallationCatalogTarget> targets,
  }) {
    final targetsByContent = <String, List<InstallationCatalogTarget>>{};
    for (final target in targets) {
      targetsByContent
          .putIfAbsent(target.identity.contentKey, () => [])
          .add(target);
    }

    final receiptsByContent = <String, List<InstallationRecord>>{};
    for (final receipt in library.receipts) {
      receiptsByContent.putIfAbsent(receipt.contentKey, () => []).add(receipt);
    }

    final updates = <InstallationUpdateCandidate>[];
    for (final entry in receiptsByContent.entries) {
      final candidates = targetsByContent[entry.key];
      if (candidates == null || candidates.isEmpty) continue;
      for (final installed in entry.value) {
        final available = _unambiguousTarget(installed, candidates);
        if (available == null ||
            !InstallationVersionPolicy.isReliableUpgrade(
              installed.versionLabel,
              available.identity.versionLabel,
            )) {
          continue;
        }
        final verification = library.verifications[installed.artifactKey];
        if (verification?.status != InstallationVerificationStatus.present) {
          continue;
        }
        updates.add(
          InstallationUpdateCandidate(
            installed: installed,
            available: available,
          ),
        );
      }
    }
    updates.sort(
      (left, right) =>
          right.installed.installedAt.compareTo(left.installed.installedAt),
    );
    return List.unmodifiable(updates);
  }

  static InstallationCatalogTarget? _unambiguousTarget(
    InstallationRecord installed,
    List<InstallationCatalogTarget> candidates,
  ) {
    for (final candidate in candidates) {
      if (candidate.identity.artifactKey == installed.artifactKey) {
        return candidate;
      }
    }
    if (candidates.length == 1) return candidates.single;

    final filename = installed.filename?.trim().toLowerCase();
    if (filename == null || filename.isEmpty) return null;
    final matches = candidates
        .where(
          (candidate) =>
              candidate.identity.fileName?.trim().toLowerCase() == filename,
        )
        .toList(growable: false);
    return matches.length == 1 ? matches.single : null;
  }
}
