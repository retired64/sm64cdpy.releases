import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/mod_installer.dart';

/// Shared UX for content installed into the common DynOS / Touch Controls
/// destination. Keeping these decisions here prevents both catalogue screens
/// from drifting into different behaviour again.
Future<bool> showDynosFolderRequiredDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return _showFolderRequiredDialog(
    context,
    title: l10n.detailDynosFolderNotSelected,
    body: l10n.detailDynosFolderBody,
  );
}

Future<bool> showModsFolderRequiredDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return _showFolderRequiredDialog(
    context,
    title: l10n.detailModsFolderNotSelected,
    body: l10n.detailModsFolderBody,
  );
}

Future<bool> _showFolderRequiredDialog(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final retro = RetroTheme.of(ctx);
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: retro.gameDecoration(BoxDecoration(
                borderRadius: retro.radius,
                color: retro.surfaceAlt,
                border: Border.all(
                  color: retro.accent,
                  width: retro.borderWidth(2),
                ),
                boxShadow: retro.hardShadow(dx: 5, dy: 5),
              )),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MarioGameIcon(
                    Icons.folder_open_rounded,
                    color: retro.accentText,
                    size: 34,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    retro.displayLabel(title),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: retro.headingFamily,
                      color: retro.ink,
                      fontWeight: retro.design.headingWeight,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(body, style: TextStyle(color: retro.inkDim)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(l10n.detailCancel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          icon: const MarioGameIcon(Icons.settings, size: 16),
                          label: Text(l10n.detailGoToSettings),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
          icon: MarioGameIcon(
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
              icon: const MarioGameIcon(Icons.install_mobile_rounded, size: 16),
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
