import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/installation_library.dart';
import '../../l10n/app_localizations.dart';
import '../providers/installation_library_provider.dart';

class InstallationLibraryCard extends ConsumerWidget {
  const InstallationLibraryCard({
    super.key,
    required this.record,
    this.verification,
    this.compact = false,
  });

  final InstallationRecord record;
  final InstallationVerification? verification;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
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
    final date = DateFormat.yMMMd(
      l10n.localeName,
    ).format(record.installedAt.toLocal());

    return Semantics(
      container: true,
      label: '${record.title}, $statusLabel',
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
                Icon(Icons.inventory_2_outlined, color: statusColor, size: 22),
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
                    color: statusColor.withValues(alpha: 0.14),
                    child: Text(
                      statusLabel,
                      style: retro.body(
                        size: 10,
                        color: statusColor,
                        weight: FontWeight.w800,
                      ),
                    ),
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
            if (!compact) ...[
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
            ? Icons.refresh_rounded
            : Icons.open_in_new_rounded,
        size: 18,
      ),
      label: Text(
        status == InstallationVerificationStatus.missing
            ? l10n.installationReinstall
            : l10n.libraryOpenSource,
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
