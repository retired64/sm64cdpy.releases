import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/mod_installer.dart';

/// Shared UX for content installed into the common DynOS / Touch Controls
/// destination. Keeping these decisions here prevents both catalogue screens
/// from drifting into different behaviour again.
Future<bool> showDynosFolderRequiredDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: RetroTheme.of(ctx).surfaceAlt,
          icon: Icon(
            Icons.folder_open_rounded,
            color: RetroTheme.of(ctx).accent,
            size: 28,
          ),
          title: Text(
            l10n.detailDynosFolderNotSelected,
            style: TextStyle(color: RetroTheme.of(ctx).ink),
          ),
          content: Text(
            l10n.detailDynosFolderBody,
            style: TextStyle(color: RetroTheme.of(ctx).inkDim),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                l10n.detailCancel,
                style: TextStyle(color: RetroTheme.of(ctx).ink),
              ),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.settings, size: 16),
              label: Text(l10n.detailGoToSettings),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> confirmDynosInstall(
  BuildContext context, {
  required String name,
}) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: RetroTheme.of(ctx).surfaceAlt,
          icon: Icon(
            Icons.install_mobile_rounded,
            color: RetroTheme.of(ctx).accent,
            size: 28,
          ),
          title: Text(
            l10n.detailInstallDownloadedTitle,
            style: TextStyle(color: RetroTheme.of(ctx).ink),
          ),
          content: Text(
            l10n.detailInstallDownloadedBody(name),
            style: TextStyle(color: RetroTheme.of(ctx).inkDim),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                l10n.detailKeepDownload,
                style: TextStyle(color: RetroTheme.of(ctx).ink),
              ),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.install_mobile_rounded, size: 16),
              label: Text(l10n.detailInstallNow),
            ),
          ],
        ),
      ) ??
      false;
}

/// Installs an already downloaded file into the shared DynOS destination.
/// Returns an error message, or null on success.
Future<String?> installDownloadedDynosFile({
  required ModInstaller installer,
  required String path,
  required String modName,
  required String fallbackError,
}) async {
  try {
    final savedName = path.split('/').last;
    if (savedName.toLowerCase().endsWith('.zip')) {
      final result = await installer.installModToDynosFolder(
        zipPath: path,
        modName: modName,
      );
      if (!result.success) return result.errorMessage ?? fallbackError;
    } else {
      await installer.copyFileToDynosFolder(
        sourcePath: path,
        targetName: savedName,
      );
    }
    return null;
  } catch (error) {
    return error.toString();
  }
}

String friendlyDownloadError(AppLocalizations l10n, Object error) {
  final details = error.toString();
  final normalized = details.toLowerCase();
  if (normalized.contains('404') || normalized.contains('not found')) {
    return l10n.detailContentUnavailable;
  }
  return l10n.detailFriendlyDownloadError;
}
