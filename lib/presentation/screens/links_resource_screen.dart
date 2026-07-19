import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_snackbar.dart';

class LinksResourceScreen extends StatelessWidget {
  const LinksResourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Scaffold(
      backgroundColor: retro.background,
      drawer: const AppDrawer(currentRoute: '/links-resource'),
      body: Stack(
        children: [
          Positioned.fill(
            child: HalftoneBackground(
              color: retro.ink.withValues(alpha: retro.isDark ? 0.05 : 0.08),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                backgroundColor: retro.background,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                floating: true,
                snap: true,
                elevation: 0,
                shape: Border(bottom: BorderSide(color: retro.border, width: 3)),
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: Icon(Icons.menu_rounded, color: retro.ink, size: 22),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'LINKS ',
                        style: retro.heading(size: 18, color: retro.ink),
                      ),
                      TextSpan(
                        text: '& RECURSOS',
                        style: retro.heading(size: 18, color: retro.accent),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Kicker: 発見 = "descubre" / リンク = "link" ──────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text(
                    '発見・すべてのリンク',
                    style: retro.body(size: 12, color: retro.inkDim),
                  ),
                ),
              ),

              // ── Hero: explica qué es esta pantalla y cómo usarla ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: _HubHero(retro: retro),
                ),
              ),

              _Section(
                retro: retro,
                title: 'OFFICIAL',
                japanese: '公式',
                description: 'Canales verificados del proyecto SM64CoopDX.',
                accent: retro.accent,
                links: _kOfficialLinks,
              ),
              _Section(
                retro: retro,
                title: 'SM64CDPY',
                japanese: 'アプリ',
                description: 'Descargas y contenido de esta app.',
                accent: retro.red,
                links: _kAppLinks,
              ),
              _Section(
                retro: retro,
                title: 'RESOURCES',
                japanese: '資料',
                description: 'Comunidad, guías e instalación paso a paso.',
                accent: retro.blue,
                links: _kResourceLinks,
                isLast: true,
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Hero card ────────────────────────────────────────────────────────────────

class _HubHero extends StatelessWidget {
  const _HubHero({required this.retro});
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: retro.surface,
        border: Border.all(color: retro.border, width: 2.5),
        boxShadow: retro.hardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link_rounded, size: 18, color: retro.accent),
              const SizedBox(width: 8),
              Text('LINK HUB', style: retro.heading(size: 13, color: retro.accent)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Todo lo oficial, la comunidad y los recursos del proyecto, '
            'en un solo lugar.',
            style: retro.body(size: 14, color: retro.ink),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SkewChip(
                retro: retro,
                icon: Icons.touch_app_rounded,
                label: 'TOCA = ABRIR',
                dense: true,
              ),
              SkewChip(
                retro: retro,
                icon: Icons.copy_rounded,
                label: 'MANTÉN = COPIAR',
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _LinkData {
  const _LinkData({
    required this.title,
    required this.url,
    required this.subtitle,
    required this.icon,
    required this.kind,
  });

  final String title;
  final String url;
  final String subtitle;
  final IconData icon;
  final String kind;
}

const _kOfficialLinks = [
  _LinkData(
    title: 'SM64CoopDX Website',
    url: AppConstants.officialweb,
    subtitle: 'sm64coopdx.com',
    icon: Icons.public_rounded,
    kind: 'WEB',
  ),
  _LinkData(
    title: 'Discord Server',
    url: AppConstants.discordPortAndroid,
    subtitle: 'Official community server · Android',
    icon: Icons.chat_rounded,
    kind: 'DISCORD',
  ),
  _LinkData(
    title: 'GitHub Repository',
    url: AppConstants.maniscat2Github,
    subtitle: 'Source code & issues',
    icon: Icons.code_rounded,
    kind: 'GITHUB',
  ),
];

const _kAppLinks = [
  _LinkData(
    title: 'GitHub Releases',
    url: AppConstants.githubReleasesUrl,
    subtitle: 'Download latest APK',
    icon: Icons.system_update_rounded,
    kind: 'DOWNLOAD',
  ),
  _LinkData(
    title: 'YouTube Channel',
    url: AppConstants.youtubeUrl,
    subtitle: '@retired64',
    icon: Icons.play_circle_rounded,
    kind: 'YOUTUBE',
  ),
];

const _kResourceLinks = [
  _LinkData(
    title: 'Discord Server',
    url: AppConstants.discordPort,
    subtitle: 'Community & support server',
    icon: Icons.chat_rounded,
    kind: 'DISCORD',
  ),
  _LinkData(
    title: 'Wiki & Guides',
    url: AppConstants.wikiUrl,
    subtitle: 'Installation guides & docs',
    icon: Icons.menu_book_rounded,
    kind: 'WIKI',
  ),
  _LinkData(
    title: 'Tools & Add-ons',
    url: AppConstants.toolsAndAddonsUrl,
    subtitle: 'How to make mods & resources',
    icon: Icons.build_rounded,
    kind: 'TOOLS',
  ),
];

// ── Section ──────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.retro,
    required this.title,
    required this.japanese,
    required this.description,
    required this.accent,
    required this.links,
    this.isLast = false,
  });

  final RetroTheme retro;
  final String title;
  final String japanese;
  final String description;
  final Color accent;
  final List<_LinkData> links;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 22, 16, isLast ? 0 : 4),
      sliver: SliverList.list(
        children: [
          SectionKicker(retro: retro, label: title, japanese: japanese),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 4, bottom: 12),
            child: Text(description, style: retro.body(size: 12)),
          ),
          ...links.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LinkCard(link: l, accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Link card ────────────────────────────────────────────────────────────────
// Tap = abre el enlace. Long-press = copia la URL.

class _LinkCard extends StatefulWidget {
  const _LinkCard({required this.link, required this.accent});

  final _LinkData link;
  final Color accent;

  @override
  State<_LinkCard> createState() => _LinkCardState();
}

class _LinkCardState extends State<_LinkCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Future<void> _open(BuildContext context) async {
    HapticFeedback.selectionClick();
    final uri = Uri.parse(widget.link.url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      AppSnackbar.error(context, message: 'Could not open link');
    }
  }

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.mediumImpact();
    await Clipboard.setData(ClipboardData(text: widget.link.url));
    if (!context.mounted) return;
    AppSnackbar.success(context, message: 'Link copied');
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: () => _open(context),
      onLongPress: () => _copy(context),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) {
          final offset = 3.0 * _pressCtrl.value;
          return Transform.translate(
            offset: Offset(offset, offset),
            child: Container(
              decoration: BoxDecoration(
                color: retro.surface,
                border: Border.all(color: retro.border, width: 2),
                boxShadow: retro.hardShadow(dx: 4 - offset, dy: 4 - offset),
              ),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.18),
                  border: Border.all(color: widget.accent, width: 2),
                ),
                child: Icon(widget.link.icon, size: 20, color: widget.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.link.title,
                            style: retro.heading(size: 14, letterSpacing: -0.1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: retro.inkDim, width: 1),
                          ),
                          child: Text(
                            widget.link.kind,
                            style: retro.heading(
                              size: 8,
                              color: retro.inkDim,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.link.subtitle,
                      style: retro.body(size: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 20, color: retro.inkDim),
            ],
          ),
        ),
      ),
    );
  }
}
