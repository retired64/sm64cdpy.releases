import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';

/// Menu controls shared by folder setup and ROM preparation. They deliberately
/// inherit the current design, including private ROM textures and glyphs.
class GameSetupAction extends StatelessWidget {
  const GameSetupAction({super.key, required this.label, required this.icon,
    required this.onPressed, this.primary = false});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final foreground = primary ? retro.inkOnAccent : retro.ink;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: onPressed == null ? 0.5 : 1,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: retro.surfaceDecoration(
              color: primary ? retro.accent : retro.surfaceAlt,
              shadowDx: 2, shadowDy: 2,
            ),
            child: InkWell(
              borderRadius: retro.radius,
              onTap: onPressed,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(children: [
                    MarioGameIcon(icon, color: foreground, size: 22),
                    const SizedBox(width: 12),
                    Expanded(child: Text(retro.displayLabel(label),
                      style: retro.heading(size: 15, color: foreground, height: 1.3))),
                    if (primary) ...[
                      const SizedBox(width: 8),
                      MarioMenuGlyph(retro: retro, asset: 'hand',
                        fallback: Icons.arrow_forward_rounded, color: foreground, size: 20),
                    ],
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameSetupStatus extends StatelessWidget {
  const GameSetupStatus({super.key, required this.label, required this.icon,
    this.detail, this.ready});
  final String label;
  final String? detail;
  final IconData icon;
  final bool? ready;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MarioGameIcon(icon, color: retro.accentText, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: retro.body(size: 16, height: 1.4)),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(detail!, style: retro.body(size: 16, color: retro.inkDim, height: 1.4)),
          ],
        ])),
        if (ready != null) ...[
          const SizedBox(width: 8),
          Icon(ready! ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
            color: ready! ? retro.accentText : retro.inkDim, size: 20),
        ],
      ]),
    );
  }
}

/// One scrollable, readable route for setup, reconnect, disconnect and resources.
/// Stacked actions remain reachable with large text and short landscape screens.
Future<bool?> showGameSetupDialog(BuildContext context, {
  required String title, required String body, required String confirm,
  required String cancel, required IconData icon, bool showFolder = false,
}) {
  return showDialog<bool>(context: context, builder: (dialogContext) {
    final retro = RetroTheme.of(dialogContext);
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: retro.surfaceDecoration(shadowDx: 5, shadowDy: 5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Align(alignment: AlignmentDirectional.centerStart,
                child: MarioGameIcon(icon, color: retro.accentText, size: 36)),
              const SizedBox(height: 16),
              Semantics(namesRoute: true,
                child: MarioGameTitle(text: title, retro: retro, size: 20)),
              if (showFolder) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: retro.surfaceDecoration(color: retro.surfaceAlt,
                    shadowDx: 1, shadowDy: 1),
                  child: Row(children: [
                    MarioGameIcon(Icons.folder_open_rounded, color: retro.accentText),
                    const SizedBox(width: 12),
                    Expanded(child: Text('com.maniscat2.sm64coopdx/\nuser/',
                      style: retro.body(size: 16, height: 1.5))),
                  ]),
                ),
              ],
              const SizedBox(height: 18),
              Text(body, style: retro.body(size: 16, height: 1.5)),
              const SizedBox(height: 24),
              GameSetupAction(label: confirm, icon: icon, primary: true,
                onPressed: () => Navigator.pop(dialogContext, true)),
              const SizedBox(height: 12),
              GameSetupAction(label: cancel, icon: Icons.close_rounded,
                onPressed: () => Navigator.pop(dialogContext, false)),
            ]),
        ),
      ),
    );
  });
}
