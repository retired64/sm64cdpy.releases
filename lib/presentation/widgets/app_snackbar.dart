import 'package:flutter/material.dart';

/// Centralised snackbar helper — consistent styling across the entire app.
///
/// Visual design:
///  - Floating card with 16 px rounded corners and horizontal margin
///  - Subtle left border accent (green/red/gold) instead of full coloured bg
///  - Icon + message row with proper colourScheme-driven text colours
///  - Dark mode: background is surfaceContainerHigh, no eye-strain solid blocks
class AppSnackbar {
  AppSnackbar._();

  // ── Border accent colours ───────────────────────────────────────────────
  static const Color _successAccent = Color(0xFF4CAF50);
  static const Color _errorAccent = Color(0xFFE53935);
  static const Color _infoAccent = Color(0xFF90A4AE);

  // ── Public API ───────────────────────────────────────────────────────────

  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    IconData icon = Icons.check_circle_rounded,
  }) {
    _show(context, accent: _successAccent, icon: icon, message: message, duration: duration);
  }

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.error_rounded,
  }) {
    _show(context, accent: _errorAccent, icon: icon, message: message, duration: duration);
  }

  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    IconData icon = Icons.info_outline_rounded,
  }) {
    _show(context, accent: _infoAccent, icon: icon, message: message, duration: duration);
  }

  // ── Internal builder ─────────────────────────────────────────────────────

  static void _show(
    BuildContext context, {
    required Color accent,
    required IconData icon,
    required String message,
    required Duration duration,
  }) {
    final cs = Theme.of(context).colorScheme;
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
        content: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: accent, width: 3),
              top: BorderSide(color: cs.outline.withValues(alpha: 0.25)),
              right: BorderSide(color: cs.outline.withValues(alpha: 0.25)),
              bottom: BorderSide(color: cs.outline.withValues(alpha: 0.25)),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
