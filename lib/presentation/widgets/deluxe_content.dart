import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../domain/entities/mod_entity.dart';
import '../../l10n/app_localizations.dart';
import '../../services/deluxe_links.dart';
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

class DeluxeWelcomePanel extends StatelessWidget {
  const DeluxeWelcomePanel({super.key});
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        key: const ValueKey('deluxe-welcome'),
        padding: const EdgeInsets.all(16),
        decoration: retro.surfaceDecoration(color: retro.surface.withValues(alpha: 0.96)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset('assets/themes/manga_deluxe/coopdx.webp', width: 164, height: 82,
            cacheWidth: 328, excludeFromSemantics: true),
          const SizedBox(height: 8),
          Text(l.deluxeWelcome, style: retro.heading(size: 20)),
          const SizedBox(height: 6),
          Text(l.deluxeWelcomeBody, style: retro.body(size: 14)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(onPressed: () => context.go('/how-to-play'),
              icon: const Icon(Icons.menu_book_outlined), label: Text(l.playGuideTitle)),
            OutlinedButton.icon(onPressed: () => _open(context, AppConstants.officialweb),
              icon: const Icon(Icons.public), label: Text(l.linksWebsite)),
          ]),
        ]),
      ),
    );
  }
}

class DeluxeFeaturedStory extends StatelessWidget {
  const DeluxeFeaturedStory({super.key, required this.mod});
  final ModEntity mod;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Container(
        key: const ValueKey('deluxe-editorial'),
        padding: const EdgeInsets.all(16), decoration: retro.surfaceDecoration(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.deluxeSpotlight, style: retro.heading(size: 12, color: retro.accentText)),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (mod.imageUrl?.isNotEmpty == true) ...[
              SizedBox(width: 64, height: 64, child: CachedNetworkImage(
                imageUrl: mod.imageUrl!, memCacheWidth: 128, fit: BoxFit.cover,
                errorWidget: (_, _, _) => Icon(Icons.landscape, color: retro.accentText),
              )),
              const SizedBox(width: 12),
            ],
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mod.title, style: retro.heading(size: 18)),
              const SizedBox(height: 4),
              Text(mod.author, style: retro.body(size: 12, color: retro.inkDim)),
            ])),
          ]),
          const SizedBox(height: 12),
          Text(l.deluxeDncBody, style: retro.body(size: 14)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton(onPressed: () => context.push('/mod/${Uri.encodeComponent(mod.id)}'),
              child: Text(l.deluxeViewMod)),
            const DeluxeDemoButton(),
          ]),
          Text(l.deluxeDemoHint, style: retro.body(size: 12, color: retro.inkDim)),
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
