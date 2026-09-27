import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/installation_library.dart';
import '../../l10n/app_localizations.dart';
import '../providers/installation_library_provider.dart';
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
    return RefreshIndicator(
      onRefresh: () => ref
          .read(installationLibraryProvider.notifier)
          .refresh(discover: true, forceDiscovery: true),
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
            leading: const DrawerMenuButton(icon: Icons.menu),
            title: Text(l10n.libraryTitle, style: retro.heading(size: 18)),
            actions: [
              IconButton(
                tooltip: l10n.libraryRefresh,
                onPressed: value.isLoading
                    ? null
                    : () => ref
                          .read(installationLibraryProvider.notifier)
                          .refresh(discover: true, forceDiscovery: true),
                icon: const Icon(Icons.refresh_rounded),
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
                  _viewSelector(l10n, retro),
                  const SizedBox(height: 12),
                  _filters(l10n, retro, state.snapshot),
                  const SizedBox(height: 14),
                  if (_view == _LibraryView.detected &&
                      state.snapshot.discoveryTruncated)
                    _Notice(
                      text: l10n.libraryDetectedScanLimit,
                      color: retro.amber,
                    ),
                  ..._content(l10n, state.snapshot),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewSelector(AppLocalizations l10n, RetroTheme retro) {
    final labels = [
      l10n.libraryInstalled,
      l10n.libraryUpdates,
      l10n.libraryDetected,
      l10n.libraryRecent,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<_LibraryView>(
        segments: [
          for (var i = 0; i < _LibraryView.values.length; i++)
            ButtonSegment(
              value: _LibraryView.values[i],
              label: Text(labels[i]),
            ),
        ],
        selected: {_view},
        onSelectionChanged: (value) => setState(() => _view = value.first),
        showSelectedIcon: false,
      ),
    );
  }

  Widget _filters(
    AppLocalizations l10n,
    RetroTheme retro,
    InstallationLibrarySnapshot snapshot,
  ) {
    final sections = snapshot.receipts.map((e) => e.section).toSet().toList()
      ..sort();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_view != _LibraryView.detected)
          DropdownButton<String?>(
            value: _section,
            hint: Text(l10n.libraryAllSections),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n.libraryAllSections),
              ),
              ...sections.map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.replaceAll('_', ' ').toUpperCase()),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _section = value),
          ),
        DropdownButton<String?>(
          value: _destination,
          hint: Text(l10n.libraryAllDestinations),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(l10n.libraryAllDestinations),
            ),
            DropdownMenuItem(
              value: 'mods',
              child: Text(l10n.libraryModsDestination),
            ),
            DropdownMenuItem(
              value: 'dynos',
              child: Text(l10n.libraryDynosDestination),
            ),
          ],
          onChanged: (value) => setState(() => _destination = value),
        ),
      ],
    );
  }

  List<Widget> _content(
    AppLocalizations l10n,
    InstallationLibrarySnapshot snapshot,
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
      return [
        _MessageState(
          icon: Icons.system_update_alt_rounded,
          title: l10n.libraryUpdatesEmptyTitle,
          body: l10n.libraryUpdatesEmptyBody,
        ),
      ];
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
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
    child: Text(text),
  );
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 52, color: retro.inkDim),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: retro.heading(size: 19),
          ),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: retro.body(size: 13)),
          if (action != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}
