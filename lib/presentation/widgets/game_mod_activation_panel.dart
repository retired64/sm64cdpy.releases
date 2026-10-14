import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/background_install_service.dart';
import '../../services/game_mod_activation.dart';
import '../../services/mod_installer.dart';
import '../providers/game_mod_activation_provider.dart';
import 'app_snackbar.dart';

enum _ModFilter { all, enabled, disabled }

enum _AccessAction { select, disconnect, restore }

/// Library presentation only. Native SAF remains the authority for every save.
class GameModActivationPanel extends ConsumerStatefulWidget {
  const GameModActivationPanel({super.key});
  @override
  ConsumerState<GameModActivationPanel> createState() =>
      _GameModActivationPanelState();
}

class _GameModActivationPanelState extends ConsumerState<GameModActivationPanel>
    with WidgetsBindingObserver {
  final _search = TextEditingController();
  bool _busy = false;
  bool _confirming = false;
  bool _closedGameConfirmed = false;
  int _visible = 20;
  _ModFilter _filter = _ModFilter.all;
  String? _savingName;
  String? _error;
  StreamSubscription<BgInstallEvent>? _subscription;
  StreamSubscription<String>? _folderSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _folderSubscription = ModInstaller.libraryInvalidations.listen(
      (_) => unawaited(_refresh()),
    );
    _subscription = BackgroundInstallService.instance.events.listen((event) {
      if (mounted) setState(() {});
      if (event is BgInstallCompleted) unawaited(_refresh());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_refresh());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _folderSubscription?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _closedGameConfirmed = false;
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() =>
      _run(() => ref.read(gameModActivationProvider.notifier).refresh());

  Future<void> _run(
    Future<void> Function() action, {
    String? savingName,
  }) async {
    if (_busy || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
      _savingName = savingName;
    });
    try {
      await action();
    } on PlatformException catch (error) {
      if (mounted) setState(() => _error = error.code);
    } catch (_) {
      if (mounted) setState(() => _error = 'access');
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
          _savingName = null;
        });
    }
  }

  Future<bool> _confirm({
    required bool restore,
    GameModEntry? mod,
    bool? enabled,
  }) async {
    if (_busy) return false;
    setState(() {
      _busy = true;
      _confirming = true;
    });
    final l10n = AppLocalizations.of(context);
    bool? confirmed;
    try {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final retro = RetroTheme.of(dialogContext);
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              decoration: retro.surfaceDecoration(shadowDx: 5, shadowDy: 5),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MarioGameIcon(
                      restore
                          ? Icons.restore_rounded
                          : Icons.sports_esports_rounded,
                      size: 36,
                      color: retro.accentText,
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      namesRoute: true,
                      child: Text(
                        restore ? l10n.gameModsRestore : l10n.gameModsTitle,
                        style: retro.heading(size: 20),
                      ),
                    ),
                    if (mod != null) ...[
                      const SizedBox(height: 12),
                      Text(mod.title, style: retro.heading(size: 15)),
                      Text(
                        enabled == true
                            ? l10n.gameModsEnabled
                            : l10n.gameModsDisabled,
                        style: retro.body(size: 12, color: retro.accentText),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      restore
                          ? l10n.gameModsRestoreConfirm
                          : l10n.gameModsConfirm,
                      style: retro.body(size: 14),
                    ),
                    const SizedBox(height: 20),
                    _LibraryAction(
                      label: restore
                          ? l10n.gameModsRestore
                          : l10n.gameModsApply,
                      icon: restore
                          ? Icons.restore_rounded
                          : Icons.check_rounded,
                      primary: true,
                      onPressed: () => Navigator.pop(dialogContext, true),
                    ),
                    const SizedBox(height: 10),
                    _LibraryAction(
                      label: l10n.gameModsCancel,
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
          _confirming = false;
        });
    }
    return mounted && confirmed == true;
  }

  Future<void> _change(GameModEntry mod, bool enabled) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    if (!_closedGameConfirmed) {
      if (!await _confirm(restore: false, mod: mod, enabled: enabled) ||
          !mounted)
        return;
      _closedGameConfirmed = true;
    }
    await _run(
      () => ref.read(gameModActivationProvider.notifier).perform(
        'setGameModActivation',
        {'name': mod.name, 'enabled': enabled},
      ),
      savingName: mod.name,
    );
    if (mounted && _error == null)
      AppSnackbar.success(
        context,
        message: AppLocalizations.of(context).gameModsSaved,
      );
  }

  Future<void> _access(_AccessAction action) async {
    if (_busy) return;
    if (action == _AccessAction.restore &&
        (!await _confirm(restore: true) || !mounted))
      return;
    _closedGameConfirmed = false;
    final method = switch (action) {
      _AccessAction.select => 'selectGameUserFolder',
      _AccessAction.disconnect => 'clearGameUserFolder',
      _AccessAction.restore => 'restoreGameModConfig',
    };
    await _run(
      () => ref.read(gameModActivationProvider.notifier).perform(method),
    );
    if (action == _AccessAction.restore && mounted && _error == null) {
      AppSnackbar.success(
        context,
        message: AppLocalizations.of(context).gameModsSaved,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final value = ref.watch(gameModActivationProvider);
    final installing =
        BackgroundInstallService.instance.activeInstalls.isNotEmpty;
    final snapshot = value.asData?.value;
    final ready = snapshot?.status == 'ready';
    final status = _error ?? snapshot?.status;
    final message = switch (status) {
      'ready' => l10n.gameModsHint,
      'unselected' => l10n.gameModsSelectHint,
      'conflict' => l10n.gameModsConflict,
      'invalid' => l10n.gameModsBlocked,
      'size' => l10n.gameModsSize,
      'installing' => l10n.gameModsInstalling,
      'mismatch' => l10n.gameModsMismatch,
      'write' || 'verify' => l10n.gameModsWriteError,
      'limit' || 'format' => l10n.gameModsFormat,
      _ => l10n.gameModsAccess,
    };
    final hasError =
        _error != null ||
        value.hasError ||
        (!value.isLoading &&
            snapshot?.status != 'ready' &&
            snapshot?.status != 'unselected');
    final mods = snapshot?.mods ?? const <GameModEntry>[];
    final query = _search.text.trim().toLowerCase();
    final filtered = mods
        .where(
          (mod) =>
              (query.isEmpty ||
                  [
                    mod.title,
                    mod.name,
                    mod.author,
                    mod.category,
                    mod.versionLabel,
                    mod.description,
                  ].whereType<String>().any(
                    (text) => text.toLowerCase().contains(query),
                  )) &&
              switch (_filter) {
                _ModFilter.all => true,
                _ModFilter.enabled => mod.enabled,
                _ModFilter.disabled => !mod.enabled,
              },
        )
        .toList(growable: false);
    final active = mods.where((mod) => mod.enabled).length;
    final restoreAvailable =
        snapshot?.backupAvailable == true ||
        _error == 'write' ||
        _error == 'verify';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (retro.isMario && snapshot != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MarioMenuGlyph(
                    retro: retro,
                    asset: 'star',
                    fallback: Icons.star_rounded,
                  ),
                  const SizedBox(width: 6),
                  MarioHudNumber(value: active, retro: retro),
                  Text(' / ', style: retro.body(size: 14)),
                  MarioHudNumber(value: mods.length, retro: retro),
                ],
              ),
            ),
          ),
        Container(
          key: const ValueKey('game-mods-header'),
          decoration: retro.surfaceDecoration(shadowDx: 3, shadowDy: 3),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: retro.surfaceDecoration(
                      color: retro.accent,
                      shadowDx: 2,
                      shadowDy: 2,
                    ),
                    child: MarioGameIcon(
                      retro.design.playfulSelection
                          ? Icons.star_rounded
                          : Icons.sports_esports_rounded,
                      color: retro.inkOnAccent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          retro.displayLabel(l10n.gameModsTitle),
                          style: retro.heading(size: 18),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          ready
                              ? l10n.gameModsCount(active, mods.length)
                              : l10n.gameModsSubtitle,
                          style: retro.body(size: 12, color: retro.inkDim),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_AccessAction>(
                    tooltip: l10n.gameModsManage,
                    enabled: !_busy,
                    icon: MarioGameIcon(
                      Icons.more_horiz_rounded,
                      color: retro.ink,
                    ),
                    onSelected: _access,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _AccessAction.select,
                        child: Text(l10n.gameModsSelect),
                      ),
                      if (snapshot != null && snapshot.status != 'unselected')
                        PopupMenuItem(
                          value: _AccessAction.disconnect,
                          child: Text(l10n.gameModsDisconnect),
                        ),
                      if (restoreAvailable)
                        PopupMenuItem(
                          value: _AccessAction.restore,
                          child: Text(l10n.gameModsRestore),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LibraryNotice(
                message: value.isLoading ? l10n.gameModsSubtitle : message,
                icon: hasError
                    ? Icons.error_outline_rounded
                    : ready
                    ? Icons.info_outline_rounded
                    : Icons.folder_open_rounded,
                warning: hasError,
              ),
              if (installing) ...[
                const SizedBox(height: 10),
                _LibraryNotice(
                  message: l10n.gameModsInstalling,
                  icon: Icons.downloading_rounded,
                  warning: true,
                ),
              ],
              if ((_busy && !_confirming) || value.isLoading) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  color: retro.accent,
                  backgroundColor: retro.surfaceAlt,
                  minHeight: 3,
                ),
              ],
              if (!ready && !value.isLoading) ...[
                const SizedBox(height: 14),
                _LibraryAction(
                  label: l10n.gameModsSelect,
                  icon: Icons.folder_open_rounded,
                  primary: true,
                  onPressed: _busy ? null : () => _access(_AccessAction.select),
                ),
              ],
              if (hasError) ...[
                const SizedBox(height: 10),
                _LibraryAction(
                  label: l10n.generalRetry,
                  icon: Icons.refresh_rounded,
                  onPressed: _busy ? null : _refresh,
                ),
              ],
              if (_error == 'write' || _error == 'verify') ...[
                const SizedBox(height: 10),
                _LibraryAction(
                  label: l10n.gameModsRestore,
                  icon: Icons.restore_rounded,
                  onPressed: _busy
                      ? null
                      : () => _access(_AccessAction.restore),
                ),
              ],
            ],
          ),
        ),
        if (ready) ...[
          TextField(
            key: const ValueKey('game-mods-search'),
            controller: _search,
            style: retro.body(size: 14),
            onChanged: (_) => setState(() => _visible = 20),
            decoration: InputDecoration(
              hintText: l10n.gameModsSearch,
              hintStyle: retro.body(size: 12, color: retro.inkDim),
              filled: true,
              fillColor: retro.surface,
              prefixIcon: MarioGameIcon(
                Icons.search_rounded,
                color: retro.accentText,
              ),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.gameModsClearSearch,
                      icon: const MarioGameIcon(Icons.close_rounded),
                      onPressed: () => setState(() {
                        _search.clear();
                        _visible = 20;
                      }),
                    ),
              enabledBorder: OutlineInputBorder(
                borderRadius: retro.radius,
                borderSide: BorderSide(
                  color: retro.border,
                  width: retro.borderWidth(2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: retro.radius,
                borderSide: BorderSide(
                  color: retro.accent,
                  width: retro.borderWidth(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsetsDirectional.only(start: 3, end: 6),
            child: Row(
              children: [
                for (final filter in _ModFilter.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: SkewChip(
                      key: ValueKey('game-mod-filter-${filter.name}'),
                      retro: retro,
                      dense: true,
                      label: retro.displayLabel(switch (filter) {
                        _ModFilter.all => l10n.gameModsAll,
                        _ModFilter.enabled => l10n.gameModsEnabledFilter,
                        _ModFilter.disabled => l10n.gameModsDisabledFilter,
                      }),
                      icon: switch (filter) {
                        _ModFilter.all => Icons.apps_rounded,
                        _ModFilter.enabled =>
                          Icons.check_circle_outline_rounded,
                        _ModFilter.disabled =>
                          Icons.pause_circle_outline_rounded,
                      },
                      selected: _filter == filter,
                      onTap: () => setState(() {
                        _filter = filter;
                        _visible = 20;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            Container(
              decoration: retro.surfaceDecoration(shadowDx: 3, shadowDy: 3),
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  MarioGameIcon(
                    mods.isEmpty
                        ? Icons.extension_off_rounded
                        : Icons.search_off_rounded,
                    size: 36,
                    color: retro.inkDim,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mods.isEmpty ? l10n.gameModsEmpty : l10n.gameModsNoResults,
                    textAlign: TextAlign.center,
                    style: retro.body(size: 14),
                  ),
                ],
              ),
            ),
          for (final mod in filtered.take(_visible))
            _GameModCard(
              key: ValueKey('game-mod-card-${mod.name}'),
              mod: mod,
              saving: _savingName == mod.name,
              showIdentity:
                  mods.where((other) => other.title == mod.title).length > 1,
              onChanged: _busy || installing || !mod.selectable
                  ? null
                  : (enabled) => _change(mod, enabled),
            ),
          if (filtered.length > _visible)
            _LibraryAction(
              label: l10n.gameModsMore,
              icon: Icons.expand_more_rounded,
              onPressed: () => setState(() => _visible += 20),
            ),
        ],
      ],
    );
  }
}

class _LibraryNotice extends StatelessWidget {
  const _LibraryNotice({
    required this.message,
    required this.icon,
    this.warning = false,
  });
  final String message;
  final IconData icon;
  final bool warning;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: retro.gameDecoration(
        BoxDecoration(
          color: retro.surfaceAlt,
          borderRadius: retro.radius,
          border: Border(
            left: BorderSide(
              color: warning ? retro.amber : retro.accent,
              width: retro.borderWidth(3),
            ),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarioGameIcon(icon, size: 18, color: retro.inkDim),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: retro.body(size: 12, height: 1.45)),
          ),
        ],
      ),
    );
  }
}

class _LibraryAction extends StatelessWidget {
  const _LibraryAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final color = primary ? retro.accent : retro.surface;
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: retro.surfaceDecoration(
              color: color,
              shadowDx: 2,
              shadowDy: 2,
            ),
            child: InkWell(
              borderRadius: retro.radius,
              onTap: onPressed,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MarioGameIcon(
                        icon,
                        color: primary ? retro.inkOnAccent : retro.accentText,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          retro.displayLabel(label),
                          textAlign: TextAlign.center,
                          style: retro.heading(
                            size: 13,
                            color: primary ? retro.inkOnAccent : retro.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameModCard extends StatelessWidget {
  const _GameModCard({
    super.key,
    required this.mod,
    required this.saving,
    required this.onChanged,
    required this.showIdentity,
  });
  final GameModEntry mod;
  final bool saving;
  final bool showIdentity;
  final ValueChanged<bool>? onChanged;
  Future<void> _showDetails(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final retro = RetroTheme.of(context);
        final l10n = AppLocalizations.of(context);
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionKicker(retro: retro, label: l10n.gameModsDetails),
                  const SizedBox(height: 18),
                  Text(
                    mod.title.isEmpty ? mod.name : mod.title,
                    style: retro.heading(size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mod.name,
                    style: retro.body(size: 12, color: retro.inkDim),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (mod.versionLabel != null)
                        _GameMetadata(
                          icon: Icons.sell_outlined,
                          label: mod.versionLabel!,
                        ),
                      if (mod.author != null)
                        _GameMetadata(
                          icon: Icons.person_outline_rounded,
                          label: mod.author!,
                        ),
                      if (mod.category != null)
                        _GameMetadata(
                          icon: Icons.category_outlined,
                          label: mod.category!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    mod.description ?? '',
                    style: retro.body(size: 14, color: retro.ink),
                  ),
                  const SizedBox(height: 20),
                  _LibraryAction(
                    label: l10n.gameModsCloseDetails,
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: retro.surfaceDecoration(
        borderColor: mod.enabled
            ? retro.accent
            : retro.border.withValues(alpha: 0.45),
        shadowDx: 3,
        shadowDy: 3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: retro.gameDecoration(
                  BoxDecoration(
                    color: retro.surfaceAlt,
                    borderRadius: retro.radius,
                  ),
                ),
                child: MarioMenuGlyph(
                  retro: retro,
                  asset: mod.enabled ? 'hand_pressed' : 'hand',
                  fallback: mod.enabled && retro.design.playfulSelection
                      ? Icons.star_rounded
                      : Icons.extension_rounded,
                  size: 24,
                  color: mod.enabled ? retro.accentText : retro.inkDim,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mod.title.isEmpty ? mod.name : mod.title,
                      style: retro.heading(size: 16),
                    ),
                    if (showIdentity) ...[
                      const SizedBox(height: 4),
                      Text(
                        mod.name,
                        style: retro.body(size: 11, color: retro.inkDim),
                      ),
                    ],
                  ],
                ),
              ),
              if (saving)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: retro.accent,
                    ),
                  ),
                ),
              if (!saving)
                Semantics(
                  label: mod.title,
                  child: retro.isMario && retro.marioAssets.complete
                      ? MarioGameToggle(
                          key: ValueKey('game-mod-switch-${mod.name}'),
                          value: mod.enabled,
                          onChanged: onChanged,
                        )
                      : Switch(
                          key: ValueKey('game-mod-switch-${mod.name}'),
                          value: mod.enabled,
                          onChanged: onChanged,
                          activeTrackColor: retro.accent,
                          activeThumbColor: retro.inkOnAccent,
                          inactiveTrackColor: retro.surfaceAlt,
                          inactiveThumbColor: retro.inkDim,
                          trackOutlineColor: WidgetStatePropertyAll(
                            retro.border,
                          ),
                          thumbIcon: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? Icon(
                                    retro.design.playfulSelection
                                        ? Icons.star_rounded
                                        : Icons.check_rounded,
                                    size: 16,
                                    color: retro.accentText,
                                  )
                                : null,
                          ),
                        ),
                ),
            ],
          ),
          if (mod.versionLabel != null ||
              mod.author != null ||
              mod.category != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (mod.versionLabel != null)
                  _GameMetadata(
                    icon: Icons.sell_outlined,
                    label: mod.versionLabel!,
                  ),
                if (mod.author != null)
                  _GameMetadata(
                    icon: Icons.person_outline_rounded,
                    label: mod.author!,
                  ),
                if (mod.category != null)
                  _GameMetadata(
                    icon: Icons.category_outlined,
                    label: mod.category!,
                  ),
              ],
            ),
          ],
          if (mod.description != null) ...[
            const SizedBox(height: 10),
            Text(
              mod.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: retro.body(size: 12),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => _showDetails(context),
                icon: const MarioGameIcon(Icons.description_outlined, size: 16),
                label: Text(l10n.gameModsDetails),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarioGameIcon(
                !mod.selectable
                    ? Icons.lock_outline_rounded
                    : mod.enabled
                    ? Icons.check_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
                size: 16,
                color: retro.inkDim,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  !mod.selectable
                      ? l10n.gameModsBlocked
                      : mod.enabled
                      ? l10n.gameModsEnabled
                      : l10n.gameModsDisabled,
                  style: retro.body(size: 11.5, color: retro.inkDim),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameMetadata extends StatelessWidget {
  const _GameMetadata({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MarioGameIcon(icon, size: 14, color: retro.inkDim),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: retro.body(size: 11.5, color: retro.inkDim),
          ),
        ),
      ],
    );
  }
}
