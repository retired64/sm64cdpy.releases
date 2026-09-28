import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/installation_catalog.dart';
import '../../domain/entities/installation_library.dart';
import '../../l10n/app_localizations.dart';
import '../../services/background_install_service.dart';
import '../providers/installation_library_provider.dart';
import '../providers/mod_providers.dart';
import 'app_snackbar.dart';

class InstallationLibraryCard extends ConsumerWidget {
  const InstallationLibraryCard({
    super.key,
    required this.record,
    this.verification,
    this.compact = false,
    this.historyEntry = false,
  });

  final InstallationRecord record;
  final InstallationVerification? verification;
  final bool compact;
  final bool historyEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final contentBusy = ref
        .watch(bgInstallStateProvider)
        .values
        .any(
          (operation) =>
              operation.identity?.contentKey == record.contentKey &&
              switch (operation.status) {
                BgInstallStatus.pending ||
                BgInstallStatus.downloading ||
                BgInstallStatus.installing => true,
                _ => false,
              },
        );
    final status = verification?.status;
    final statusLabel = switch (status) {
      InstallationVerificationStatus.present => l10n.libraryPresent,
      InstallationVerificationStatus.missing => l10n.libraryMissing,
      InstallationVerificationStatus.permissionRevoked =>
        l10n.libraryPermissionRevoked,
      InstallationVerificationStatus.folderNotSelected =>
        l10n.libraryFolderNotSelected,
      InstallationVerificationStatus.unknown || null => l10n.libraryNotVerified,
    };
    final statusColor = switch (status) {
      InstallationVerificationStatus.present => retro.accent,
      InstallationVerificationStatus.missing => retro.amber,
      InstallationVerificationStatus.permissionRevoked => retro.red,
      InstallationVerificationStatus.folderNotSelected => retro.amber,
      InstallationVerificationStatus.unknown || null => retro.inkDim,
    };
    final displayLabel = historyEntry
        ? _eventLabel(l10n, record.eventKind)
        : statusLabel;
    final displayColor = historyEntry
        ? _eventColor(retro, record.eventKind)
        : statusColor;
    final displayIcon = historyEntry
        ? _eventIcon(record.eventKind)
        : Icons.inventory_2_outlined;
    final date = DateFormat.yMMMd(
      l10n.localeName,
    ).format(record.installedAt.toLocal());

    return Semantics(
      container: true,
      label: '${record.title}, $displayLabel',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          color: retro.surface,
          border: Border.all(
            color: retro.border.withValues(alpha: 0.45),
            width: 2,
          ),
          boxShadow: retro.hardShadow(dx: 3, dy: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(displayIcon, color: displayColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: retro.heading(size: compact ? 14 : 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (record.versionLabel != null) record.versionLabel!,
                          _sectionLabel(l10n, record.section),
                        ].join(' · '),
                        style: retro.body(size: 11, color: retro.inkDim),
                      ),
                    ],
                  ),
                ),
                if (!compact)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    color: displayColor.withValues(alpha: 0.14),
                    child: Text(
                      displayLabel,
                      style: retro.body(
                        size: 10,
                        color: displayColor,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (!compact)
                  PopupMenuButton<_LibraryMaintenanceAction>(
                    enabled: historyEntry || !contentBusy,
                    tooltip: historyEntry
                        ? l10n.libraryRemoveHistoryAction
                        : l10n.libraryForgetAction,
                    onSelected: (action) =>
                        _maintain(context, ref, l10n, action),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: historyEntry
                            ? _LibraryMaintenanceAction.removeHistory
                            : _LibraryMaintenanceAction.forget,
                        child: Text(
                          historyEntry
                              ? l10n.libraryRemoveHistoryAction
                              : l10n.libraryForgetAction,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 12,
              runSpacing: 5,
              children: [
                _Meta(icon: Icons.schedule_rounded, label: date),
                _Meta(
                  icon: Icons.folder_outlined,
                  label: _destinationLabel(l10n, record.destination),
                ),
              ],
            ),
            if (record.replacedByArtifactKey != null) ...[
              const SizedBox(height: 7),
              Text(
                l10n.libraryEventReplaced,
                style: retro.body(size: 10.5, color: retro.inkDim),
              ),
            ],
            if (!compact && !historyEntry) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _action(context, ref, l10n, retro, status),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _maintain(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    _LibraryMaintenanceAction action,
  ) async {
    final forget = action == _LibraryMaintenanceAction.forget;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          forget ? l10n.libraryForgetTitle : l10n.libraryRemoveHistoryTitle,
        ),
        content: Text(
          forget ? l10n.libraryForgetBody : l10n.libraryRemoveHistoryBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.detailCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              forget
                  ? l10n.libraryForgetConfirm
                  : l10n.libraryRemoveHistoryConfirm,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      if (forget) {
        await ref
            .read(installationLibraryProvider.notifier)
            .forgetContent(record.contentKey);
      } else {
        await ref
            .read(installationLibraryProvider.notifier)
            .removeHistoryEvent(record.installWorkerId);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.error(context, message: l10n.libraryMaintenanceError);
      }
    }
  }

  Widget _action(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    RetroTheme retro,
    InstallationVerificationStatus? status,
  ) {
    if (status == InstallationVerificationStatus.permissionRevoked ||
        status == InstallationVerificationStatus.folderNotSelected) {
      return OutlinedButton.icon(
        onPressed: () => context.go('/settings'),
        icon: const Icon(Icons.folder_open_rounded, size: 18),
        label: Text(l10n.installationSelectFolder),
      );
    }
    if (status == null || status == InstallationVerificationStatus.unknown) {
      return OutlinedButton.icon(
        onPressed: () => ref
            .read(installationLibraryProvider.notifier)
            .verifyArtifact(record.artifactKey),
        icon: const Icon(Icons.fact_check_outlined, size: 18),
        label: Text(l10n.installationVerify),
      );
    }
    return TextButton.icon(
      onPressed: () {
        final route = _originRoute(record);
        if (record.section == 'mods') {
          context.push(route);
        } else {
          context.go(route);
        }
      },
      icon: Icon(
        status == InstallationVerificationStatus.missing
            ? Icons.install_mobile_rounded
            : Icons.open_in_new_rounded,
        size: 18,
      ),
      label: Text(
        status == InstallationVerificationStatus.missing
            ? l10n.installationInstall
            : l10n.libraryOpenSource,
      ),
    );
  }
}

enum _LibraryMaintenanceAction { forget, removeHistory }

class InstallationUpdateCard extends StatelessWidget {
  const InstallationUpdateCard({super.key, required this.update});

  final InstallationUpdateCandidate update;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final installed = update.installed.versionLabel ?? '—';
    final available = update.available.identity.versionLabel ?? '—';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: retro.surface,
        border: Border.all(color: retro.accent, width: 2),
        boxShadow: retro.hardShadow(dx: 3, dy: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.system_update_alt_rounded, color: retro.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  update.available.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: retro.heading(size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            l10n.libraryUpdateVersions(installed, available),
            style: retro.body(size: 12, color: retro.inkDim),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: () {
                if (update.installed.section == 'mods') {
                  context.push(update.available.route);
                } else {
                  context.go(update.available.route);
                }
              },
              icon: const Icon(Icons.system_update_alt_rounded, size: 18),
              label: Text(l10n.installationUpdate),
            ),
          ),
        ],
      ),
    );
  }
}

class DetectedInstallationCard extends StatelessWidget {
  const DetectedInstallationCard({super.key, required this.discovery});

  final DiscoveredInstallation discovery;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: '${discovery.displayName}, ${l10n.libraryDetectedOnDevice}',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: retro.surface,
          border: Border.all(
            color: retro.border.withValues(alpha: 0.45),
            width: 2,
          ),
          boxShadow: retro.hardShadow(dx: 3, dy: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: retro.surfaceAlt,
                    border: Border.all(color: retro.accent, width: 2),
                  ),
                  child: Icon(
                    Icons.extension_rounded,
                    color: retro.accent,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discovery.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: retro.heading(size: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.libraryDetectedOnDevice,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: retro.body(size: 11.5, color: retro.inkDim),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (discovery.versionLabel != null)
                  _Meta(
                    icon: Icons.sell_outlined,
                    label: discovery.versionLabel!,
                  ),
                if (discovery.author != null)
                  _Meta(
                    icon: Icons.person_outline_rounded,
                    label: discovery.author!,
                  ),
                if (discovery.category != null)
                  _Meta(
                    icon: Icons.category_outlined,
                    label: discovery.category!,
                  ),
                _Meta(
                  icon: Icons.folder_outlined,
                  label: _destinationLabel(l10n, discovery.destination),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: retro.surfaceAlt,
                border: Border(left: BorderSide(color: retro.accent, width: 3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 15,
                    color: retro.inkDim,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${l10n.libraryDetectedPath}: ${discovery.entryPath}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: retro.body(size: 10.5, color: retro.inkDim),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: retro.inkDim),
        const SizedBox(width: 4),
        Text(label, style: retro.body(size: 10.5)),
      ],
    );
  }
}

String _originRoute(InstallationRecord record) => switch (record.section) {
  'mods' => '/mod/${Uri.encodeComponent(record.contentId)}',
  'vip' => '/vip',
  'dynos' => '/dynos',
  'touch_controls' => '/touch-controls',
  'omm' => '/omm-rebirth',
  'render96' => '/render96',
  _ => '/catalogue',
};

String _sectionLabel(AppLocalizations l10n, String section) =>
    switch (section) {
      'mods' => l10n.navCatalog,
      'vip' => l10n.navVIPMods,
      'dynos' => l10n.navDynOS,
      'touch_controls' => l10n.navTouchControls,
      'omm' => l10n.navOmmRebirth,
      'render96' => l10n.navRender96,
      _ => section,
    };

String _destinationLabel(AppLocalizations l10n, String destination) =>
    destination == 'dynos'
    ? l10n.libraryDynosDestination
    : l10n.libraryModsDestination;

String _eventLabel(AppLocalizations l10n, String eventKind) =>
    switch (eventKind) {
      'update' => l10n.libraryEventUpdate,
      'reinstall' => l10n.libraryEventReinstall,
      _ => l10n.libraryEventInstall,
    };

IconData _eventIcon(String eventKind) => switch (eventKind) {
  'update' => Icons.system_update_alt_rounded,
  'reinstall' => Icons.refresh_rounded,
  _ => Icons.download_done_rounded,
};

Color _eventColor(RetroTheme retro, String eventKind) => switch (eventKind) {
  'update' => retro.changelogImproved,
  'reinstall' => retro.amber,
  _ => retro.accent,
};
