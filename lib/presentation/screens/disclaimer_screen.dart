import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/retro_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DisclaimerScreen
// Bilingual disclaimer screen (EN / ES) with animated language toggle.
// A floating "Translate" button sits fixed at the bottom via Stack so it
// never covers the scrollable content; it cross-fades the body on switch.
// ─────────────────────────────────────────────────────────────────────────────

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen>
    with TickerProviderStateMixin {
  bool _isSpanish = false;
  bool _switching = false;

  // Cross-fade controller for content swap
  late final AnimationController _langCtrl;
  late final Animation<double> _fadeOut;
  late final Animation<double> _fadeIn;

  // Subtle intro pulse on the translate button to hint it's interactive
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _langCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _langCtrl,
        curve: const Interval(0.0, 0.46, curve: Curves.easeIn),
      ),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _langCtrl,
        curve: const Interval(0.54, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.035,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _pulseCtrl.stop();
    });
  }

  @override
  void dispose() {
    _langCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleLanguage() async {
    if (_switching) return;
    _switching = true;
    _langCtrl.reset();
    // Phase 1 — fade out current content
    await _langCtrl.animateTo(0.46);
    if (mounted) setState(() => _isSpanish = !_isSpanish);
    // Phase 2 — fade in new content
    await _langCtrl.animateTo(1.0);
    _langCtrl.reset();
    _switching = false;
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Stack(
      children: [
        Column(
          children: [
            SafeArea(
              bottom: false,
              child: Container(
                height: 56,
                color: retro.background,
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    const DrawerMenuButton(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: Text(
                          _isSpanish ? 'Aviso Legal' : 'Disclaimer',
                          key: ValueKey(_isSpanish),
                          style: retro.heading(size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _langCtrl,
                builder: (context, child) {
                  final double opacity;
                  if (!_langCtrl.isAnimating) {
                    opacity = 1.0;
                  } else if (_langCtrl.value <= 0.46) {
                    opacity = _fadeOut.value;
                  } else {
                    opacity = _fadeIn.value;
                  }
                  return Opacity(
                      opacity: opacity.clamp(0.0, 1.0), child: child);
                },
                child: _DisclaimerBody(isSpanish: _isSpanish),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 100,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    retro.background.withValues(alpha: 0),
                    retro.background,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: _TranslateButton(
            isSpanish: _isSpanish,
            pulse: _pulse,
            pulseCtrl: _pulseCtrl,
            onTap: _toggleLanguage,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scrollable body — isolated so AnimatedBuilder rebuilds only the opacity
// wrapper, not the entire subtree on every animation tick.
// ─────────────────────────────────────────────────────────────────────────────
class _DisclaimerBody extends StatelessWidget {
  const _DisclaimerBody({required this.isSpanish});
  final bool isSpanish;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 8),
        _HeroBadge(isSpanish: isSpanish),
        const SizedBox(height: 28),

        // Sections
        ...(_isSpanish(isSpanish) ? _sectionsEs : _sectionsEn).map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DisclaimerSection(
              icon: s.icon,
              title: s.title,
              body: s.body,
            ),
          ),
        ),
        const SizedBox(height: 8),

        _WarningBanner(isSpanish: isSpanish),
        const SizedBox(height: 20),

        // ── What's new badge ───────────────────────────────────────────
        _WhatsNewBanner(isSpanish: isSpanish),
        const SizedBox(height: 28),

        _SectionLabel(
          isSpanish ? 'Contacto del desarrollador' : 'Developer contact',
        ),
        const SizedBox(height: 12),
        _ContactButton(
          asset: 'assets/icons/discord-chat.svg',
          platform: 'Discord',
          handle: isSpanish
              ? 'Escríbeme en mi servidor de Discord'
              : 'Reach me on my Discord server',
          url: 'https://discord.com/invite/thuhUH2WNX',
        ),
        const SizedBox(height: 28),

        Center(
          child: Text(
            isSpanish
                ? 'v1.4.4 \u00b7 para uso personal \u00b7 No oficial'
                : 'v1.4.4 \u00b7 for personal use \u00b7 Unofficial',
            style: retro.body(size: 11),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // Tiny helper to avoid using a local variable with the same name as param
  bool _isSpanish(bool v) => v;
}

// ─────────────────────────────────────────────────────────────────────────────
// Content data model
// ─────────────────────────────────────────────────────────────────────────────
class _SectionData {
  const _SectionData({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

const _sectionsEn = [
  _SectionData(
    icon: Icons.person_rounded,
    title: 'Personal purpose',
    body:
        'This application was independently developed as a personal project. '
        'Its sole purpose is to give me faster access, organization, and '
        'download management for mods I use for my own entertainment. '
        'It is not an application supported by the SM64CoopDX team or an official service of any kind.',
  ),
  _SectionData(
    icon: Icons.link_off_rounded,
    title: 'No official affiliation',
    body:
        'This project is not associated with, endorsed by, or approved by '
        'the developers of SM64CoopDX, Super Mario 64, Nintendo, or any of '
        'the mod creators listed. All names, images, and content displayed '
        'belong to their respective authors.',
  ),
  _SectionData(
    icon: Icons.storage_rounded,
    title: 'Data source',
    body:
        'Mod information comes from the public catalog at '
        'mods.sm64coopdx.com. This app only presents that information in '
        'a more accessible way; it does not host, modify, or redistribute '
        'any mod files.',
  ),
  _SectionData(
    icon: Icons.auto_awesome_rounded,
    title: 'Exclusive sections (VIP · DynOS · Touch Controls)',
    body:
        'Starting with v1.4.2, the app includes curated sections with '
        'content not officially listed on the SM64CoopDX website. These '
        'sections (VIP Mods, DynOS packs, and Touch Control layouts) are '
        'maintained independently by the developer and are not affiliated '
        'with any official source. All credit goes to the original creators.',
  ),
  _SectionData(
    icon: Icons.bug_report_rounded,
    title: 'Bugs, suggestions & requests',
    body:
        'If you find an issue with this app, have a suggestion, or want to '
        'request something, contact me directly through my social media. '
        'Please do not contact the official SM64CoopDX developers or mod '
        'creators about anything related to this application.',
  ),
];

const _sectionsEs = [
  _SectionData(
    icon: Icons.person_rounded,
    title: 'Propósito personal',
    body:
        'Esta aplicación fue desarrollada de forma independiente como un '
        'proyecto personal. Su único objetivo es facilitarme el acceso, '
        'organización y descarga de mods que uso para mi propio '
        'entretenimiento. No es una aplicación respaldada por el equipo de SM64CoopDX ni un servicio '
        'oficial de ningún tipo.',
  ),
  _SectionData(
    icon: Icons.link_off_rounded,
    title: 'Sin afiliación oficial',
    body:
        'Este proyecto no está asociado, respaldado ni aprobado por los '
        'desarrolladores de SM64CoopDX, Super Mario 64, Nintendo, ni por '
        'ninguno de los creadores de los mods listados. Los nombres, '
        'imágenes y contenido mostrados pertenecen a sus respectivos autores.',
  ),
  _SectionData(
    icon: Icons.storage_rounded,
    title: 'Fuente de datos',
    body:
        'La información de los mods proviene del catálogo público de '
        'mods.sm64coopdx.com. Esta app únicamente presenta esa información '
        'de manera más accesible; no aloja, modifica ni redistribuye '
        'ningún archivo de mod.',
  ),
  _SectionData(
    icon: Icons.auto_awesome_rounded,
    title: 'Secciones exclusivas (VIP · DynOS · Touch Controls)',
    body:
        'A partir de la v1.4.2, la app incluye secciones curadas con '
        'contenido que no está listado oficialmente en el sitio de SM64CoopDX. '
        'Estas secciones (VIP Mods, packs de DynOS y layouts de Touch Controls) '
        'son mantenidas de forma independiente por el desarrollador y no tienen '
        'ninguna afiliación con ninguna fuente oficial. Todo el crédito '
        'pertenece a los creadores originales.',
  ),
  _SectionData(
    icon: Icons.bug_report_rounded,
    title: 'Errores, sugerencias o solicitudes',
    body:
        'Si encuentras algún problema con esta app, tienes una sugerencia '
        'o quieres pedir algo, contáctame directamente a través de mis '
        'redes sociales. Por favor, no contactes a los desarrolladores '
        'oficiales de SM64CoopDX ni a los creadores de mods por asuntos '
        'relacionados con esta aplicación.',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Hero badge
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.isSpanish});
  final bool isSpanish;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: retro.surface,
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.border, width: 2.5),
            boxShadow: retro.hardShadow(),
          ),
          child: Icon(Icons.info_outline, size: 38, color: retro.accent),
        ),
        const SizedBox(height: 16),
        Text(
          isSpanish ? 'App No Oficial' : 'Unofficial Fan-Made',
          style: retro.heading(size: 22),
        ),
        const SizedBox(height: 5),
        RetroTag(
          retro: retro,
          label: 'SM64CoopDX Mods Manager',
          filled: true,
          dense: true,
        ),
        const SizedBox(height: 8),
        // Version pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: retro.surface,
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.border, width: 1),
          ),
          child: Text(
            'v1.4.2',
            style: retro.body(size: 11),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// What's new banner — v1.4.2
// ─────────────────────────────────────────────────────────────────────────────
class _WhatsNewBanner extends StatelessWidget {
  const _WhatsNewBanner({required this.isSpanish});
  final bool isSpanish;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    final items = isSpanish
        ? [
            (
              Icons.phone_android,
              'Descarga e instalación en segundo plano — notificación persistente con progreso real y botón de cancelar',
            ),
            (
              Icons.notifications_active,
              'Notificaciones de progreso aunque salgas de la app — descarga, instalación, cancelación y reintento',
            ),
            (
              Icons.folder_zip,
              'ZIP copiado automáticamente a la carpeta de mods cuando auto-instalación está desactivada',
            ),
          ]
        : [
            (
              Icons.phone_android,
              'Background download & install — persistent notification with real progress and cancel button',
            ),
            (
              Icons.notifications_active,
              'Progress notifications even outside the app — download, install, cancel, and retry',
            ),
            (
              Icons.folder_zip,
              'ZIP auto-copied to mods folder when auto-install is off',
            ),
          ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: retro.surface,
        borderRadius: RetroTheme.radius,
        border: Border.all(color: retro.amber, width: 1.5),
        boxShadow: retro.hardShadow(dx: 3, dy: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.new_releases, size: 16, color: retro.amber),
              const SizedBox(width: 8),
              Text(
                isSpanish ? 'Novedades en v1.4.2' : "What's new in v1.4.2",
                style: TextStyle(
                  color: retro.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$1, size: 14, color: retro.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: TextStyle(
                        color: retro.inkDim,
                        fontSize: 12.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
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
// Section card
// ─────────────────────────────────────────────────────────────────────────────
class _DisclaimerSection extends StatelessWidget {
  const _DisclaimerSection({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: retro.surface,
        borderRadius: RetroTheme.radius,
        border: Border.all(color: retro.border, width: 2),
        boxShadow: retro.hardShadow(dx: 2, dy: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: retro.surfaceAlt,
              borderRadius: RetroTheme.radius,
              border: Border.all(color: retro.accent, width: 1.5),
            ),
            child: Icon(icon, size: 18, color: retro.accent),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: retro.heading(size: 13)),
                const SizedBox(height: 5),
                Text(body, style: retro.body(size: 12.5, height: 1.56)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Warning banner
// ─────────────────────────────────────────────────────────────────────────────
class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.isSpanish});
  final bool isSpanish;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: retro.surface,
        borderRadius: RetroTheme.radius,
        border: Border.all(color: retro.red, width: 2),
        boxShadow: retro.hardShadow(dx: 3, dy: 3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, size: 20, color: retro.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isSpanish
                  ? 'Esta app es un proyecto personal. Cualquier '
                        'problema relacionado con ella (Funcionalidad, errores, etc.) es responsabilidad '
                        'exclusiva del desarrollador. Los desarrolladores de '
                        'SM64CoopDX y los creadores de mods no tienen ninguna '
                        'responsabilidad sobre esta aplicación.'
                  : 'This app is a personal project. Any issues '
                        'related to it (functionality, bugs, etc.) are the sole responsibility of the '
                        'developer. The SM64CoopDX developers and mod creators '
                        'bear no responsibility whatsoever for this application.',
              style: TextStyle(
                color: retro.ink,
                fontSize: 12,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Text(label.toUpperCase(), style: retro.heading(size: 10, color: retro.inkDim, letterSpacing: 1.5));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact button — full-width Discord banner button
// ─────────────────────────────────────────────────────────────────────────────
class _ContactButton extends StatefulWidget {
  const _ContactButton({
    required this.asset,
    required this.platform,
    required this.handle,
    required this.url,
  });
  final String asset;
  final String platform;
  final String handle;
  final String url;

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Future<void> _launch(BuildContext context) async {
    try {
      await launchUrl(
        Uri.parse(widget.url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.error(context, message: 'Could not open the link');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    const blurple = Color(0xFF5865F2);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        _launch(context);
      },
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: SvgPicture.asset(
                widget.asset,
                height: 100,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: blurple,
                borderRadius: RetroTheme.radius,
                border: Border.all(color: retro.border, width: 2.5),
                boxShadow: retro.hardShadow(dx: 4, dy: 4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.discord, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.handle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: RetroTheme.radius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Colors.white,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Floating translate button
// ─────────────────────────────────────────────────────────────────────────────
class _TranslateButton extends StatefulWidget {
  const _TranslateButton({
    required this.isSpanish,
    required this.pulse,
    required this.pulseCtrl,
    required this.onTap,
  });
  final bool isSpanish;
  final Animation<double> pulse;
  final AnimationController pulseCtrl;
  final VoidCallback onTap;

  @override
  State<_TranslateButton> createState() => _TranslateButtonState();
}

class _TranslateButtonState extends State<_TranslateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 85),
      reverseDuration: const Duration(milliseconds: 170),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([widget.pulse, _pressCtrl]),
      builder: (context, _) {
        final pulseScale = widget.pulseCtrl.isAnimating
            ? widget.pulse.value
            : 1.0;
        return Transform.scale(
          scale: pulseScale * _pressScale.value,
          child: GestureDetector(
            onTapDown: (_) => _pressCtrl.forward(),
            onTapCancel: () => _pressCtrl.reverse(),
            onTapUp: (_) {
              _pressCtrl.reverse();
              widget.onTap();
            },
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: retro.accent,
                borderRadius: RetroTheme.radius,
                border: Border.all(color: retro.border, width: 2.5),
                boxShadow: retro.hardShadow(dx: 4, dy: 4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.translate,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Text(
                      widget.isSpanish
                          ? 'Translate to English'
                          : 'Traducir al Español',
                      key: ValueKey(widget.isSpanish),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
