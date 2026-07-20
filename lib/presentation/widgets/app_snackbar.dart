import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';

/// Centralised snackbar helper — consistent styling across the entire app.
///
/// Visual design:
///  - Tarjeta flotante con borde duro (sin esquinas redondeadas) y sombra
///    desplazada, coherente con el resto del sistema retro.
///  - Barra de acento sólida a la izquierda (verde/rojo/azul) en vez de
///    fondo completo coloreado.
///  - Ícono en una caja bordeada + mensaje.
///  - Pop de rebote liviano al aparecer (TweenAnimationBuilder de un solo
///    uso, sin AnimationController que mantener/limpiar) — se monta encima
///    de la animación de entrada nativa del SnackBar, no la reemplaza.
class AppSnackbar {
  AppSnackbar._();

  // ── Public API ───────────────────────────────────────────────────────────

  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    IconData icon = Icons.check_circle_rounded,
  }) {
    _show(
      context,
      accentOf: (retro) => retro.accent,
      icon: icon,
      message: message,
      duration: duration,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.error_rounded,
  }) {
    _show(
      context,
      accentOf: (retro) => retro.red,
      icon: icon,
      message: message,
      duration: duration,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    IconData icon = Icons.info_outline_rounded,
  }) {
    _show(
      context,
      accentOf: (retro) => retro.blue,
      icon: icon,
      message: message,
      duration: duration,
    );
  }

  // ── Internal builder ─────────────────────────────────────────────────────

  static void _show(
    BuildContext context, {
    required Color Function(RetroTheme retro) accentOf,
    required IconData icon,
    required String message,
    required Duration duration,
  }) {
    final retro = RetroTheme.of(context);
    final accent = accentOf(retro);
    final scaffold = ScaffoldMessenger.of(context);

    // Clear any existing snackbar first to avoid stacking
    scaffold.clearSnackBars();

    scaffold.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        content: _BouncyToast(
          child: Container(
            decoration: BoxDecoration(
              color: retro.surface,
              border: Border.all(color: retro.border, width: 2.5),
              boxShadow: retro.hardShadow(dx: 4, dy: 4),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Barra de acento sólida ──────────────────────
                  Container(width: 5, color: accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 13, 14, 13),
                      child: Row(
                        children: [
                          Icon(icon, size: 20, color: accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: retro.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bouncy entrance ────────────────────────────────────────────────────────
// Pop liviano al aparecer: escala de 0.85 a 1.0 con leve rebote
// (easeOutBack), un solo TweenAnimationBuilder sin controller que limpiar.
// Se monta encima del slide-up nativo del SnackBar en vez de reemplazarlo.

class _BouncyToast extends StatelessWidget {
  const _BouncyToast({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, alignment: Alignment.bottomCenter, child: child),
      child: child,
    );
  }
}
