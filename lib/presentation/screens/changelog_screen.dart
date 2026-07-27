import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_shell.dart';

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
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: retro.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: const DrawerMenuButton(),
          title: Text(l10n.changelogTitle, style: retro.heading(size: 18)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final version = _kVersions[i];
                final isLatest = i == 0;
                return Padding(
                  padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
                  child: _VersionCard(version: version, isLatest: isLatest),
                );
              },
              childCount: _kVersions.length,
            ),
          ),
        ),
      ],
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
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);

    final tagLabel = widget.version.tag == 'Latest' ? l10n.changelogLatest : widget.version.tag;

    return Container(
      decoration: BoxDecoration(
        color: retro.surface,
        borderRadius: RetroTheme.radius,
        border: Border.all(
          color: widget.isLatest ? retro.accent : retro.border,
          width: widget.isLatest ? 3 : 2,
        ),
        boxShadow: retro.hardShadow(dx: 3, dy: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header — siempre visible, tappable ──────────────────────────
          GestureDetector(
            onTap: _toggle,
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
                              style: retro.heading(size: 15),
                            ),
                            if (widget.version.tag != null) ...[
                              const SizedBox(width: 8),
                              RetroTag(
                                retro: retro,
                                label: tagLabel!,
                                filled: widget.isLatest,
                                dense: true,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.version.date,
                          style: retro.body(size: 11),
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
                      Icons.keyboard_arrow_down,
                      color: retro.inkDim,
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
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: retro.border.withValues(alpha: 0.5),
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
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de cambio
          Row(
            children: [
              Icon(group.type.icon, size: 13, color: group.type.color(retro)),
              const SizedBox(width: 5),
              Text(
                group.type.label(l10n).toUpperCase(),
                style: TextStyle(
                  color: group.type.color(retro),
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
                        color: retro.inkDim.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: retro.inkDim,
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
// Tipo de cambio — define color, icono y etiqueta
// ─────────────────────────────────────────────────────────────────────────────
enum _ChangeType {
  added,
  improved,
  fixed,
  removed,
  changed;

  String label(AppLocalizations l10n) => switch (this) {
    _ChangeType.added => l10n.changelogNew,
    _ChangeType.improved => l10n.changelogImproved,
    _ChangeType.fixed => l10n.changelogFixed,
    _ChangeType.removed => l10n.changelogRemoved,
    _ChangeType.changed => l10n.changelogChanged,
  };

  IconData get icon => switch (this) {
    _ChangeType.added => Icons.add_circle_outline_rounded,
    _ChangeType.improved => Icons.auto_fix_high_rounded,
    _ChangeType.fixed => Icons.bug_report_outlined,
    _ChangeType.removed => Icons.remove_circle_outline_rounded,
    _ChangeType.changed => Icons.swap_horiz_rounded,
  };

  Color color(RetroTheme retro) => switch (this) {
    _ChangeType.added => retro.changelogAdded,
    _ChangeType.improved => retro.changelogImproved,
    _ChangeType.fixed => retro.changelogFixed,
    _ChangeType.removed => retro.changelogRemoved,
    _ChangeType.changed => retro.changelogChanged,
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
    version: '1.6.1',
    date: 'July 2026',
    tag: 'Latest',
    groups: [
      _ChangeGroupData(
        type: _ChangeType.fixed,
        items: [
          'Standalone .lua mods from the catalogue now download and copy correctly to the mods folder — no more silently failing because the file was wrongly treated as a ZIP.',
          'Native SAF file creation changed from hardcoded "application/zip" to generic "application/octet-stream" MIME type so .lua files (and any non-ZIP) can be created in the selected folder.',
          'All download callbacks now check the operation result before showing success — false "Saved to folder" messages when the copy failed are gone.',
          'Filename inference no longer forces .zip extension on /download URLs — the server\'s Content-Disposition header now determines the real filename.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'Download success messages now show the content type in context — "Saved to DynOS folder", "Saved to Touch Controls folder", etc., instead of the generic "mods folder" for everything.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.changed,
        items: [
          'Removed 4 unused dependencies (cupertino_icons, lucide_icons_flutter, android_intent_plus, archive) — smaller APK, faster build.',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.6.0',
    date: 'July 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'Mod detail hero height reduced from 300px to 180px — avatar now sits near the top, removing wasted empty space and putting content front and center.',
          'Description text now uses 3-line clamping (maxLines: 3 + TextOverflow.ellipsis) instead of character-based truncation — no more mid-word cuts, cleaner and more readable.',
          'Mod detail title cleaned up — removed the teal "stamp" shadow effect behind the title text. Title now uses softWrap for clean word wrapping on long mod names.',
          'Download buttons in exclusive sections (VIP, DynOS, Touch Controls, OMM Rebirth) now use the full download flow: notification permission check, folder selection, real progress bar, and auto-copy to the target folder.',
          'New DynOS folder selector in Settings → Game Integration — DynOS and Touch Controls packs now install to a separate dynos/packs/ folder instead of the mods folder.',
          'OMM Rebirth "cappy-bros-dynos" now installs to the DynOS folder automatically (the only OMM entry that is a DynOS pack, not a mod).',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.removed,
        items: [
          'Dark gradient scrim (black-to-transparent) above the mod detail avatar eliminated — the glass app bar buttons already have sufficient contrast against the teal hero background without it.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.fixed,
        items: [
          '"LAUNCH GAME" button on the home screen was still hardcoded in English and ignored the selected language — now correctly uses the i18n system (shows "ABRIR JUEGO" / "ABRIR JOGO").',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.5.1',
    date: 'July 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'New app icon — concept by Retired64, adapted by □●AGS4●□.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.fixed,
        items: [
          'Update dialog crashed with a full-screen error the moment "Update now" was tapped, due to a localization field being reassigned on every rebuild.',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.5.0',
    date: 'July 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'Multi-language support — English (US), Spanish (Latin America), and Brazilian Portuguese. All screens, widgets, dialogs, and settings translated via flutter_localizations + ARB (299 keys).',
          'Language selector in Settings → Appearance, with expandable dropdown and country flags (follow system / EN / ES / PT).',
          'Android notification channel names and foreground service messages localized (values, values-es, values-pt-rBR).',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'Disclaimer screen: legacy hardcoded bilingual EN/ES toggle replaced by the standard i18n system. Original legal text preserved clause-for-clause in all three languages.',
          'Date formatting now follows the active locale (formatDate accepts optional locale parameter).',
          'Count labels (X MODS / X LAYOUTS) now use proper ICU pluralization (1 MOD / X MODS).',
          'Dark text on accent backgrounds (LAUNCH GAME button, SOON badge) now centralized as inkOnAccent token in RetroTheme.',
          'Medal colors (gold/silver/bronze) unified between home and popular screens as RetroTheme tokens (medalGold, medalSilver, medalBronze).',
          'Changelog type labels (New, Improved, Fixed, Removed, Changed) and category display names extracted to ARB for translation.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.fixed,
        items: [
          'Pagination label in Popular screen was hardcoded in Spanish (MOSTRANDO\u2026) — unified with the catalogue pagination key.',
          'Links & Resources screen descriptions were hardcoded in Spanish in the English translation template — fixed to English.',
          'Duplicate notification-permission and mods-folder dialog strings in mod_detail_screen now share a single ARB key instead of duplicated entries.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.removed,
        items: [
          'AppTheme class (~345 lines) eliminated — RetroTheme is now the sole design source for the entire app.',
          'google_fonts dependency removed (no longer used after AppTheme deletion).',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.4.5',
    date: 'July 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'Home "Browse" section redesigned as a swipeable carousel (Catalog, Favourites, Popular), matching the same card + page-dot style as the Featured carousel.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'Each Browse card now has a color-coded skewed "GO TO" button for quicker at-a-glance navigation — amber for Catalog, red for Favourites, navy blue for Popular.',
          'Skewed chip buttons now auto-pick readable text color (white or dark ink) based on the fill color brightness, fixing low-contrast text on darker accent colours.',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.4.4',
    date: 'July 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'Complete retro redesign — all screens and widgets migrated to the new RetroTheme with navy/cream/teal palette, Lato typography, hard drop shadows, and square borders.',
          'Custom SVG icons throughout the navigation drawer and home screen (13 hand‑crafted icons, native colours, no colour filters applied).',
          'Drawer performance overhaul for low‑end devices: single global fade instead of 14 individual opacity layers (~14× fewer GPU compositing layers), lazy‑built category and sort option lists, and reduced stagger duration from 500 ms to 420 ms.',
          'Sort options in the drawer now display clean text labels only (emoji decorations removed to match the retro aesthetic).',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.4.3',
    date: 'July 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'New "Links Resource" screen — a dedicated hub gathering all useful links in one place, organised into OFFICIAL, SM64CDPY, and RESOURCES sections.',
          'Each link is shown as a tappable card with an icon, title, and short description, opening in your browser with a single tap.',
          'Accessible directly from the navigation drawer.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'The app now supports both portrait and landscape orientations — previously it was locked to portrait only.',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.4.2',
    date: 'July 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'Complete background download + install via Android WorkManager with persistent foreground notifications — download and install both show real-time progress in the notification shade even when the app is in the background.',
          'Download progress notification with cancel button — tap "Cancel" in the notification to stop an ongoing download at any time.',
          'Install progress notification with cancel button and file counter (e.g. "Extracting 45/120 files").',
          'Runtime permission request for POST_NOTIFICATIONS (Android 13+), shown in-context when the user first taps Download, with a rationale dialog explaining why notifications are needed.',
          'Guided "Go to Settings" dialog when auto-install is enabled but no mods folder has been selected yet — preventing cryptic errors.',
          'When auto-install is OFF but a mods folder is selected, ZIP files are automatically copied to the mods folder after download (ready for manual installation).',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'Download + install flow is now fully non-blocking — the previous install progress dialog that locked the screen has been removed entirely.',
          'Inline status banner on the mod detail screen shows live download percentage and install file count.',
          'Real download progress replaces the fake animation — progress bar reflects actual bytes downloaded via EventChannel from native WorkManager.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.removed,
        items: [
          'Invasive "Install to game?" dialog after every download — replaced by the auto-install toggle in Settings as the single source of truth for installation behavior.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.fixed,
        items: [
          'Mod installation no longer freezes the UI during ZIP extraction — the entire extraction runs on a native background thread with WorkManager.',
          'Downloaded ZIPs no longer remain in the system Downloads folder when a mods folder is selected — they are moved to the mods folder automatically.',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.4.1',
    date: 'July 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.fixed,
        items: [
          'Mod installer no longer creates an extra parent folder — ZIP contents are extracted directly into the selected mods directory, preserving the original mod structure so the game detects mods correctly.',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.4.0',
    date: 'July 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'Mod installer — downloaded ZIP files can now be extracted directly into the SM64CoopDX mods folder so mods are ready to play immediately.',
          'Mods folder selection in Settings → Game Integration — uses the Storage Access Framework (SAF) file picker with persistent permissions across device reboots.',
          'Auto-install toggle — when enabled, mods are automatically installed to the game folder after each download without confirmation.',
          'Install progress dialog with success / error states and retry support.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.changed,
        items: [
          'Download complete flow now checks for a configured mods folder and offers installation (or auto-installs if the toggle is on).',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.3.1',
    date: 'June 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.changed,
        items: [
          'OTA update checks are now manual-only — removed the automatic check on app startup. Users must go to Settings → About → "Check for updates" to look for new versions.',
          'Update dialog changelog now displays as clean plain text instead of raw GitHub Markdown (headings, bold, code blocks, links and bullets are stripped).',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.removed,
        items: [
          'Automatic OTA update detection on app launch (the dialog will no longer pop up when opening the app).',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'Markdown-stripping preserves readability of GitHub release notes while removing visual noise ([FORCE] tags, code fences, emphasis markers).',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.3.0',
    date: 'June 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'Manual "Check for updates" button in Settings → About with inline progress indicator and update dialog.',
          'Force-update support — releases can now include [FORCE] in the changelog body to block app usage until updated.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'OTA now detects the real device ABI at runtime (arm64 / arm32 / x86_64) via device_info_plus instead of assuming arm64-v8a.',
          'Version comparison now handles semver suffixes (-beta, +5) gracefully and logs errors instead of silently failing.',
          'GitHub API rate-limit (403) is now distinguished from other HTTP errors in update checks.',
          'Update checks are cached for 6 hours via SharedPreferences to avoid unnecessary API hits.',
          '"App version" tile renamed to "Go to releases" with open-in-browser icon.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.fixed,
        items: [
          'Update dialog now shows "Mejoras y correcciones menores" when the release changelog is empty or missing.',
          'Silent version comparison failures on malformed tags no longer swallowed — they are now logged.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.changed,
        items: [
          '"Catalogue" quick card renamed to "Catalog" and "Favourites" to "Fav".',
          '"Recently Updated" horizontal scroll removed from the home screen.',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.2.0',
    date: 'June 2026',
    tag: null,
    groups: [
      _ChangeGroupData(
        type: _ChangeType.added,
        items: [
          'OTA update system — automatic update detection from GitHub Releases with in-app download, progress bar, and one-tap APK installation (Android only).',
          'OMM Rebirth Pack section — exclusive content for OMM Rebirth mods with download and favourites support.',
          'Centralised notification system — all snackbars now use a consistent floating-card design with icon + accent border (success / error / info).',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.improved,
        items: [
          'Unified 30+ SnackBars across 7 screens into a single AppSnackbar helper (no more eye-strain solid backgrounds).',
          'Notification contrast improved — floating rounded cards with surface-based backgrounds instead of harsh container colours.',
          'OMM Rebirth Pack listed under the EXCLUSIVE section in the navigation drawer.',
        ],
      ),
      _ChangeGroupData(
        type: _ChangeType.removed,
        items: [
          'Visual tags removed from OMM Rebirth Pack cards (irrelevant metadata for that section).',
        ],
      ),
    ],
  ),
  _VersionData(
    version: '1.1.0',
    date: 'April 2026',
    tag: null,
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
