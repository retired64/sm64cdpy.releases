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
import '../widgets/play_guide_widgets.dart';

class HowToPlayScreen extends ConsumerStatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  ConsumerState<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends ConsumerState<HowToPlayScreen>
    with WidgetsBindingObserver {
  final _pages = PageController();
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
    if (_busy || !_pages.hasClients) return;
    _pages.jumpToPage(step);
  }

  Future<void> _overview(List<String> titles) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: RetroTheme.of(context).background,
      builder: (sheetContext) {
        final retro = RetroTheme.of(sheetContext);
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.8,
            child: ListView(
              primary: false,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Text(l10n.playGuideMap, style: retro.heading(size: 22)),
                const SizedBox(height: 12),
                Text(l10n.playGuideIntro, style: retro.body(size: 16)),
                const SizedBox(height: 16),
                for (var i = 0; i < titles.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      key: ValueKey('guide-map-$i'),
                      shape: RoundedRectangleBorder(
                        borderRadius: retro.radius,
                        side: BorderSide(
                          color: retro.border,
                          width: retro.borderWidth(1),
                        ),
                      ),
                      tileColor: i == _step ? retro.accent : retro.surface,
                      textColor: i == _step ? retro.inkOnAccent : retro.ink,
                      leading: Text(
                        '${i + 1}',
                        style: retro.heading(
                          size: 22,
                          color: i == _step
                              ? retro.inkOnAccent
                              : retro.accentText,
                        ),
                      ),
                      title: Text(
                        titles[i],
                        style: retro.body(
                          size: 16,
                          color: i == _step ? retro.inkOnAccent : retro.ink,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_rounded,
                        color: i == _step ? retro.inkOnAccent : retro.ink,
                      ),
                      onTap: () => Navigator.pop(sheetContext, i),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (mounted && selected != null) _select(selected);
  }

  @override
  void dispose() {
    ++_refreshRevision;
    WidgetsBinding.instance.removeObserver(this);
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final folder = ref.watch(gameFolderProvider);
    final connected =
        folder.connection.connected && folder.connection.fullAccess;
    final titles = [
      l10n.playGuideStep1Title,
      l10n.playGuideStep2Title,
      l10n.playGuideStep3Title,
      l10n.playGuideStep4Title,
      l10n.playGuideStep5Title,
      l10n.playGuideStep6Title,
    ];
    final cards = [
      [
        l10n.playGuideS1Card1,
        l10n.playGuideS1Card2,
        l10n.playGuideS1Card3,
        l10n.playGuideS1Card4,
        l10n.playGuideS1Card5,
        l10n.playGuideS1Card6,
      ],
      [
        l10n.playGuideS2Card1,
        l10n.playGuideS2Card2,
        l10n.playGuideS2Card3,
        l10n.playGuideS2Card4,
        l10n.playGuideS2Card5,
      ],
      [
        l10n.playGuideS3Card1,
        l10n.playGuideS3Card2,
        l10n.playGuideS3Card3,
        l10n.playGuideS3Card4,
        l10n.playGuideS3Card5,
      ],
      [
        l10n.playGuideS4Card1,
        l10n.playGuideS4Card2,
        l10n.playGuideS4Card3,
        l10n.playGuideS4Card4,
        l10n.playGuideS4Card5,
      ],
      [
        l10n.playGuideS5Card1,
        l10n.playGuideS5Card2,
        l10n.playGuideS5Card3,
        l10n.playGuideS5Card4,
        l10n.playGuideS5Card5,
      ],
      [
        l10n.playGuideS6Card1,
        l10n.playGuideS6Card2,
        l10n.playGuideS6Card3,
        l10n.playGuideS6Card4,
        l10n.playGuideS6Card5,
        l10n.playGuideS6Card6,
      ],
    ];
    final cardTitles = [
      [
        l10n.playGuideS1Title1,
        l10n.playGuideS1Title2,
        l10n.playGuideS1Title3,
        l10n.playGuideS1Title4,
        l10n.playGuideS1Title5,
        l10n.playGuideS1Title6,
      ],
      [
        l10n.playGuideS2Title1,
        l10n.playGuideS2Title2,
        l10n.playGuideS2Title3,
        l10n.playGuideS2Title4,
        l10n.playGuideS2Title5,
      ],
      [
        l10n.playGuideS3Title1,
        l10n.playGuideS3Title2,
        l10n.playGuideS3Title3,
        l10n.playGuideS3Title4,
        l10n.playGuideS3Title5,
      ],
      [
        l10n.playGuideS4Title1,
        l10n.playGuideS4Title2,
        l10n.playGuideS4Title3,
        l10n.playGuideS4Title4,
        l10n.playGuideS4Title5,
      ],
      [
        l10n.playGuideS5Title1,
        l10n.playGuideS5Title2,
        l10n.playGuideS5Title3,
        l10n.playGuideS5Title4,
        l10n.playGuideS5Title5,
      ],
      [
        l10n.playGuideS6Title1,
        l10n.playGuideS6Title2,
        l10n.playGuideS6Title3,
        l10n.playGuideS6Title4,
        l10n.playGuideS6Title5,
        l10n.playGuideS6Title6,
      ],
    ];
    const icons = [
      Icons.downloading_rounded,
      Icons.sd_storage_outlined,
      Icons.sports_esports_outlined,
      Icons.folder_open_rounded,
      Icons.extension_outlined,
      Icons.flag_outlined,
    ];
    Widget action(
      String label,
      IconData icon,
      Future<void> Function() run, {
      bool primary = false,
    }) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GameSetupAction(
        label: label,
        icon: icon,
        primary: primary,
        onPressed: _busy ? null : () => _action(run),
      ),
    );
    return RetroFixedHeaderView(
      title: Text(l10n.playGuideTitle, style: retro.heading(size: 22)),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 400;
            return Column(
              children: [
                Container(
                  color: retro.background,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Column(
                    children: [
                      if (!compact)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.playGuideSwipe,
                                style: retro.body(size: 12),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _busy ? null : () => _overview(titles),
                              icon: const Icon(Icons.map_outlined, size: 18),
                              label: Text(l10n.playGuideOverview),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: PlayGuideRail(
                              titles: titles,
                              selected: _step,
                              onSelected: _busy ? null : _select,
                            ),
                          ),
                          if (compact)
                            IconButton(
                              tooltip: l10n.playGuideOverview,
                              onPressed: _busy ? null : () => _overview(titles),
                              icon: const Icon(Icons.map_outlined),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    key: const ValueKey('guide-pager'),
                    controller: _pages,
                    itemCount: titles.length,
                    physics: _busy
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                    onPageChanged: (page) => setState(() => _step = page),
                    itemBuilder: (context, index) => ListView(
                      key: PageStorageKey('guide-chapter-$index'),
                      primary: false,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 680),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PlayGuideChapter(
                                  number: index + 1,
                                  label: l10n.playGuideChapter,
                                  title: titles[index],
                                  icon: icons[index],
                                ),
                                if (index == 0) ...[
                                  if (_installed != null)
                                    GameSetupStatus(
                                      label: _installed!
                                          ? l10n.playGuideInstalled
                                          : l10n.playGuideNotInstalled,
                                      icon: Icons.sports_esports_outlined,
                                      ready: _installed,
                                    ),
                                  action(
                                    _installed == true
                                        ? l10n.playGuideLaunch
                                        : l10n.playGuideOpenDownload,
                                    _installed == true
                                        ? Icons.play_arrow_rounded
                                        : Icons.open_in_browser,
                                    _installed == true
                                        ? () => launchGameWithGuide(context)
                                        : () => _open(
                                            AppConstants.androidGameReleasesUrl,
                                          ),
                                    primary: true,
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      if (_installed == true)
                                        TextButton(
                                          onPressed: _busy
                                              ? null
                                              : () => _action(
                                                  () => _open(
                                                    AppConstants
                                                        .androidGameReleasesUrl,
                                                  ),
                                                ),
                                          child: Text(
                                            l10n.playGuideOpenDownload,
                                          ),
                                        ),
                                      TextButton.icon(
                                        onPressed: _busy
                                            ? null
                                            : () => _action(
                                                () => _open(
                                                  AppConstants.maniscat2Github,
                                                ),
                                              ),
                                        icon: const Icon(Icons.code, size: 18),
                                        label: Text(l10n.playGuideRepository),
                                      ),
                                    ],
                                  ),
                                ],
                                if (index == 1)
                                  ExpansionTile(
                                    key: const PageStorageKey('guide-conversion-help'),
                                    tilePadding: EdgeInsets.zero,
                                    title: Text(
                                      l10n.playGuideConvertTitle,
                                      style: retro.heading(size: 17),
                                    ),
                                    children: [
                                      Column(
                                        children: [
                                          PlayGuideCard(
                                            text: l10n.playGuideConvertCard1,
                                            number: 1,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuideConvertCard2,
                                            number: 2,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuideConvertCard3,
                                            number: 3,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuideConvertCard4,
                                            number: 4,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuideConvertCard5,
                                            number: 5,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuideConvertCard6,
                                            number: 6,
                                          ),
                                        ],
                                      ),
                                      action(
                                        l10n.playGuideConverter,
                                        Icons.swap_horiz,
                                        () =>
                                            _open(AppConstants.romConverterUrl),
                                      ),
                                    ],
                                  ),
                                if (index == 2)
                                  action(
                                    l10n.playGuideLaunch,
                                    Icons.play_arrow_rounded,
                                    () => launchGameWithGuide(context),
                                    primary: true,
                                  ),
                                if (index == 3) ...[
                                  if (folder.initialized)
                                    GameSetupStatus(
                                      label:
                                          folder.connection.connected &&
                                              folder.connection.fullAccess
                                          ? l10n.playGuideConnected
                                          : l10n.playGuideNotConnected,
                                      icon: Icons.folder_open_rounded,
                                      ready:
                                          folder.connection.connected &&
                                          folder.connection.fullAccess,
                                    ),
                                  action(
                                    connected
                                        ? l10n.playGuideLibrary
                                        : l10n.playGuideConnect,
                                    connected
                                        ? Icons.inventory_2_outlined
                                        : Icons.folder_open_rounded,
                                    () async {
                                      if (connected) {
                                        context.go('/library?view=game-mods');
                                      } else {
                                        await connectGameFolder(context, ref);
                                      }
                                    },
                                    primary: true,
                                  ),
                                  if (connected)
                                    TextButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _action(() async {
                                              await connectGameFolder(
                                                context,
                                                ref,
                                              );
                                            }),
                                      child: Text(l10n.gameFolderChange),
                                    ),
                                ],
                                if (index == 4) ...[
                                  action(
                                    l10n.playGuideLibrary,
                                    Icons.inventory_2_outlined,
                                    () async {
                                      context.go('/library?view=game-mods');
                                    },
                                    primary: true,
                                  ),
                                  ExpansionTile(
                                    key: const PageStorageKey('guide-paths-help'),
                                    tilePadding: EdgeInsets.zero,
                                    title: Text(
                                      l10n.playGuidePathsTitle,
                                      style: retro.heading(size: 17),
                                    ),
                                    children: [
                                      Column(
                                        children: [
                                          PlayGuideCard(
                                            text: l10n.playGuidePathsCard1,
                                            number: 1,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuidePathsCard2,
                                            number: 2,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuidePathsCard3,
                                            number: 3,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuidePathsCard4,
                                            number: 4,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuidePathsCard5,
                                            number: 5,
                                          ),
                                          PlayGuideCard(
                                            text: l10n.playGuidePathsCard6,
                                            number: 6,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                                if (index == 5) ...[
                                  const SizedBox(height: 18),
                                  Text(
                                    l10n.playGuideReady,
                                    style: retro.body(size: 16),
                                  ),
                                ],

                                const SizedBox(height: 20),
                                for (
                                  var card = 0;
                                  card < cards[index].length;
                                  card++
                                )
                                  PlayGuideCard(
                                    text: cards[index][card],
                                    title: cardTitles[index][card],
                                    number: card + 1,
                                    tipLabel:
                                        (card == cards[index].length - 1 &&
                                            [0, 2, 3, 5].contains(index))
                                        ? l10n.playGuideTip
                                        : null,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  decoration: BoxDecoration(
                    color: retro.background,
                    border: Border(
                      top: BorderSide(
                        color: retro.border,
                        width: retro.borderWidth(1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton.outlined(
                        key: const ValueKey('guide-previous'),
                        tooltip: l10n.playGuideBack,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 52,
                        ),
                        onPressed: _busy || _step == 0
                            ? null
                            : () => _select(_step - 1),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GameSetupAction(
                          label: _step == 5
                              ? l10n.playGuideLaunch
                              : l10n.playGuideNext,
                          icon: _step == 5
                              ? Icons.play_arrow_rounded
                              : Icons.menu_book_rounded,
                          primary: true,
                          onPressed: _busy
                              ? null
                              : () {
                                  if (_step == 5) {
                                    _action(() => launchGameWithGuide(context));
                                  } else {
                                    _select(_step + 1);
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
