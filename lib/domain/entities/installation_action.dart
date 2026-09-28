import '../../services/background_install_service.dart';
import 'install_identity.dart';
import 'installation_library.dart';

enum InstallationPrimaryAction {
  checking,
  download,
  install,
  cancel,
  installed,
  update,
  reinstall,
  verify,
  selectFolder,
}

class InstallationActionState {
  const InstallationActionState({
    required this.primaryAction,
    required this.identity,
    this.operation,
    this.receipt,
    this.verification,
    this.progress,
    this.canReinstall = false,
  });

  final InstallationPrimaryAction primaryAction;
  final InstallIdentity identity;
  final BgInstallInfo? operation;
  final InstallationRecord? receipt;
  final InstallationVerification? verification;
  final double? progress;
  final bool canReinstall;

  bool get isOperationActive =>
      primaryAction == InstallationPrimaryAction.cancel;
}

/// The single policy for catalogue actions. Widgets render this result but do
/// not infer installation state from titles, download completion or local UI.
class InstallationActionSelector {
  const InstallationActionSelector._();

  static InstallationActionState select({
    required InstallIdentity identity,
    required BgInstallInfo? operation,
    required InstallationLibrarySnapshot? library,
    required bool libraryLoading,
  }) {
    if (_isActive(operation)) {
      return InstallationActionState(
        primaryAction: InstallationPrimaryAction.cancel,
        identity: identity,
        operation: operation,
        progress: _progress(operation!),
      );
    }

    if (libraryLoading && library == null) {
      return InstallationActionState(
        primaryAction: InstallationPrimaryAction.checking,
        identity: identity,
        operation: operation,
      );
    }

    final exactReceipt = library?.receipts
        .where((candidate) => candidate.artifactKey == identity.artifactKey)
        .firstOrNull;
    final receipt =
        exactReceipt ??
        library?.receipts
            .where((candidate) => candidate.contentKey == identity.contentKey)
            .fold<InstallationRecord?>(
              null,
              (latest, candidate) =>
                  latest == null ||
                      candidate.installedAt.isAfter(latest.installedAt)
                  ? candidate
                  : latest,
            );
    if (receipt == null) {
      return InstallationActionState(
        primaryAction: InstallationPrimaryAction.download,
        identity: identity,
        operation: operation,
      );
    }

    final verification = library?.verifications[receipt.artifactKey];
    final action = switch (verification?.status) {
      InstallationVerificationStatus.present =>
        InstallationVersionPolicy.isReliableUpgrade(
              receipt.versionLabel,
              identity.versionLabel,
            )
            ? InstallationPrimaryAction.update
            : exactReceipt != null
            ? InstallationPrimaryAction.installed
            : InstallationPrimaryAction.install,
      InstallationVerificationStatus.missing =>
        InstallationPrimaryAction.install,
      InstallationVerificationStatus.permissionRevoked =>
        InstallationPrimaryAction.selectFolder,
      InstallationVerificationStatus.folderNotSelected =>
        InstallationPrimaryAction.selectFolder,
      InstallationVerificationStatus.unknown ||
      null => InstallationPrimaryAction.verify,
    };
    return InstallationActionState(
      primaryAction: action,
      identity: identity,
      operation: operation,
      receipt: receipt,
      verification: verification,
      canReinstall: action == InstallationPrimaryAction.installed,
    );
  }

  static bool _isActive(BgInstallInfo? operation) =>
      switch (operation?.status) {
        BgInstallStatus.pending ||
        BgInstallStatus.downloading ||
        BgInstallStatus.installing => true,
        _ => false,
      };

  static double? _progress(BgInstallInfo operation) {
    if (operation.status == BgInstallStatus.downloading &&
        operation.downloadProgress != null) {
      return (operation.downloadProgress! / 100).clamp(0, 1);
    }
    if (operation.status == BgInstallStatus.installing &&
        operation.current != null &&
        operation.total != null &&
        operation.total! > 0) {
      return (operation.current! / operation.total!).clamp(0, 1);
    }
    return null;
  }
}

/// Conservative comparison shared by catalogue surfaces and Library.
///
/// Numeric dotted versions can be ordered. Non-numeric labels are only equal
/// when their normalized source text matches; their relative order is never
/// invented.
class InstallationVersionPolicy {
  const InstallationVersionPolicy._();

  static bool isReliableUpgrade(String? installed, String? catalogue) {
    final comparison = compare(installed, catalogue);
    return comparison != null && comparison > 0;
  }

  /// Returns a value greater than zero when [catalogue] is newer than
  /// [installed], zero for an exact/equivalent version, and null when the two
  /// labels cannot be ordered safely.
  static int? compare(String? installed, String? catalogue) {
    final installedLabel = _normalizedLabel(installed);
    final catalogueLabel = _normalizedLabel(catalogue);
    if (installedLabel == null || catalogueLabel == null) return null;
    if (installedLabel.toLowerCase() == catalogueLabel.toLowerCase()) return 0;

    final left = _numericVersion(installedLabel);
    final right = _numericVersion(catalogueLabel);
    if (left == null || right == null) return null;
    final length = left.length > right.length ? left.length : right.length;
    for (var index = 0; index < length; index++) {
      final installedPart = index < left.length ? left[index] : 0;
      final cataloguePart = index < right.length ? right[index] : 0;
      if (cataloguePart != installedPart) {
        return cataloguePart.compareTo(installedPart);
      }
    }
    return 0;
  }

  static List<int>? _numericVersion(String? value) {
    if (value == null) return null;
    final normalized = value.trim().replaceFirst(RegExp(r'^[vV]'), '');
    if (!RegExp(r'^\d+(?:\.\d+){0,3}$').hasMatch(normalized)) return null;
    return normalized.split('.').map(int.parse).toList(growable: false);
  }

  static String? _normalizedLabel(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
