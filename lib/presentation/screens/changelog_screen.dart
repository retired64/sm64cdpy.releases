import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChangelogScreen
// Muestra el historial de versiones de la app en orden cronológico inverso
// (la más reciente primero). Cada versión tiene:
//   · número de versión + etiqueta opcional (Latest, Beta…)
//   · fecha de lanzamiento
//   · lista de cambios agrupados por tipo (New, Improved, Fixed, Removed)
// Para agregar una versión nueva: añade una entrada al top de _kVersions.
// ─────────────────────────────────────────────────────────────────────────────

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(currentRoute: '/changelog'),
      appBar: AppBar(title: const Text('Changelog')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _kVersions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final version = _kVersions[i];
          final isLatest = i == 0;
          return _VersionCard(version: version, isLatest: isLatest);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de versión
// ─────────────────────────────────────────────────────────────────────────────
class _VersionCard extends StatefulWidget {
  const _VersionCard({required this.version, required this.isLatest});
  final _VersionData version;
  final bool isLatest;

  @override
  State<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends State<_VersionCard>
    with SingleTickerProviderStateMixin {
  // Versiones distintas a la más reciente empiezan colapsadas
  late bool _expanded;
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isLatest;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.isLatest ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isLatest
              ? cs.primary.withValues(alpha: isDark ? 0.40 : 0.30)
              : cs.outline.withValues(alpha: 0.35),
          width: widget.isLatest ? 1.2 : 0.8,
        ),
        boxShadow: widget.isLatest
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header — siempre visible, tappable ──────────────────────────
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  // Número de versión
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'v${widget.version.version}',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (widget.version.tag != null) ...[
                              const SizedBox(width: 8),
                              _Tag(
                                label: widget.version.tag!,
                                isLatest: widget.isLatest,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.version.date,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chevron animado
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: cs.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Cuerpo expandible ────────────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Divisor
                Container(
                  height: 0.8,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: cs.outline.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 12),

                // Grupos de cambios
                ...widget.version.groups.map((g) => _ChangeGroup(group: g)),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grupo de cambios (New / Improved / Fixed / Removed)
// ─────────────────────────────────────────────────────────────────────────────
class _ChangeGroup extends StatelessWidget {
  const _ChangeGroup({required this.group});
  final _ChangeGroupData group;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de cambio
          Row(
            children: [
              Icon(group.type.icon, size: 13, color: group.type.color),
              const SizedBox(width: 5),
              Text(
                group.type.label.toUpperCase(),
                style: TextStyle(
                  color: group.type.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Items
          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Etiqueta de versión (Latest, Beta, etc.)
// ─────────────────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.isLatest});
  final String label;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isLatest ? cs.primaryContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isLatest ? cs.primary : cs.onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tipo de cambio — define color, icono y etiqueta
// ─────────────────────────────────────────────────────────────────────────────
enum _ChangeType {
  added,
  improved,
  fixed,
  removed;

  String get label => switch (this) {
    _ChangeType.added => 'New',
    _ChangeType.improved => 'Improved',
    _ChangeType.fixed => 'Fixed',
    _ChangeType.removed => 'Removed',
  };

  IconData get icon => switch (this) {
    _ChangeType.added => Icons.add_circle_outline_rounded,
    _ChangeType.improved => Icons.auto_fix_high_rounded,
    _ChangeType.fixed => Icons.bug_report_outlined,
    _ChangeType.removed => Icons.remove_circle_outline_rounded,
  };

  Color get color => switch (this) {
    _ChangeType.added => const Color(0xFF22C55E),
    _ChangeType.improved => const Color(0xFF3B82F6),
    _ChangeType.fixed => const Color(0xFFF59E0B),
    _ChangeType.removed => const Color(0xFFEF4444),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────
class _VersionData {
  const _VersionData({
    required this.version,
    required this.date,
    required this.groups,
    this.tag,
  });
  final String version;
  final String date;
  final String? tag; // 'Latest', 'Beta', etc. — null para omitir
  final List<_ChangeGroupData> groups;
}

class _ChangeGroupData {
  const _ChangeGroupData({required this.type, required this.items});
  final _ChangeType type;
  final List<String> items;
}

// ─────────────────────────────────────────────────────────────────────────────
// ── HISTORIAL DE VERSIONES ────────────────────────────────────────────────────
// Para agregar una versión nueva: inserta una entrada al PRINCIPIO de la lista.
// ─────────────────────────────────────────────────────────────────────────────
const _kVersions = <_VersionData>[
  _VersionData(
    version: '1.1.0',
    date: 'April 2026',
    tag: 'Latest',
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'VIP Mods section — curated exclusive mods not listed on the official SM64CoopDX website.',
          'DynOS section — model and animation packs ready to drop into your DynOS folder.',
          'Touch Controls section — touch layout presets for on-screen controls.',
          'Direct download support in VIP Mods, DynOS, and Touch Controls cards.',
          'Favourites support for VIP Mods, DynOS, and Touch Controls (stored with prefixed IDs to avoid collisions).',
          'Favourites screen now shows four tabs: Mods, VIP, DynOS, and Touch Controls.',
          "What's new banner added to the Disclaimer screen.",
          'Version pill (v1.1.0) displayed in the Disclaimer hero badge.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'Disclaimer updated to document the new exclusive sections and their unofficial nature.',
          'App version bumped from 1.0.1 → 1.1.0 across AppConstants and all UI references.',
          'Favourite IDs now use section prefixes (vip_, dynos_, tc_) to avoid collisions between sections.',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.0.1',
    date: 'April 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'Added file downloader:  mod downloads are now handled entirely within the app, no need to open an external browser.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'Renamed "Download Mod" button to "Download" for a cleaner visual.',
          'Fixed unused local variable warning in ChangelogScreen.',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.0.0',
    date: 'April 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'Initial release of SM64CoopDX Mods Manager.',
          'Full mod catalog with search, category filters, and sort options.',
          'Favourites system with Hive persistence.',
          'Export & import favourites as JSON via share sheet.',
          'Popular screen sorted by total downloads.',
          'Mod detail screen with description, tags, stats, and download links.',
          'Light / Dark / System theme modes with persistence.',
          'Bilingual Disclaimer screen (English / Spanish) with animated toggle.',
          'Social links: YouTube, Discord, GitHub.',
          'Smooth fade + scale page transitions across all routes.',
          'Reload data on settings screen.',
        ],
      ),
    ],
  ),
];
