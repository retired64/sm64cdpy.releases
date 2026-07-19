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
      backgroundColor: retro.void_,
      drawer: const AppDrawer(currentRoute: '/links-resource'),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            backgroundColor: retro.void_,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            floating: true,
            snap: true,
            elevation: 0,
            shape: Border(bottom: BorderSide(color: retro.line, width: 3)),
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu_rounded, color: retro.gold, size: 22),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  color: retro.gold,
                  margin: const EdgeInsets.only(right: 4),
                ),
                const SizedBox(width: 6),
                Text(
                  'LINKS & RESOURCES',
                  style: TextStyle(
                    color: retro.gold,
                    fontFamily: RetroTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // ── Hero: explica qué es esta pantalla y cómo usarla ──────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: _HubHero(retro: retro),
            ),
          ),

          _Section(
            retro: retro,
            badge: 'OFC',
            accent: retro.gold,
            title: 'OFFICIAL',
            description: 'Canales verificados del proyecto SM64CoopDX.',
            links: _kOfficialLinks,
          ),
          _Section(
            retro: retro,
            badge: 'APP',
            accent: retro.red,
            title: 'SM64CDPY',
            description: 'Descargas y contenido de esta app.',
            links: _kAppLinks,
          ),
          _Section(
            retro: retro,
            badge: 'RES',
            accent: retro.purple,
            title: 'RESOURCES',
            description: 'Comunidad, guías e instalación paso a paso.',
            links: _kResourceLinks,
            isLast: true,
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

// ── Hero card ────────────────────────────────────────────────────────────────
// Marco con esquinas tipo bracket + explica el propósito de la pantalla y
// la interacción (tap vs. mantener presionado) para que sea evidente a
// simple vista, sin tener que descubrirlo por accidente.

class _HubHero extends StatelessWidget {
  const _HubHero({required this.retro});
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: retro.panel,
            borderRadius: RetroTheme.pixelRadius,
            border: Border.all(color: retro.line, width: 3),
            boxShadow: retro.hardShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link_rounded, size: 18, color: retro.gold),
                  const SizedBox(width: 8),
                  Text(
                    'LINK HUB',
                    style: TextStyle(
                      color: retro.gold,
                      fontFamily: RetroTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Todo lo oficial, la comunidad y los recursos del proyecto, '
                'en un solo lugar.',
                style: TextStyle(
                  color: retro.ink,
                  fontFamily: RetroTheme.fontFamily,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HintChip(
                    retro: retro,
                    icon: Icons.touch_app_rounded,
                    label: 'TOCA = ABRIR',
                  ),
                  _HintChip(
                    retro: retro,
                    icon: Icons.copy_rounded,
                    label: 'MANTÉN = COPIAR',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Corner brackets — el "marco" retro sobre el panel principal.
        Positioned(top: -6, left: -6, child: _Corner(retro: retro, tl: true)),
        Positioned(top: -6, right: -6, child: _Corner(retro: retro, tr: true)),
        Positioned(
          bottom: -6,
          left: -6,
          child: _Corner(retro: retro, bl: true),
        ),
        Positioned(
          bottom: -6,
          right: -6,
          child: _Corner(retro: retro, br: true),
        ),
      ],
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.retro, required this.icon, required this.label});
  final RetroTheme retro;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: retro.panelAlt,
        border: Border.all(color: retro.line, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: retro.inkDim),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: retro.inkDim,
              fontFamily: RetroTheme.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.retro,
    this.tl = false,
    this.tr = false,
    this.bl = false,
    this.br = false,
  });

  final RetroTheme retro;
  final bool tl, tr, bl, br;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        border: Border(
          top: (tl || tr) ? BorderSide(color: retro.gold, width: 2) : BorderSide.none,
          bottom: (bl || br) ? BorderSide(color: retro.gold, width: 2) : BorderSide.none,
          left: (tl || bl) ? BorderSide(color: retro.gold, width: 2) : BorderSide.none,
          right: (tr || br) ? BorderSide(color: retro.gold, width: 2) : BorderSide.none,
        ),
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
  final String kind; // etiqueta corta: WEB, DISCORD, GITHUB...
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
    required this.badge,
    required this.accent,
    required this.title,
    required this.description,
    required this.links,
    this.isLast = false,
  });

  final RetroTheme retro;
  final String badge;
  final Color accent;
  final String title;
  final String description;
  final List<_LinkData> links;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 22, 16, isLast ? 0 : 4),
      sliver: SliverList.list(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  border: Border.all(color: retro.line, width: 2),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: retro.void_,
                    fontFamily: RetroTheme.fontFamily,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: retro.ink,
                        fontFamily: RetroTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: retro.inkDim,
                        fontFamily: RetroTheme.fontFamily,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
// Tap = abre el enlace. Long-press = copia la URL. Feedback de presión tipo
// botón de arcade (se hunde y pierde la sombra dura), como en OmmRebirthCard.

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
    AppSnackbar.success(
      context,
      message: 'Link copied',
    );
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
                color: retro.panel,
                borderRadius: RetroTheme.pixelRadius,
                border: Border.all(color: retro.line, width: 2.5),
                boxShadow: retro.hardShadow(
                  dx: 4 - offset,
                  dy: 4 - offset,
                ),
              ),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              // Icono con marco propio, tintado por categoría.
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.16),
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
                            style: TextStyle(
                              color: retro.ink,
                              fontFamily: RetroTheme.fontFamily,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
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
                            style: TextStyle(
                              color: retro.inkDim,
                              fontFamily: RetroTheme.fontFamily,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.link.subtitle,
                      style: TextStyle(
                        color: retro.inkDim,
                        fontFamily: RetroTheme.fontFamily,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: retro.inkDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
