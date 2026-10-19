import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/game_launcher_service.dart';
import '../providers/game_folder_provider.dart';
import '../providers/extra_providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/game_folder_card.dart';
import '../widgets/game_launch_flow.dart';
import '../widgets/game_setup_widgets.dart';

class HowToPlayScreen extends ConsumerStatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  ConsumerState<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends ConsumerState<HowToPlayScreen>
    with WidgetsBindingObserver {
  final _scroll = ScrollController();
  int _step = 0;
  bool? _installed;
  bool _busy = false;
  int _refreshRevision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Both operations handle errors internally. Recheck after external setup.
    unawaited(_refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final revision = ++_refreshRevision;
    try {
      final installed = await GameLauncherService.isInstalled();
      if (!mounted || revision != _refreshRevision) return;
      ref.read(gameInstalledProvider.notifier).setInstalled(installed);
      setState(() => _installed = installed);
      await ref.read(gameFolderProvider.notifier).refresh();
    } catch (_) {
      // A failed check leaves the existing status; it never marks setup done.
    }
  }

  Future<void> _action(Future<void> Function() run) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await run();
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          message: AppLocalizations.of(context).playGuideLinkError,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) throw StateError('External page unavailable');
  }

  void _select(int step) {
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    ++_refreshRevision;
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final folder = ref.watch(gameFolderProvider);
    final titles = [
      l10n.playGuideStep1Title,
      l10n.playGuideStep2Title,
      l10n.playGuideStep3Title,
      l10n.playGuideStep4Title,
      l10n.playGuideStep5Title,
      l10n.playGuideStep6Title,
    ];
    final bodies = [
      l10n.playGuideStep1Body,
      l10n.playGuideStep2Body,
      l10n.playGuideStep3Body,
      l10n.playGuideStep4Body,
      l10n.playGuideStep5Body,
      l10n.playGuideStep6Body,
    ];
    const icons = [
      Icons.downloading_rounded,
      Icons.sd_storage_outlined,
      Icons.sports_esports_outlined,
      Icons.folder_open_rounded,
      Icons.extension_outlined,
      Icons.flag_outlined,
    ];
    Widget action(String label, IconData icon, Future<void> Function() run,
            {bool primary = false}) =>
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: GameSetupAction(
            label: label,
            icon: icon,
            primary: primary,
            onPressed: _busy ? null : () => _action(run),
          ),
        );
    return CustomScrollView(
      controller: _scroll,
      slivers: [
        RetroPinnedAppBar(
          title: Text(l10n.playGuideTitle, style: retro.heading(size: 22)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.playGuideIntro, style: retro.body(size: 16)),
                    const SizedBox(height: 18),
                    Text(l10n.playGuideSteps, style: retro.heading(size: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(titles.length, (i) => ChoiceChip(
                        label: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: (MediaQuery.sizeOf(context).width - 120).clamp(100, 240).toDouble()),
                          child: Text('${i + 1}. ${titles[i]}'),
                        ),
                        selected: _step == i,
                        onSelected: (_) => _select(i),
                      )),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      key: ValueKey(_step),
                      padding: const EdgeInsets.all(18),
                      decoration: retro.surfaceDecoration(shadowDx: 3, shadowDy: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            MarioGameIcon(icons[_step], size: 30, color: retro.accentText),
                            const SizedBox(width: 12),
                            Expanded(child: Text('${_step + 1}. ${titles[_step]}',
                                style: retro.heading(size: 22))),
                          ]),
                          const SizedBox(height: 18),
                          SelectableText(bodies[_step], style: retro.body(size: 16, height: 1.55)),
                          if (_step == 0) ...[
                            if (_installed != null)
                              GameSetupStatus(
                                label: _installed! ? l10n.playGuideInstalled : l10n.playGuideNotInstalled,
                                icon: Icons.sports_esports_outlined,
                                ready: _installed,
                              ),
                            action(l10n.playGuideOpenDownload, Icons.open_in_browser,
                                () => _open(AppConstants.androidGameReleasesUrl), primary: true),
                            action(l10n.playGuideRepository, Icons.code,
                                () => _open(AppConstants.maniscat2Github)),
                          ],
                          if (_step == 1)
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: Text(l10n.playGuideConvertTitle, style: retro.heading(size: 17)),
                              children: [
                                SelectableText(l10n.playGuideConvertBody,
                                    style: retro.body(size: 16, height: 1.55)),
                                action(l10n.playGuideConverter, Icons.swap_horiz,
                                    () => _open(AppConstants.romConverterUrl)),
                              ],
                            ),
                          if (_step == 2 || _step == 5)
                            action(l10n.playGuideLaunch, Icons.play_arrow_rounded,
                                () => launchGameWithGuide(context), primary: true),
                          if (_step == 3) ...[
                            if (folder.initialized)
                              GameSetupStatus(
                                label: folder.connection.connected && folder.connection.fullAccess
                                    ? l10n.playGuideConnected : l10n.playGuideNotConnected,
                                icon: Icons.folder_open_rounded,
                                ready: folder.connection.connected && folder.connection.fullAccess,
                              ),
                            action(l10n.playGuideConnect, Icons.folder_open_rounded, () async {
                              await connectGameFolder(context, ref);
                            }, primary: true),
                          ],
                          if (_step == 4) ...[
                            action(l10n.playGuideLibrary, Icons.inventory_2_outlined, () async {
                              context.go('/library?view=game-mods');
                            }, primary: true),
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: Text(l10n.playGuidePathsTitle, style: retro.heading(size: 17)),
                              children: [SelectableText(l10n.playGuidePathsBody,
                                  style: retro.body(size: 16, height: 1.55))],
                            ),
                          ],
                          if (_step == 5) ...[
                            const SizedBox(height: 18),
                            Text(l10n.playGuideReady, style: retro.body(size: 16)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_step < 5)
                      GameSetupAction(
                        label: l10n.playGuideNext,
                        icon: Icons.arrow_forward_rounded,
                        primary: true,
                        onPressed: _busy ? null : () => _select(_step + 1),
                      ),
                    if (_step > 0) ...[
                      const SizedBox(height: 12),
                      GameSetupAction(
                        label: l10n.playGuideBack,
                        icon: Icons.arrow_back_rounded,
                        onPressed: _busy ? null : () => _select(_step - 1),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
