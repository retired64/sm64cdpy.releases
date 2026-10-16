import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/player_profile.dart';
import '../../l10n/app_localizations.dart';
import '../providers/player_profile_provider.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/player_3d_preview.dart';
import '../widgets/settings_expansion_group.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});
  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with WidgetsBindingObserver {
  final _name = TextEditingController();
  final _nameFocus = FocusNode();
  PlayerPart _part = PlayerPart.cap;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !ref.read(playerProfileProvider).dirty) {
      ref.read(playerProfileProvider.notifier).load(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerProfileProvider);
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref.read(playerProfileProvider.notifier).load();
        if (!mounted) return;
      });
    }
    final draft = state.draft;
    if (draft != null && _name.text != draft.name && !_nameFocus.hasFocus) {
      _name.text = draft.name;
    }
    return PopScope(
      canPop: !state.dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && state.dirty) _confirmDiscard();
      },
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(playerProfileProvider.notifier).load(force: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            RetroPinnedAppBar(
              title: Text(
                l10n.playerTitle,
                style: retro.heading(size: 18, color: retro.accentText),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 96),
              sliver: SliverList.list(
                children: [
                  if (state.busy && draft == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (draft == null && !state.busy)
                    _Unavailable(
                      status: state.status,
                      onRetry: () async {
                        if (state.status == 'unselected') {
                          context.go('/settings');
                        } else {
                          await ref
                              .read(playerProfileProvider.notifier)
                              .load(force: true);
                        }
                      },
                    ),
                  if (draft != null) ...[
                    _PlayerPreview(profile: draft),
                    const SizedBox(height: 12),
                    SectionKicker(
                      retro: retro,
                      label: retro.displayLabel(l10n.playerCharacter),
                    ),
                    const SizedBox(height: 8),
                    _ModelSelector(
                      model: draft.model,
                      onChanged: ref
                          .read(playerProfileProvider.notifier)
                          .setModel,
                    ),
                    const SizedBox(height: 12),
                    SectionKicker(
                      retro: retro,
                      label: retro.displayLabel(l10n.playerName),
                    ),
                    const SizedBox(height: 8),
                    _Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _name,
                            focusNode: _nameFocus,
                            maxLength: 63,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: l10n.playerNameHint,
                              counterText: '',
                            ),
                            onChanged: ref
                                .read(playerProfileProvider.notifier)
                                .setName,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.playerCloseGameHint,
                            style: TextStyle(color: retro.inkDim, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SectionKicker(
                      retro: retro,
                      label: retro.displayLabel(l10n.playerPresets),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.presets.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final preset = state.presets[index];
                          final selected = preset.palette == draft.palette;
                          return _PresetCard(
                            preset: preset,
                            selected: selected,
                            onTap: () => ref
                                .read(playerProfileProvider.notifier)
                                .usePreset(preset),
                            onLongPress: preset.writable
                                ? () => _deletePreset(preset)
                                : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    SectionKicker(
                      retro: retro,
                      label: retro.displayLabel(l10n.playerParts),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3.35,
                            crossAxisSpacing: 7,
                            mainAxisSpacing: 7,
                          ),
                      itemCount: PlayerPart.values.length,
                      itemBuilder: (_, index) {
                        final part = PlayerPart.values[index];
                        return _PartTile(
                          part: part,
                          color: draft.palette[part],
                          selected: part == _part,
                          onTap: () => setState(() => _part = part),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ColorEditor(
                      part: _part,
                      color: draft.palette[_part],
                      onChanged: (color) => ref
                          .read(playerProfileProvider.notifier)
                          .setColor(_part, color),
                    ),
                    const SizedBox(height: 14),
                    _PlayerActions(
                      busy: state.busy,
                      dirty: state.dirty,
                      backupAvailable: state.backupAvailable,
                      onReset: ref.read(playerProfileProvider.notifier).reset,
                      onSavePreset: _savePreset,
                      onApply: _apply,
                      onRestore: _restore,
                    ),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _errorMessage(l10n, state.error!),
                          style: TextStyle(
                            color: retro.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.playerUnsavedTitle),
        content: Text(l10n.playerUnsavedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.playerKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.playerDiscard),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (discard == true) {
      ref.read(playerProfileProvider.notifier).reset();
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _deletePreset(PlayerPalettePreset preset) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.playerDeletePreset),
        content: Text(l10n.playerDeletePresetBody(preset.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.playerCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.playerDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(playerProfileProvider.notifier).deletePalette(preset.id);
    }
  }

  String _errorMessage(AppLocalizations l10n, String code) => switch (code) {
    'conflict' => l10n.playerConflict,
    'invalid' => l10n.playerInvalid,
    'exists' => l10n.playerPresetExists,
    'installing' => l10n.gameModsInstalling,
    'write' || 'verify' => l10n.gameModsWriteError,
    _ => l10n.playerAccessError,
  };

  Future<void> _savePreset() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.playerSavePreset),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 63,
          decoration: InputDecoration(labelText: l10n.playerPresetName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.playerCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.playerSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    var success = await ref
        .read(playerProfileProvider.notifier)
        .savePalette(name);
    if (!success &&
        ref.read(playerProfileProvider).error == 'exists' &&
        mounted) {
      final overwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.playerPresetExists),
          content: Text(l10n.playerOverwritePreset(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.playerCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.playerOverwrite),
            ),
          ],
        ),
      );
      if (overwrite == true) {
        success = await ref
            .read(playerProfileProvider.notifier)
            .savePalette(name, overwrite: true);
      }
    }
    if (success && mounted) {
      AppSnackbar.success(context, message: l10n.playerPresetSaved);
    }
  }

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    if (_name.text.trim() != _name.text ||
        _name.text.trim().isEmpty ||
        _name.text.contains(RegExp(r'\s')) ||
        utf8.encode(_name.text).length > 63) {
      AppSnackbar.error(context, message: l10n.playerInvalid);
      return;
    }
    final success = await ref.read(playerProfileProvider.notifier).apply();
    if (success && mounted) {
      AppSnackbar.success(context, message: l10n.playerApplied);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.playerRestore),
        content: Text(l10n.playerRestoreBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.playerCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.playerRestore),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final restored = await ref.read(playerProfileProvider.notifier).restore();
    if (restored && mounted) {
      AppSnackbar.success(context, message: l10n.playerRestored);
    }
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: retro.settingsPanel(width: 2, dx: 4, dy: 4),
      child: child,
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.status, required this.onRetry});
  final String status;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Panel(
      child: Column(
        children: [
          Icon(Icons.sports_esports, size: 48),
          const SizedBox(height: 12),
          Text(
            status == 'unselected'
                ? l10n.playerConnectGame
                : status == 'missing'
                ? l10n.playerMissingConfig
                : l10n.playerAccessError,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.playerRetry),
          ),
        ],
      ),
    );
  }
}

class _PlayerPreview extends StatelessWidget {
  const _PlayerPreview({required this.profile});
  final PlayerProfile profile;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 310,
      decoration: retro.settingsPanel(width: 3, dx: 5, dy: 5),
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ThemeBackdrop(menuSurface: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 42),
              child: Player3DPreview(
                profile: profile,
                loadingLabel: l10n.player3DLoading,
                unavailableLabel: l10n.player3DUnavailable,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Text(
                profile.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: retro.heading(size: 20, color: retro.accentText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  const _ModelSelector({required this.model, required this.onChanged});

  final int model;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    const names = ['Mario', 'Luigi', 'Toad', 'Waluigi', 'Wario'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(5, 2, 8, 5),
        itemCount: names.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => Semantics(
          button: true,
          selected: model == index,
          label: names[index],
          child: SkewChip(
            retro: retro,
            label: names[index],
            icon: model == index ? Icons.sports_esports : Icons.person_outline,
            selected: model == index,
            dense: true,
            onTap: () => onChanged(index),
          ),
        ),
      ),
    );
  }
}

class _PlayerActions extends StatelessWidget {
  const _PlayerActions({
    required this.busy,
    required this.dirty,
    required this.backupAvailable,
    required this.onReset,
    required this.onSavePreset,
    required this.onApply,
    required this.onRestore,
  });

  final bool busy;
  final bool dirty;
  final bool backupAvailable;
  final VoidCallback onReset;
  final VoidCallback onSavePreset;
  final VoidCallback onApply;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: busy || !dirty ? null : onApply,
            icon: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(l10n.playerApply),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy || !dirty ? null : onReset,
                  icon: const Icon(Icons.undo, size: 18),
                  label: Text(
                    l10n.playerReset,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onSavePreset,
                  icon: const Icon(Icons.palette_outlined, size: 18),
                  label: Text(
                    l10n.playerSavePreset,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          if (backupAvailable) ...[
            const SizedBox(height: 2),
            TextButton.icon(
              onPressed: busy ? null : onRestore,
              icon: const Icon(Icons.history, size: 18),
              label: Text(l10n.playerRestore),
            ),
          ],
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });
  final PlayerPalettePreset preset;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Semantics(
      selected: selected,
      button: true,
      label: preset.name,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: 108,
          padding: const EdgeInsets.all(8),
          decoration: retro.surfaceDecoration(
            borderColor: selected ? retro.accent : retro.border,
            border: selected ? 3 : 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preset.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: preset.palette.colors
                    .take(6)
                    .map(
                      (c) => Expanded(
                        child: Container(height: 14, color: Color(c)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartTile extends StatelessWidget {
  const _PartTile({
    required this.part,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final PlayerPart part;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final label = _partLabel(AppLocalizations.of(context), part);
    return Semantics(
      button: true,
      selected: selected,
      label: '$label ${_hex(color)}',
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: retro.surfaceDecoration(
            borderColor: selected ? retro.accent : retro.border,
            border: selected ? 3 : 2,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: retro.ink, width: 2),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _hex(color),
                      style: TextStyle(fontSize: 11, color: retro.inkDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorEditor extends StatefulWidget {
  const _ColorEditor({
    required this.part,
    required this.color,
    required this.onChanged,
  });
  final PlayerPart part;
  final Color color;
  final ValueChanged<Color> onChanged;
  @override
  State<_ColorEditor> createState() => _ColorEditorState();
}

class _ColorEditorState extends State<_ColorEditor> {
  late final TextEditingController _hexController;
  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(text: _hex(widget.color));
  }

  @override
  void didUpdateWidget(covariant _ColorEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = _hex(widget.color);
    if (_hexController.text.toUpperCase() != value) _hexController.text = value;
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _partLabel(l10n, widget.part),
            style: RetroTheme.of(context).heading(size: 16),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: RetroTheme.of(context).ink,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _hexController,
                  maxLength: 7,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.playerHex,
                    counterText: '',
                    isDense: true,
                  ),
                  onSubmitted: _submitHex,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _channel(
            l10n.playerRed,
            widget.color.r,
            (v) => widget.onChanged(widget.color.withValues(red: v)),
          ),
          _channel(
            l10n.playerGreen,
            widget.color.g,
            (v) => widget.onChanged(widget.color.withValues(green: v)),
          ),
          _channel(
            l10n.playerBlue,
            widget.color.b,
            (v) => widget.onChanged(widget.color.withValues(blue: v)),
          ),
        ],
      ),
    );
  }

  void _submitHex(String value) {
    final match = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(value.trim());
    if (match != null) {
      widget.onChanged(
        Color(0xFF000000 | int.parse(match.group(1)!, radix: 16)),
      );
    }
  }

  Widget _channel(String label, double value, ValueChanged<double> onChanged) =>
      SizedBox(
        height: 42,
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(
                '$label ${(value * 255).round()}',
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Expanded(
              child: Slider(value: value, onChanged: onChanged),
            ),
          ],
        ),
      );
}

String _hex(Color color) =>
    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
String _partLabel(AppLocalizations l10n, PlayerPart part) => switch (part) {
  PlayerPart.pants => l10n.playerPants,
  PlayerPart.shirt => l10n.playerShirt,
  PlayerPart.gloves => l10n.playerGloves,
  PlayerPart.shoes => l10n.playerShoes,
  PlayerPart.hair => l10n.playerHair,
  PlayerPart.skin => l10n.playerSkin,
  PlayerPart.cap => l10n.playerCap,
  PlayerPart.emblem => l10n.playerEmblem,
};
