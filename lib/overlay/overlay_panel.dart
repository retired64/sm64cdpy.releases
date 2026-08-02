import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/retro_theme.dart';
import '../l10n/app_localizations.dart';
import 'overlay_sections.dart';

/// Tema fijo del overlay flotante — ver `RetroTheme.overlay()` para el
/// razonamiento de por qué es una instancia fija y no `RetroTheme.of(context)`.
final _retro = RetroTheme.overlay();

class OverlayPanel extends ConsumerStatefulWidget {
  const OverlayPanel({super.key});

  @override
  ConsumerState<OverlayPanel> createState() => _OverlayPanelState();
}

class _OverlayPanelState extends ConsumerState<OverlayPanel>
    with WidgetsBindingObserver {
  StreamSubscription<Object?>? _sub;
  final Map<String, String> _modStatus = {};
  final Map<String, int> _modProgress = {};
  final Map<String, Timer> _pendingTimers = {};
  final Set<String> _cancelledMods = {};

  final _searchCtrl = TextEditingController();

  static const _bridgeTimeout = Duration(seconds: 4);

  // Debe coincidir con `contentWidth`/`contentHeight` del showChatHead() en
  // settings_screen.dart — es el tamaño "de reposo" al que volvemos cuando
  // se cierra el teclado.
  static const _panelWidth = 260;
  static const _panelHeight = 340;
  bool _resizedForKeyboard = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sub = FloatyOverlay.onData.listen(_onOverlayData);
    FloatyOverlay.shareData({'type': 'panel_opened'});
  }

  // Confirmado en la doc del plugin (pub.dev/packages/floaty_chatheads):
  // `FloatyOverlay.resizeContent(w, h)` — "Resizes the content panel from
  // inside the overlay". Es el mecanismo soportado para esto: como esta
  // ventana es un View nativo aparte (no una Activity), Android no le
  // aplica el resize/pan automático que sí le da a la app principal
  // cuando aparece el teclado — por eso `resizeToAvoidBottomInset: false`
  // no alcanzaba. En vez de solo esconder elementos, ahora agrandamos la
  // ventana en tiempo real por la altura que el teclado le está robando.
  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final view = View.of(context);
    final bottomInsetLogical = view.viewInsets.bottom / view.devicePixelRatio;
    final shouldExpand = bottomInsetLogical > 24; // margen contra jitter/IME transitorio
    if (shouldExpand == _resizedForKeyboard) return;
    _resizedForKeyboard = shouldExpand;

    final targetHeight = shouldExpand
        ? (_panelHeight + bottomInsetLogical).round()
        : _panelHeight;
    _safeResizeContent(_panelWidth, targetHeight);
  }

  /// `resizeContent` es una llamada a un canal de plataforma hacia una
  /// ventana nativa (View) que vive fuera del ciclo de vida normal del
  /// widget tree — puede estar en proceso de destruirse (usuario cerrando
  /// el overlay justo cuando el teclado también se está cerrando) cuando
  /// esto se dispara. Sin try/catch, un PlatformException ahí queda como
  /// un Future sin manejar: no tumba el proceso nativo, pero sí es ruido
  /// silencioso que además puede dejar la animación de resize a medias.
  void _safeResizeContent(int width, int height) {
    try {
      FloatyOverlay.resizeContent(width, height);
    } catch (e) {
      debugPrint('resizeContent failed (overlay window likely gone): $e');
    }
  }

  void _startDownload(OverlayModItem mod) {
    if (mod.downloadUrls.isEmpty) return;
    HapticFeedback.lightImpact();
    final title = mod.title;

    setState(() => _modStatus[title] = 'connecting');

    FloatyOverlay.shareData({
      'type': 'download_mod',
      'url': mod.downloadUrls.first,
      'modTitle': title,
      'section': mod.section.name,
    });

    _pendingTimers[title]?.cancel();
    _pendingTimers[title] = Timer(_bridgeTimeout, () {
      if (!mounted) return;
      if (_modStatus[title] == 'connecting') {
        setState(() => _modStatus.remove(title));
        _showToast(AppLocalizations.of(context).overlayNoResponse);
      }
    });
  }

  /// Cancela una descarga/instalación en curso. A diferencia del botón de
  /// "cancelled" que ya existía (que solo reacciona a eventos que YA
  /// vinieron del backend), esto lo dispara el usuario mientras está
  /// activa — el caso real que faltaba: instalación colgada por internet
  /// lento o zip corrupto, sin forma de salir de ahí.
  void _cancelDownload(OverlayModItem mod) {
    final title = mod.title;
    HapticFeedback.mediumImpact();
    _pendingTimers.remove(title)?.cancel();

    FloatyOverlay.shareData({'type': 'cancel_mod', 'modTitle': title});

    // Evita que un evento de progreso en vuelo (emitido antes de que
    // WorkManager procese la cancelación) re-active este tile.
    _cancelledMods.add(title);
    Future.delayed(const Duration(seconds: 10), () {
      _cancelledMods.remove(title);
    });

    // Limpieza optimista: no esperamos confirmación del bridge para que
    // el usuario recupere el control de inmediato, incluso si la
    // instalación estaba tan colgada que ni siquiera responde al mensaje.
    setState(() {
      _modStatus.remove(title);
      _modProgress.remove(title);
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _retro.ink,
          ),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: _retro.surfaceAlt,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: _retro.border.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  void _onOverlayData(Object? data) {
    if (data is! Map) return;
    final type = data['type'] as String?;
    if (type == 'db_reloaded') {
      ref.invalidate(overlayAllItems);
    } else if (type == 'install_progress') {
      final modTitle = data['modTitle'] as String?;
      final rawStatus = data['status'] as String?;
      final progress = data['progress'] as int?;
      if (modTitle == null || rawStatus == null || !mounted) return;
      if (_cancelledMods.contains(modTitle)) return;

      _pendingTimers.remove(modTitle)?.cancel();

      final mapped = _mapStatus(rawStatus);
      setState(() {
        _modStatus[modTitle] = mapped;
        if (progress != null) _modProgress[modTitle] = progress;
      });

      if (mapped == 'cancelled') {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _modStatus[modTitle] == 'cancelled') {
            setState(() {
              _modStatus.remove(modTitle);
              _modProgress.remove(modTitle);
            });
          }
        });
      }
    } else if (type == 'install_error') {
      final modTitle = data['modTitle'] as String?;
      final error = data['error'] as String?;
      if (modTitle == null || !mounted) return;
      if (_cancelledMods.contains(modTitle)) return;
      _pendingTimers.remove(modTitle)?.cancel();
      setState(() {
        _modStatus.remove(modTitle);
        _modProgress.remove(modTitle);
      });
      final message = switch (error) {
        'no_folder' => AppLocalizations.of(context).overlaySelectFolder,
        'auto_install_off' => AppLocalizations.of(context).overlayEnableAutoInstall,
        _ => AppLocalizations.of(context).overlayDownloadFailed,
      };
      _showToast(message);
    }
  }

  String _mapStatus(String raw) {
    switch (raw) {
      case 'BgDownloadProgress':
        return 'downloading';
      case 'BgInstallProgress':
        return 'installing';
      case 'completed':
      case 'BgInstallCompleted':
        return 'done';
      case 'BgOperationCancelled':
        return 'cancelled';
      default:
        if (raw.contains('Progress')) return 'downloading';
        if (raw.contains('Completed')) return 'done';
        return raw;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _searchCtrl.dispose();
    // Si el panel se cierra mientras el teclado seguía abierto, no dejamos
    // la ventana nativa agrandada — la próxima vez que se abra el overlay
    // debe arrancar en su tamaño de reposo.
    if (_resizedForKeyboard) {
      _safeResizeContent(_panelWidth, _panelHeight);
    }
    super.dispose();
  }


  void _switchSection(OverlaySection s) {
    if (s == ref.read(overlaySectionProvider)) return;
    HapticFeedback.selectionClick();
    ref.read(overlaySectionProvider.notifier).select(s);
    _searchCtrl.clear();
    ref.read(searchProviderFor(s).notifier).set('');
    ref.read(pageProviderFor(s).notifier).reset();
  }

  void _onSearchChanged(String v) {
    final section = ref.read(overlaySectionProvider);
    ref.read(searchProviderFor(section).notifier).set(v);
    ref.read(pageProviderFor(section).notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final section = ref.watch(overlaySectionProvider);
    final items = ref.watch(overlayPaginatedItems);
    final page = ref.watch(pageProviderFor(section));
    final totalPages = ref.watch(overlayTotalPages);

    // La ventana del overlay tiene alto fijo (`contentHeight: 340` en
    // settings_screen.dart) y corre en un engine de Flutter aparte —
    // Android dibuja el teclado del sistema (IME) POR ENCIMA de ventanas
    // tipo overlay, sin el ajuste de resize/pan que sí tienen las
    // Activities normales. Resultado: cualquier elemento anclado cerca del
    // borde inferior del panel queda tapado en cuanto se abre el teclado,
    // sin importar qué pongamos en `resizeToAvoidBottomInset`. La mitigación
    // real es de layout, no de flag: el campo en el que se está escribiendo
    // tiene que vivir arriba, no abajo, y lo secundario se repliega.
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _retro.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
          child: Column(
            children: [
              _SectionTabs(active: section, onTap: _switchSection),
              const SizedBox(height: 6),
              _SearchBar(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 6),
              if (totalPages > 1 && !keyboardOpen) ...[
                _PageBar(
                  current: page + 1,
                  total: totalPages,
                  onPrev: page > 0
                      ? () => ref
                          .read(pageProviderFor(section).notifier)
                          .set(page - 1)
                      : null,
                  onNext: page < totalPages - 1
                      ? () => ref
                          .read(pageProviderFor(section).notifier)
                          .set(page + 1)
                      : null,
                ),
                const SizedBox(height: 6),
              ],
              Expanded(
                child: items.when(
                  loading: () => const Center(child: _Spinner()),
                  error: (err, _) => _EmptyState(
                    icon: Icons.error_outline,
                    label: AppLocalizations.of(context).overlayError,
                    color: _retro.red,
                  ),
                  data: (mods) {
                    if (mods.isEmpty) {
                      return _EmptyState(
                        icon: Icons.search_off,
                        label: AppLocalizations.of(context).overlayNoResults,
                        color: _retro.inkDim,
                      );
                    }
                    return ListView.builder(
                      itemCount: mods.length,
                      itemBuilder: (context, i) => _ModTile(
                        mod: mods[i],
                        status: _modStatus[mods[i].title],
                        progress: _modProgress[mods[i].title],
                        onDownload: () => _startDownload(mods[i]),
                        onCancel: () => _cancelDownload(mods[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section tabs ─────────────────────────────────────────────────────────────
// Antes: subrayado plano de 2px sin identidad. Ahora: SkewChip denso (mismo
// componente que usan las screens reales de la app), con fade en los bordes
// para señalar que hay más tabs fuera de vista cuando no entran todas.

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.active, required this.onTap});

  final OverlaySection active;
  final ValueChanged<OverlaySection> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: const [0.0, 0.04, 0.94, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: OverlaySection.values.map((s) {
              return Padding(
                padding: const EdgeInsets.only(right: 7),
                child: SkewChip(
                  retro: _retro,
                  label: s.label,
                  selected: s == active,
                  dense: true,
                  onTap: () => onTap(s),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Page bar ──────────────────────────────────────────────────────────────────
// Flechas 32x32 (antes 20x20) — objetivo táctil real sobre un overlay donde
// el dedo tapa parte de la pantalla. Borde + sombra dura reducida (2px) para
// mantener el lenguaje visual sin pesar tanto como en pantallas grandes.

class _PageBar extends StatelessWidget {
  const _PageBar({
    required this.current,
    required this.total,
    this.onPrev,
    this.onNext,
  });

  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ArrowIcon(icon: Icons.chevron_left, enabled: onPrev != null, onTap: onPrev),
        const SizedBox(width: 10),
        RetroTag(retro: _retro, label: '$current / $total', dense: true),
        const SizedBox(width: 10),
        _ArrowIcon(icon: Icons.chevron_right, enabled: onNext != null, onTap: onNext),
      ],
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  const _ArrowIcon({required this.icon, required this.enabled, this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap?.call();
            }
          : null,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? _retro.surface : Colors.transparent,
          border: Border.all(
            color: enabled ? _retro.border.withValues(alpha: 0.5) : _retro.border.withValues(alpha: 0.12),
            width: 1.5,
          ),
          boxShadow: enabled ? _retro.hardShadow(dx: 2, dy: 2) : null,
        ),
        child: Icon(icon, size: 18, color: enabled ? _retro.accent : _retro.inkDim.withValues(alpha: 0.3)),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _retro.surface,
        border: Border.all(color: _retro.border.withValues(alpha: 0.4), width: 1.5),
        boxShadow: _retro.hardShadow(dx: 2, dy: 2),
      ),
      child: TextField(
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        cursorColor: _retro.accent,
        style: _retro.body(size: 11.5, weight: FontWeight.w600, color: _retro.ink),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).overlaySearchHint,
          hintStyle: _retro.body(size: 10.5, color: _retro.inkDim.withValues(alpha: 0.7)),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: _retro.accent.withValues(alpha: 0.8), size: 17),
        ),
      ),
    );
  }
}

// ── Empty / error state ────────────────────────────────────────────────────────
// Antes: Text suelto en gris genérico. Ahora reusa la paleta semántica real
// (retro.red para error) en vez de Colors.redAccent/white24 sueltos.

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: color.withValues(alpha: 0.55)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mod tile ──────────────────────────────────────────────────────────────────
// Antes: sin sombra, borde 1px al 30% de opacidad, estados de color
// arbitrarios (_accent para todo). Ahora: hardShadow denso + paleta
// semántica del changelog ya definida en RetroTheme (added/fixed/blue/red)
// para que cada estado se lea sin tener que leer el texto.

class _ModTile extends ConsumerStatefulWidget {
  const _ModTile({
    required this.mod,
    required this.onDownload,
    required this.onCancel,
    this.status,
    this.progress,
  });

  final OverlayModItem mod;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final String? status;
  final int? progress;

  @override
  ConsumerState<_ModTile> createState() => _ModTileState();
}

class _ModTileState extends ConsumerState<_ModTile> {
  bool get _isDone => widget.status == 'done';
  bool get _isConnecting => widget.status == 'connecting';
  bool get _isDownloading => widget.status == 'downloading';
  bool get _isInstalling => widget.status == 'installing';
  bool get _isActive => _isConnecting || _isDownloading || _isInstalling;
  bool get _hasSingleUrl => widget.mod.downloadUrls.length == 1;
  bool get _isCancelled => widget.status == 'cancelled';

  Color get _statusColor {
    if (_isDone) return _retro.changelogAdded;
    if (_isCancelled) return _retro.changelogRemoved;
    if (_isInstalling) return _retro.changelogFixed;
    if (_isDownloading) return _retro.changelogImproved;
    if (_isConnecting) return _retro.inkDim;
    return _retro.accent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: _retro.surface,
        border: Border.all(color: _retro.border.withValues(alpha: 0.35), width: 1.5),
        boxShadow: _retro.hardShadow(dx: 2, dy: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _titleRow()),
              const SizedBox(width: 6),
              if (_isDone)
                Icon(Icons.check_circle, size: 19, color: _statusColor)
              else if (!_hasSingleUrl)
                Icon(Icons.list_alt, size: 18, color: _retro.inkDim.withValues(alpha: 0.5))
              else if (_isCancelled)
                _RoundIconButton(
                  icon: Icons.refresh,
                  color: _statusColor,
                  onTap: widget.onDownload,
                )
              else if (!_isActive)
                _RoundIconButton(
                  icon: Icons.download,
                  color: _retro.accent,
                  onTap: widget.onDownload,
                )
              else
                GestureDetector(
                  onTap: widget.onCancel,
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          value: _isDownloading && widget.progress != null
                              ? widget.progress! / 100.0
                              : null,
                          color: _statusColor,
                          backgroundColor: _statusColor.withValues(alpha: 0.15),
                        ),
                        Icon(Icons.close, size: 12, color: _statusColor),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_isActive) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: _isDownloading && widget.progress != null
                  ? widget.progress! / 100.0
                  : null,
              backgroundColor: _statusColor.withValues(alpha: 0.12),
              color: _statusColor,
              minHeight: 3,
            ),
            const SizedBox(height: 3),
            Text(
              AppLocalizations.of(context).overlayTapToCancel,
              style: TextStyle(
                color: _statusColor.withValues(alpha: 0.55),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _titleRow() {
    final l10n = AppLocalizations.of(context);
    final label = _isDownloading && widget.progress != null
        ? '${widget.mod.title}  ${widget.progress}%'
        : _isInstalling
            ? '${widget.mod.title}  ${l10n.overlayInstalling}'
            : _isConnecting
                ? '${widget.mod.title}  ${l10n.overlayConnecting}'
                : widget.mod.title;

    return Text(
      label,
      style: _retro.body(
        size: 11,
        weight: FontWeight.w700,
        color: _isDone ? _statusColor : _retro.ink,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ── Round icon button ───────────────────────────────────────────────────────
// Botón de descarga: 30x30 (antes 24x24), con hardShadow denso.

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
          boxShadow: _retro.hardShadow(dx: 2, dy: 2),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: _retro.accent),
    );
  }
}
