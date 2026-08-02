import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/render96_entity.dart';
import '../../l10n/app_localizations.dart';
import '../../services/background_install_service.dart';
import '../../services/download_url_resolver.dart';
import '../providers/extra_providers.dart';
import '../widgets/app_shell.dart';

class Render96Screen extends ConsumerStatefulWidget {
  const Render96Screen({super.key});

  @override
  ConsumerState<Render96Screen> createState() => _Render96ScreenState();
}

class _Render96ScreenState extends ConsumerState<Render96Screen> {
  @override
  Widget build(BuildContext context) {
    final modsAsync = ref.watch(allRender96Provider);
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return modsAsync.when(
      loading: () => const _Render96Skeleton(),
      error: (e, _) => _Render96Error(
        retro: retro,
        l10n: l10n,
        message: e.toString(),
      ),
      data: (mods) {
        if (mods.isEmpty) {
          return _Render96Empty(retro: retro, l10n: l10n);
        }

        final mainMod = mods.firstWhere(
          (m) => m.id == 'render96-v4',
          orElse: () => mods.first,
        );
        final extras = mods.where((m) => m.id != 'render96-v4').toList();

        return _Render96Body(
          retro: retro,
          l10n: l10n,
          mainMod: mainMod,
          extras: extras,
        );
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Render96Body extends StatelessWidget {
  const _Render96Body({
    required this.retro,
    required this.l10n,
    required this.mainMod,
    required this.extras,
  });

  final RetroTheme retro;
  final AppLocalizations l10n;
  final Render96Entity mainMod;
  final List<Render96Entity> extras;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: retro.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: const DrawerMenuButton(),
          title: Text(l10n.render96Title, style: retro.heading(size: 18)),
        ),
        // ── Hero Banner ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _Render96Hero(retro: retro, mainMod: mainMod, l10n: l10n),
          ),
        ),
        // ── Section Kicker ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: SectionKicker(
              retro: retro,
              label: l10n.render96SectionHeader,
              japanese: 'エクスクルーシブ',
            ),
          ),
        ),
        // ── Main Card ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _Render96MainCard(
              retro: retro,
              l10n: l10n,
              mod: mainMod,
              isMain: true,
            ),
          ),
        ),
        // ── Extras ─────────────────────────────────────────────────────────────
        ...extras.map(
          (mod) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _Render96MainCard(
                retro: retro,
                l10n: l10n,
                mod: mod,
                isMain: false,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ── Hero Banner ────────────────────────────────────────────────────────────────

class _Render96Hero extends StatelessWidget {
  const _Render96Hero({
    required this.retro,
    required this.mainMod,
    required this.l10n,
  });

  final RetroTheme retro;
  final Render96Entity mainMod;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: retro.surfaceAlt,
          border: Border.all(color: retro.border, width: 2),
          boxShadow: retro.hardShadow(dx: 4, dy: 4),
        ),
        child: Stack(
          children: [
            // Diagonal stripes background
            Positioned.fill(
              child: DiagonalStripeBanner(
                baseColor: retro.surfaceAlt,
                stripeColor: retro.amber.withValues(alpha: 0.12),
                stripeWidth: 28,
                gap: 28,
                angle: -0.5,
              ),
            ),
            // Halftone dots
            Positioned.fill(
              child: HalftoneBackground(
                color: retro.border.withValues(alpha: 0.08),
                spacing: 14,
                dotRadius: 1.0,
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      SkewChip(
                        retro: retro,
                        label: mainMod.category.toUpperCase(),
                        selected: true,
                        dense: true,
                        accentColor: retro.amber,
                      ),
                      const SizedBox(width: 10),
                      if (mainMod.version != null)
                        RetroTag(
                          retro: retro,
                          label: 'v${mainMod.version}',
                          filled: true,
                          dense: true,
                          color: retro.amber,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mainMod.name,
                    style: retro.heading(size: 24, letterSpacing: -0.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'リリース',
                    style: retro.body(size: 13, color: retro.inkDim),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main Card ──────────────────────────────────────────────────────────────────

class _Render96MainCard extends ConsumerStatefulWidget {
  const _Render96MainCard({
    required this.retro,
    required this.l10n,
    required this.mod,
    required this.isMain,
  });

  final RetroTheme retro;
  final AppLocalizations l10n;
  final Render96Entity mod;
  final bool isMain;

  @override
  ConsumerState<_Render96MainCard> createState() => _Render96MainCardState();
}

class _Render96MainCardState extends ConsumerState<_Render96MainCard> {
  bool _isExpanded = false;
  bool _downloading = false;
  double _progress = 0.0;
  String? _status;

  Color get _accentColor {
    switch (widget.mod.category) {
      case 'Skinpack':
        return widget.retro.amber;
      case 'Dependency':
        return widget.retro.blue;
      case 'Texture Pack':
        return widget.retro.changelogAdded;
      default:
        return widget.retro.accent;
    }
  }

  String get _badgeLabel {
    switch (widget.mod.category) {
      case 'Dependency':
        return 'REQUIRED';
      case 'Texture Pack':
        return 'OPTIONAL';
      default:
        return widget.mod.category.toUpperCase();
    }
  }

  Color get _categoryColor {
    switch (widget.mod.category) {
      case 'Skinpack':
        return widget.retro.amber;
      case 'Dependency':
        return widget.retro.blue;
      case 'Texture Pack':
        return widget.retro.changelogAdded;
      default:
        return widget.retro.accent;
    }
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    HapticFeedback.mediumImpact();

    // FIX: antes se resolvía el filename con widget.mod.downloadUrl pero se
    // pasaba esa misma URL SIN RESOLVER al downloader nativo. Cuando
    // downloadUrl es una página de GitHub Releases (ej.
    // "github.com/DorfDork/render96/releases/latest"), el nativo descargaba
    // el HTML de esa página en vez del asset .zip real. Ahora se resuelve
    // la URL real PRIMERO, y tanto el filename como la descarga usan esa
    // URL resuelta — ver DownloadUrlResolver.resolveDownloadUrl().
    final resolvedUrl =
        await DownloadUrlResolver.instance.resolveDownloadUrl(
      widget.mod.downloadUrl,
    );

    final filename =
        await DownloadUrlResolver.instance.resolveDownloadFilename(
      resolvedUrl,
      widget.mod.name,
    );
    final modName = sanitizeModTitle(widget.mod.name);

    // Flujo unificado WorkManager con installDestination del JSON
    await BackgroundInstallService.instance.startDownloadAndInstall(
      url: resolvedUrl,
      modName: modName,
      fileName: filename,
      displayTitle: widget.mod.name,
      installDestination: widget.mod.installDestination,
    );

    setState(() {
      _downloading = false;
      _progress = 1.0;
      _status = 'done';
    });
  }

  Future<void> _openTrailer() async {
    if (widget.mod.youtube != null) {
      final uri = Uri.parse(widget.mod.youtube!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final desc = widget.mod.description;
    final isActive = _downloading || _status == 'done';

    return Container(
      decoration: BoxDecoration(
        color: widget.retro.surface,
        border: Border.all(
          color: widget.isMain ? _accentColor : widget.retro.border,
          width: widget.isMain ? 3 : 1.5,
        ),
        boxShadow: widget.retro.hardShadow(dx: 3, dy: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge + Version row
                Row(
                  children: [
                    SkewChip(
                      retro: widget.retro,
                      label: _badgeLabel,
                      selected: true,
                      dense: true,
                      accentColor: _categoryColor,
                    ),
                    if (widget.mod.version != null) ...[
                      const SizedBox(width: 8),
                      RetroTag(
                        retro: widget.retro,
                        label: 'v${widget.mod.version}',
                        dense: true,
                        color: widget.retro.inkDim,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  widget.mod.name,
                  style: widget.retro.heading(size: 16.5),
                ),

                // Author · Repo — antes vivían en lugares distintos (autor
                // debajo del título, repo apretado en el row de badges sin
                // límite de ancho → se cortaba con "pokeheadroom/REN...").
                // Ahora comparten una sola línea de metadata secundaria,
                // cada uno en un Flexible independiente: si ambos caben,
                // se muestran completos; si no, cada uno trunca por su
                // cuenta con ellipsis en vez de desbordar la tarjeta.
                if (widget.mod.author != null || widget.mod.repo.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (widget.mod.author != null)
                        Flexible(
                          child: Text(
                            widget.mod.author!,
                            style: widget.retro.body(
                              size: 11.5,
                              weight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (widget.mod.author != null &&
                          widget.mod.repo.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Text(
                            '·',
                            style: widget.retro.body(
                              size: 12,
                              color: widget.retro.inkDim.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      if (widget.mod.repo.isNotEmpty)
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.code_rounded,
                                size: 12,
                                color: widget.retro.inkDim.withValues(alpha: 0.55),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  widget.mod.repo,
                                  style: widget.retro.body(
                                    size: 10.5,
                                    color: widget.retro.inkDim.withValues(
                                      alpha: 0.65,
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],

                // Description
                if (desc != null && desc.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    desc,
                    style: widget.retro.body(size: 12, height: 1.5),
                    maxLines: _isExpanded ? null : 3,
                    overflow:
                        _isExpanded ? TextOverflow.visible : TextOverflow.fade,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Text(
                      _isExpanded
                          ? widget.l10n.sharedShowLess
                          : widget.l10n.sharedReadMore,
                      style: TextStyle(
                        color: widget.retro.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],

                // Notes — antes: borde parejo en los 4 lados + Icons.info_outline
                // genérico sin importar el contexto. Ahora: barra de acento
                // lateral (patrón "callout") + ícono que cambia según lo que
                // el aviso realmente comunica — prioridad para una dependencia
                // requerida, informativo para todo lo demás.
                if (widget.mod.notes != null && widget.mod.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.07),
                      border: Border(
                        top: BorderSide(color: _accentColor.withValues(alpha: 0.25)),
                        right: BorderSide(color: _accentColor.withValues(alpha: 0.25)),
                        bottom: BorderSide(color: _accentColor.withValues(alpha: 0.25)),
                        left: BorderSide(color: _accentColor, width: 3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            widget.mod.category == 'Dependency'
                                ? Icons.priority_high_rounded
                                : Icons.info_outline_rounded,
                            size: 14,
                            color: _accentColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.mod.notes!,
                              style: widget.retro.body(
                                size: 11,
                                color: widget.retro.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Progress bar
                if (isActive) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _downloading ? null : _progress,
                    color: _accentColor,
                    backgroundColor:
                        _accentColor.withValues(alpha: 0.12),
                    minHeight: 4,
                  ),
                ],

                // Buttons
                const SizedBox(height: 14),
                if (widget.isMain && widget.mod.youtube != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ActionButton(
                      retro: widget.retro,
                      label: 'WATCH TRAILER',
                      icon: Icons.play_circle_fill_rounded,
                      color: widget.retro.red,
                      onTap: _openTrailer,
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        retro: widget.retro,
                        label: _downloading
                            ? 'DOWNLOADING...'
                            : _status == 'done'
                                ? 'INSTALLED'
                                : widget.l10n.sharedDownload,
                        icon: _status == 'done'
                            ? Icons.check_circle_rounded
                            : Icons.download_rounded,
                        loading: _downloading,
                        color: _status == 'done'
                            ? widget.retro.changelogAdded
                            : _accentColor,
                        filled: true,
                        onTap:
                            isActive ? null : _download,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Button helpers ─────────────────────────────────────────────────────────────
// Antes (_OutlinedButton): el "ícono" era un carácter emoji (⬇, ▶) metido a
// mano dentro del string del label. Eso lo renderiza la fuente emoji del
// sistema — colores y trazo que no tienen nada que ver con el resto del
// lenguaje visual "manga panel" (Icon() con stroke fino y color controlado
// como en SkewChip/RetroTag/RetroMeta). _ActionButton reemplaza eso con un
// slot real de IconData, más un estado `loading` que muestra un spinner del
// mismo color que el ícono en vez de dejar el botón "congelado" durante la
// descarga.

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.retro,
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.filled = false,
    this.loading = false,
  });

  final RetroTheme retro;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool filled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // Mismo criterio de contraste que ya usa SkewChip para accentColor
    // custom: sobre un relleno claro (amber, teal) la tinta oscura del tema
    // gana legibilidad; sobre un relleno oscuro (verde éxito, azul, rojo)
    // gana el blanco.
    final fg = filled
        ? (ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : retro.background)
        : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
          boxShadow: retro.hardShadow(dx: 2, dy: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              ),
              const SizedBox(width: 9),
            ] else if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────────

class _Render96Skeleton extends StatelessWidget {
  const _Render96Skeleton();

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: retro.background,
          elevation: 0,
          leading: const DrawerMenuButton(),
          title: _Bone(width: 110, height: 20, retro: retro),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Bone(width: double.infinity, height: 170, retro: retro),
                const SizedBox(height: 20),
                _Bone(width: double.infinity, height: 200, retro: retro),
                const SizedBox(height: 12),
                _Bone(width: double.infinity, height: 120, retro: retro),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Error ──────────────────────────────────────────────────────────────────────

class _Render96Error extends StatelessWidget {
  const _Render96Error({
    required this.retro,
    required this.l10n,
    required this.message,
  });

  final RetroTheme retro;
  final AppLocalizations l10n;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: retro.red.withValues(alpha: 0.35), width: 2),
                boxShadow: retro.hardShadow(dx: 3, dy: 3),
              ),
              child: Column(
                children: [
                  Icon(Icons.error_outline_rounded, size: 32, color: retro.red),
                  const SizedBox(height: 8),
                  Text(
                    l10n.render96FailedToLoad,
                    style: retro.heading(size: 14, color: retro.red),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: retro.body(size: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty ──────────────────────────────────────────────────────────────────────

class _Render96Empty extends StatelessWidget {
  const _Render96Empty({required this.retro, required this.l10n});

  final RetroTheme retro;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: retro.inkDim.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: retro.hardShadow(dx: 3, dy: 3),
              ),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_rounded,
                      size: 32, color: retro.inkDim),
                  const SizedBox(height: 8),
                  Text(l10n.render96Empty,
                      style: retro.heading(size: 14, color: retro.inkDim)),
                  const SizedBox(height: 6),
                  Text(l10n.render96EmptyHint,
                      textAlign: TextAlign.center, style: retro.body(size: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bone (skeleton placeholder) ────────────────────────────────────────────────

class _Bone extends StatelessWidget {
  const _Bone({required this.width, required this.height, required this.retro});
  final double width;
  final double height;
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: retro.surfaceAlt,
        border: Border.all(
          color: retro.border.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
    );
  }
}
