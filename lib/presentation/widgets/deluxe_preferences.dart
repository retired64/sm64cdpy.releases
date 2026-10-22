import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_accent.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_audio_settings_provider.dart';
import '../providers/deluxe_visual_provider.dart';
import '../providers/manga_menu_audio_provider.dart';
import '../providers/retro_accent_provider.dart';
import 'app_snackbar.dart';
import 'manga_switch.dart';

class DeluxePreferences extends ConsumerStatefulWidget {
  const DeluxePreferences({super.key});
  @override
  ConsumerState<DeluxePreferences> createState() => _DeluxePreferencesState();
}
class _DeluxePreferencesState extends ConsumerState<DeluxePreferences> {
  bool _saving = false;
  Future<void> _motion(bool value) async {
    setState(() => _saving = true);
    final saved = await ref.read(deluxeMotionProvider.notifier).select(value);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) AppSnackbar.error(context, message: AppLocalizations.of(context).themeSaveFailed);
  }
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isDeluxe) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context) || MediaQuery.accessibleNavigationOf(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: retro.surfaceDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ThemedSwitchListTile(
          key: const ValueKey('deluxe-motion'),
          title: Text(l.deluxeMotion, style: retro.heading(size: 14)),
          subtitle: Text(reduce ? l.deluxeReducedMotion : l.deluxeMotionHint, style: retro.body(size: 12)),
          value: ref.watch(deluxeMotionProvider),
          onChanged: _saving || reduce ? null : _motion,
          secondary: Icon(Icons.texture, color: retro.accentText),
        ),
      ]),
    );
  }
}

/// El reset que incluye audio vive en su submenú, no en Ajustes de apariencia.
class DeluxeResetButton extends ConsumerStatefulWidget {
  const DeluxeResetButton({super.key});
  @override
  ConsumerState<DeluxeResetButton> createState() => _DeluxeResetButtonState();
}
class _DeluxeResetButtonState extends ConsumerState<DeluxeResetButton> {
  bool _saving = false;
  Future<void> _reset() async {
    setState(() => _saving = true);
    var saved = true;
    try {
      // Usar cada escritor canónico; nunca borrar la caja de ajustes completa.
      saved = await ref.read(deluxeMotionProvider.notifier).select(false) && saved;
      if (!mounted) return;
      saved = await ref.read(retroAccentProvider.notifier).select(RetroAccent.cyan) && saved;
      if (!mounted) return;
      final mix = ref.read(appAudioSettingsProvider.notifier);
      saved = await mix.setEffectsVolume(0.65) && saved;
      if (!mounted) return;
      saved = await mix.setMusicVolume(0.18) && saved;
      if (!mounted) return;
      saved = await mix.setMusicEnabled(true) && saved;
      if (!mounted) return;
      saved = await ref.read(mangaMenuSoundsProvider.notifier).setEnabled(true) && saved;
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      if (saved) AppSnackbar.success(context, message: l.deluxeResetDone);
      else AppSnackbar.error(context, message: l.themeSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isDeluxe) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l.deluxeResetHint, style: retro.body(size: 12, color: retro.inkDim))),
        Padding(padding: const EdgeInsets.all(12), child: OutlinedButton.icon(
          key: const ValueKey('deluxe-reset'),
          onPressed: _saving ? null : _reset,
          icon: const Icon(Icons.restore), label: Text(l.deluxeReset),
        )),
      ]),
    );
  }
}
