import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/guided_setup_service.dart';
import '../../services/permission_access_service.dart';
import '../providers/game_folder_provider.dart';
import '../widgets/app_shell.dart';
import '../widgets/game_folder_card.dart';
import '../widgets/guided_setup_flow.dart';
import '../widgets/notification_permission_flow.dart';
import '../../services/mod_installer.dart';

class PermissionsAccessScreen extends ConsumerStatefulWidget {
  const PermissionsAccessScreen({super.key});

  @override
  ConsumerState<PermissionsAccessScreen> createState() =>
      _PermissionsAccessScreenState();
}

class _PermissionsAccessScreenState
    extends ConsumerState<PermissionsAccessScreen>
    with WidgetsBindingObserver {
  final PermissionAccessService _service = PermissionAccessService();
  PermissionAccessSnapshot? _snapshot;
  String? _busy;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final generation = ++_generation;
    unawaited(ref.read(gameFolderProvider.notifier).refresh());
    final value = await _service.snapshot();
    if (mounted && generation == _generation) setState(() => _snapshot = value);
  }

  Future<void> _act(String key, Future<void> Function() action) async {
    if (_busy != null) return;
    setState(() => _busy = key);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = null);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final folder = ref.watch(gameFolderProvider).connection;
    final snapshot = _snapshot;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        RetroPinnedAppBar(
          title: Text(
            l.permissionCenterTitle,
            style: retro.heading(size: 18, color: retro.accentText),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          sliver: SliverList.list(
            children: [
              _Intro(text: l.permissionCenterIntro),
              const SizedBox(height: 14),
              _AccessCard(
                icon: Icons.folder_open_rounded,
                title: l.gameFolderTitle,
                description: l.permissionFolderDescription,
                allowed: folder.connected,
                busy: _busy == 'folder',
                onPressed: () => _act('folder', () async {
                  await connectGameFolder(context, ref);
                }),
              ),
              _AccessCard(
                icon: Icons.notifications_outlined,
                title: l.detailNotificationsNeeded,
                description: l.permissionNotificationsDescription,
                allowed: snapshot?.notifications,
                busy: _busy == 'notifications',
                onPressed: () => _act('notifications', () async {
                  await ensureNotificationPermission(context, ModInstaller());
                }),
              ),
              if (snapshot?.allFilesSupported != false)
                _AccessCard(
                  icon: Icons.folder_copy_outlined,
                  title: l.fastInstallTitle,
                  description: l.permissionAllFilesDescription,
                  allowed: snapshot?.allFiles,
                  busy: _busy == 'files',
                  onPressed: () => _act('files', () async {
                    await _service.requestAllFiles();
                  }),
                ),
              _AccessCard(
                icon: Icons.picture_in_picture_alt_outlined,
                title: l.settingsOverlayInactive,
                description: l.permissionOverlayDescription,
                allowed: snapshot?.overlay,
                busy: _busy == 'overlay',
                onPressed: () => _act('overlay', () async {
                  await _service.requestOverlay();
                }),
              ),
              if (snapshot?.batterySupported != false)
                _AccessCard(
                  icon: Icons.battery_saver_outlined,
                  title: l.coopBatteryTitle,
                  description: l.permissionBatteryDescription,
                  allowed: snapshot?.batteryUnrestricted,
                  busy: _busy == 'battery',
                  onPressed: () => _act('battery', () async {
                    await _service.requestBattery();
                  }),
                ),
              _InfoCard(
                icon: Icons.system_update_alt_rounded,
                title: l.permissionUpdatesTitle,
                description: l.permissionUpdatesDescription,
              ),
              _InfoCard(
                icon: Icons.public_rounded,
                title: l.permissionNetworkTitle,
                description: l.permissionNetworkDescription,
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _busy == null
                    ? () => _act('guide', () async {
                        await GuidedSetupService.reset();
                        if (context.mounted) {
                          await showGuidedSetupFlow(
                            context,
                            allowDismiss: true,
                          );
                        }
                      })
                    : null,
                icon: const Icon(Icons.assistant_navigation),
                label: Text(l.permissionRunGuide),
              ),
              const SizedBox(height: 8),
              Text(
                l.permissionRunGuideDescription,
                textAlign: TextAlign.center,
                style: retro.body(size: 13, color: retro.inkDim),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: retro.surfaceDecoration(color: retro.surfaceAlt),
      child: Text(text, style: retro.body(size: 15, height: 1.45)),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.allowed,
    required this.busy,
    required this.onPressed,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool? allowed;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final status = allowed == null
        ? l.permissionStatusOptional
        : allowed!
        ? l.permissionStatusAllowed
        : l.permissionStatusNotAllowed;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: retro.accentText, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: retro.heading(size: 16)),
                  const SizedBox(height: 5),
                  Text(description, style: retro.body(size: 14, height: 1.35)),
                  const SizedBox(height: 10),
                  Text(
                    status,
                    style: retro.body(
                      size: 13,
                      color: allowed == true ? Colors.green : retro.inkDim,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            busy
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: onPressed,
                    child: Text(l.permissionManage),
                  ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(icon, color: retro.inkDim),
      title: Text(title, style: retro.heading(size: 15)),
      subtitle: Text(description, style: retro.body(size: 13, height: 1.35)),
    );
  }
}
