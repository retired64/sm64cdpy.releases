import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/deluxe_links.dart';
import '../providers/deluxe_visual_provider.dart';
import 'app_snackbar.dart';

Future<void> _open(BuildContext context, String url) async {
  final opened = await DeluxeLinks.open(url);
  if (!context.mounted || opened) return;
  AppSnackbar.error(context, message: AppLocalizations.of(context).deluxeLinkError);
}

class DeluxeDemoButton extends StatefulWidget {
  const DeluxeDemoButton({super.key});
  @override
  State<DeluxeDemoButton> createState() => _DeluxeDemoButtonState();
}
class _DeluxeDemoButtonState extends State<DeluxeDemoButton> {
  bool _opening = false;
  Future<void> _play() async {
    if (_opening) return;
    setState(() => _opening = true);
    try { await _open(context, DeluxeLinks.demoUrl); }
    finally { if (mounted) setState(() => _opening = false); }
  }
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const ValueKey('deluxe-demo'),
    onPressed: _opening ? null : _play,
    icon: const Icon(Icons.play_circle_outline),
    label: Text(AppLocalizations.of(context).deluxeWatchDemo),
  );
}

class DeluxeWelcomePanel extends ConsumerStatefulWidget {
  const DeluxeWelcomePanel({super.key});

  @override
  ConsumerState<DeluxeWelcomePanel> createState() => _DeluxeWelcomePanelState();
}

class _DeluxeWelcomePanelState extends ConsumerState<DeluxeWelcomePanel> {
  bool _saving = false;

  Future<void> _dismiss() async {
    if (_saving) return;
    setState(() => _saving = true);
    final saved = await ref.read(deluxeWelcomeHiddenProvider.notifier).dismiss();
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) {
      AppSnackbar.error(context,
          message: AppLocalizations.of(context).themeSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(deluxeWelcomeHiddenProvider)) return const SizedBox.shrink();
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        key: const ValueKey('deluxe-welcome'),
        padding: const EdgeInsets.all(12),
        decoration: retro.surfaceDecoration(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Image.asset('assets/themes/manga_deluxe/coopdx.webp',
                width: 64, height: 36, cacheWidth: 192,
                excludeFromSemantics: true),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.deluxeWelcome, style: retro.heading(size: 17)),
                const SizedBox(height: 4),
                Text(l.deluxeWelcomeCompact, style: retro.body(size: 13)),
              ],
            )),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 4, children: [
            FilledButton.icon(
              onPressed: _saving ? null : () => context.go('/how-to-play'),
              icon: const Icon(Icons.menu_book_outlined, size: 18),
              label: Text(l.playGuideTitle),
            ),
            Tooltip(
              message: l.deluxeSkipHint,
              child: TextButton(
                key: const ValueKey('deluxe-skip'),
                style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48)),
                onPressed: _saving ? null : _dismiss,
                child: Text(l.deluxeSkip),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// Ayuda local y rutas existentes: no replica el flujo de ROM/carpeta del juego.
class DeluxeHelpPanel extends StatelessWidget {
  const DeluxeHelpPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      key: const ValueKey('deluxe-help'),
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: retro.surfaceDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: const EdgeInsets.all(16),
          child: Text(l.deluxeHelpTitle, style: retro.heading(size: 18))),
        for (final item in [
          (l.deluxeFaqRom, l.deluxeFaqRomAnswer, '/how-to-play?step=1'),
          (l.deluxeFaqFolders, l.deluxeFaqFoldersAnswer, '/how-to-play?step=3'),
          (l.deluxeFaqPacks, l.deluxeFaqPacksAnswer, '/library'),
        ])
          ExpansionTile(title: Text(item.$1, style: retro.body(size: 14, weight: FontWeight.w700)),
            children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.$2, style: retro.body(size: 14)),
                TextButton(onPressed: () => context.go(item.$3), child: Text(l.deluxeOpenGuide)),
              ]))]),
        Padding(padding: const EdgeInsets.all(12), child: Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(onPressed: () => context.go('/links-resource'),
            icon: const Icon(Icons.people_outline), label: Text(l.deluxeCommunity)),
          OutlinedButton.icon(onPressed: () => _open(context, DeluxeLinks.gameReleases),
            icon: const Icon(Icons.new_releases_outlined), label: Text(l.deluxeGameNews)),
        ])),
      ]),
    );
  }
}
