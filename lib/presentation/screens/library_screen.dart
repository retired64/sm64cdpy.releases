import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/installation_catalog.dart';
import '../../domain/entities/installation_library.dart';
import '../../l10n/app_localizations.dart';
import '../providers/extra_providers.dart';
import '../providers/installation_library_provider.dart';
import '../providers/installation_update_provider.dart';
import '../providers/mod_providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/installation_library_card.dart';

enum _LibraryView { installed, updates, detected, recent }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});
  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _LibraryView _view = _LibraryView.installed;
  String? _section;
  String? _destination;
  bool _initialViewApplied = false;

  Future<void> _refresh() async {
    ref.invalidate(allModsProvider);
    ref.invalidate(allVipModsProvider);
    ref.invalidate(allDynosProvider);
    ref.invalidate(allTouchControlsProvider);
    ref.invalidate(allOmmRebirthProvider);
    ref.invalidate(allRender96Provider);
    await ref
        .read(installationLibraryProvider.notifier)
        .refresh(discover: true, forceDiscovery: true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(installationLibraryProvider.notifier).refresh(discover: true),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialViewApplied &&
        GoRouterState.of(context).uri.queryParameters['view'] == 'recent') {
      _view = _LibraryView.recent;
    }
    _initialViewApplied = true;
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final value = ref.watch(installationLibraryProvider);
    final updates = ref.watch(installationUpdatesProvider);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            backgroundColor: retro.background,
            surfaceTintColor: Colors.transparent,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            shape: Border(bottom: BorderSide(color: retro.border, width: 3)),
            leading: const DrawerMenuButton(),
            title: Text(
              l10n.libraryTitle,
              style: retro.heading(size: 18, color: retro.accent),
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: _RetroIconButton(
                  tooltip: l10n.libraryRefresh,
                  onPressed: value.isLoading ? null : _refresh,
                  icon: Icons.refresh_rounded,
                  busy: value.isLoading,
                ),
              ),
            ],
          ),
          value.when(
            loading: () => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: retro.accent),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: _MessageState(
                icon: Icons.error_outline_rounded,
                title: l10n.libraryErrorTitle,
                body: l10n.libraryErrorBody,
                action: l10n.generalRetry,
                onAction: () => ref.invalidate(installationLibraryProvider),
              ),
            ),
            data: (state) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList.list(
                children: [
                  if (state.status == InstallationLibraryLoadStatus.partial)
                    _Notice(
                      text: l10n.libraryPartialWarning,
                      color: retro.amber,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionKicker(
                      retro: retro,
                      label: l10n.libraryTitle,
                      japanese: 'ライブラリ',
                    ),
                  ),
                  _viewSelector(l10n, retro, state.snapshot, updates),
                  const SizedBox(height: 14),
                  _filters(l10n, retro, state.snapshot, updates),
                  const SizedBox(height: 18),
                  if (_view == _LibraryView.detected &&
                      state.snapshot.discoveryTruncated)
                    _Notice(
                      text: l10n.libraryDetectedScanLimit,
                      color: retro.amber,
                    ),
                  ..._content(l10n, state.snapshot, updates),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewSelector(
    AppLocalizations l10n,
    RetroTheme retro,
    InstallationLibrarySnapshot snapshot,
    AsyncValue<List<InstallationUpdateCandidate>> updates,
  ) {
    final labels = [
      l10n.libraryInstalled,
      l10n.libraryUpdates,
      l10n.libraryDetected,
      l10n.libraryRecent,
    ];
    final icons = [
      Icons.inventory_2_outlined,
      Icons.system_update_alt_rounded,
      Icons.manage_search_rounded,
      Icons.history_rounded,
    ];
    final counts = <int?>[
      snapshot.receipts.length,
      updates.asData?.value.length,
      snapshot.discoveries.length,
      snapshot.history.length,
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsetsDirectional.only(start: 3, end: 6),
        itemCount: _LibraryView.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final count = counts[index];
          return SkewChip(
            retro: retro,
            label: count == null
                ? labels[index].toUpperCase()
                : '${labels[index].toUpperCase()}  $count',
            icon: icons[index],
            selected: _view == _LibraryView.values[index],
            dense: true,
            onTap: () => setState(() {
              _view = _LibraryView.values[index];
              _section = null;
              _destination = null;
            }),
          );
        },
      ),
    );
  }

  Widget _filters(
    AppLocalizations l10n,
    RetroTheme retro,
    InstallationLibrarySnapshot snapshot,
    AsyncValue<List<InstallationUpdateCandidate>> updates,
  ) {
    final sections = switch (_view) {
      _LibraryView.installed =>
        snapshot.receipts.map((item) => item.section).toSet(),
      _LibraryView.updates =>
        updates.asData?.value.map((item) => item.installed.section).toSet() ??
            <String>{},
      _LibraryView.recent =>
        snapshot.history.map((item) => item.section).toSet(),
      _LibraryView.detected => <String>{},
    }.toList()..sort();
    final destinations = switch (_view) {
      _LibraryView.installed =>
        snapshot.receipts.map((item) => item.destination).toSet(),
      _LibraryView.updates =>
        updates.asData?.value
                .map((item) => item.installed.destination)
                .toSet() ??
            <String>{},
      _LibraryView.detected =>
        snapshot.discoveries.map((item) => item.destination).toSet(),
      _LibraryView.recent =>
        snapshot.history.map((item) => item.destination).toSet(),
    }.toList()..sort();
    final showSection = sections.length > 1;
    final showDestination = destinations.length > 1;
    if (!showSection && !showDestination) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsetsDirectional.only(start: 3, end: 6),
        children: [
          if (showSection) ...[
            _LibraryFilterChip(
              retro: retro,
              label: _section == null
                  ? l10n.libraryAllSections
                  : _sectionLabel(l10n, _section!),
              icon: Icons.category_outlined,
              active: _section != null,
              onTap: () => _section == null
                  ? _showSectionSheet(l10n, retro, sections)
                  : setState(() => _section = null),
            ),
            const SizedBox(width: 10),
          ],
          if (showDestination)
            _LibraryFilterChip(
              retro: retro,
              label: _destination == null
                  ? l10n.libraryAllDestinations
                  : _destinationLabel(l10n, _destination!),
              icon: Icons.folder_outlined,
              active: _destination != null,
              onTap: () => _destination == null
                  ? _showDestinationSheet(l10n, retro, destinations)
                  : setState(() => _destination = null),
            ),
        ],
      ),
    );
  }

  Future<void> _showSectionSheet(
    AppLocalizations l10n,
    RetroTheme retro,
    List<String> sections,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: retro.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: retro.border, width: 3),
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) => _LibraryFilterSheet(
        retro: retro,
        title: l10n.libraryAllSections,
        selected: _section,
        options: [
          for (final section in sections)
            _LibraryFilterOption(
              value: section,
              label: _sectionLabel(l10n, section),
              icon: _sectionIcon(section),
            ),
        ],
      ),
    );
    if (result != null && mounted) setState(() => _section = result);
  }

  Future<void> _showDestinationSheet(
    AppLocalizations l10n,
    RetroTheme retro,
    List<String> destinations,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: retro.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: retro.border, width: 3),
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) => _LibraryFilterSheet(
        retro: retro,
        title: l10n.libraryAllDestinations,
        selected: _destination,
        options: [
          for (final destination in destinations)
            _LibraryFilterOption(
              value: destination,
              label: _destinationLabel(l10n, destination),
              icon: destination == 'dynos'
                  ? Icons.folder_special_outlined
                  : Icons.folder_copy_outlined,
            ),
        ],
      ),
    );
    if (result != null && mounted) setState(() => _destination = result);
  }

  List<Widget> _content(
    AppLocalizations l10n,
    InstallationLibrarySnapshot snapshot,
    AsyncValue<List<InstallationUpdateCandidate>> updates,
  ) {
    if (_view == _LibraryView.detected) {
      final discoveries = snapshot.discoveries
          .where(
            (item) => _destination == null || item.destination == _destination,
          )
          .toList();
      if (discoveries.isEmpty) {
        return [
          _MessageState(
            icon: Icons.manage_search_rounded,
            title: l10n.libraryDetectedEmptyTitle,
            body: l10n.libraryDetectedEmptyBody,
          ),
        ];
      }
      return discoveries
          .map((item) => DetectedInstallationCard(discovery: item))
          .toList(growable: false);
    }
    if (_view == _LibraryView.updates) {
      return updates.when(
        loading: () => [
          _MessageState(
            icon: Icons.sync_rounded,
            title: l10n.libraryCatalogLoading,
            body: l10n.libraryUpdatesEmptyBody,
          ),
        ],
        error: (_, _) => [
          _MessageState(
            icon: Icons.cloud_off_rounded,
            title: l10n.libraryUpdatesEmptyTitle,
            body: l10n.libraryCatalogError,
            action: l10n.generalRetry,
            onAction: _refresh,
          ),
        ],
        data: (items) {
          final filtered = items
              .where(
                (item) =>
                    (_section == null || item.installed.section == _section) &&
                    (_destination == null ||
                        item.installed.destination == _destination),
              )
              .toList(growable: false);
          return filtered.isEmpty
              ? [
                  _MessageState(
                    icon: Icons.system_update_alt_rounded,
                    title: l10n.libraryUpdatesEmptyTitle,
                    body: l10n.libraryUpdatesEmptyBody,
                  ),
                ]
              : filtered
                    .map((item) => InstallationUpdateCard(update: item))
                    .toList(growable: false);
        },
      );
    }
    final source = _view == _LibraryView.recent
        ? snapshot.history
        : snapshot.receipts;
    final records =
        source
            .where(
              (record) =>
                  (_section == null || record.section == _section) &&
                  (_destination == null || record.destination == _destination),
            )
            .toList()
          ..sort((a, b) => b.installedAt.compareTo(a.installedAt));
    if (records.isEmpty) {
      return [
        _MessageState(
          icon: Icons.inventory_2_outlined,
          title: l10n.libraryEmptyTitle,
          body: l10n.libraryEmptyBody,
        ),
      ];
    }
    return records
        .map(
          (record) => InstallationLibraryCard(
            record: record,
            verification: snapshot.verifications[record.artifactKey],
            historyEntry: _view == _LibraryView.recent,
          ),
        )
        .toList(growable: false);
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: retro.surface,
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: retro.hardShadow(dx: 3, dy: 3),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: retro.body(size: 12))),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 22),
      decoration: BoxDecoration(
        color: retro.surface,
        border: Border.all(color: retro.border, width: 2.5),
        boxShadow: retro.hardShadow(dx: 4, dy: 4),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: retro.surfaceAlt,
              border: Border.all(color: retro.border, width: 2),
            ),
            child: Icon(icon, size: 34, color: retro.accent),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: retro.heading(size: 19),
          ),
          const SizedBox(height: 9),
          Text(body, textAlign: TextAlign.center, style: retro.body(size: 13)),
          if (action != null) ...[
            const SizedBox(height: 18),
            SkewChip(
              retro: retro,
              label: action!,
              icon: Icons.refresh_rounded,
              selected: true,
              onTap: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

class _RetroIconButton extends StatelessWidget {
  const _RetroIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.busy = false,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        label: tooltip,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: retro.surface,
              border: Border.all(color: retro.border, width: 2),
              boxShadow: onPressed == null
                  ? null
                  : retro.hardShadow(dx: 2, dy: 2),
            ),
            child: busy
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: retro.accent,
                    ),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: onPressed == null ? retro.inkDim : retro.ink,
                  ),
          ),
        ),
      ),
    );
  }
}

class _LibraryFilterChip extends StatelessWidget {
  const _LibraryFilterChip({
    required this.retro,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final RetroTheme retro;
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SkewChip(
    retro: retro,
    label: label.toUpperCase(),
    icon: icon,
    trailing: active ? Icons.close_rounded : Icons.expand_more_rounded,
    selected: active,
    dense: true,
    onTap: onTap,
  );
}

class _LibraryFilterOption {
  const _LibraryFilterOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

class _LibraryFilterSheet extends StatelessWidget {
  const _LibraryFilterSheet({
    required this.retro,
    required this.title,
    required this.selected,
    required this.options,
  });

  final RetroTheme retro;
  final String title;
  final String? selected;
  final List<_LibraryFilterOption> options;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 36, height: 4, color: retro.border)),
          const SizedBox(height: 18),
          SectionKicker(retro: retro, label: title.toUpperCase()),
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final option in options)
                    _LibraryFilterSheetItem(
                      option: option,
                      selected: selected == option.value,
                      retro: retro,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LibraryFilterSheetItem extends StatelessWidget {
  const _LibraryFilterSheetItem({
    required this.option,
    required this.selected,
    required this.retro,
  });

  final _LibraryFilterOption option;
  final bool selected;
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      onTap: () => Navigator.of(context).pop(option.value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? retro.accent : retro.surfaceAlt,
          border: Border.all(color: retro.border, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 18,
              color: selected ? retro.inkOnAccent : retro.ink,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label.toUpperCase(),
                style: retro.heading(
                  size: 13,
                  color: selected ? retro.inkOnAccent : retro.ink,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 19, color: retro.inkOnAccent),
          ],
        ),
      ),
    ),
  );
}

String _sectionLabel(AppLocalizations l10n, String section) =>
    switch (section) {
      'mods' => l10n.navCatalog,
      'vip' => l10n.navVIPMods,
      'dynos' => l10n.navDynOS,
      'touch_controls' => l10n.navTouchControls,
      'omm' => l10n.navOmmRebirth,
      'render96' => l10n.navRender96,
      _ => section.replaceAll('_', ' '),
    };

IconData _sectionIcon(String section) => switch (section) {
  'mods' => Icons.extension_outlined,
  'vip' => Icons.workspace_premium_outlined,
  'dynos' => Icons.accessibility_new_rounded,
  'touch_controls' => Icons.gamepad_outlined,
  'omm' => Icons.auto_awesome_outlined,
  'render96' => Icons.palette_outlined,
  _ => Icons.category_outlined,
};

String _destinationLabel(AppLocalizations l10n, String destination) =>
    destination == 'dynos'
    ? l10n.libraryDynosDestination
    : l10n.libraryModsDestination;
