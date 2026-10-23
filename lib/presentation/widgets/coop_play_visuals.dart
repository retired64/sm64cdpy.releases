import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import 'game_setup_widgets.dart';
import 'mario_multicolor_label.dart';

const coopPlayReadingSize = 8.4;

/// Presentación pura: no conoce providers, permisos ni el motor de sesión.
TextStyle coopPlayBody(RetroTheme retro, {
  double size = 15,
  Color? color,
  double height = 1.45,
}) {
  final base = retro.body(size: size, color: color, height: height);
  if (!retro.isDeluxe) return base;
  return base.copyWith(
    fontFamily: 'SuperMarioWorldTextBox',
    fontFamilyFallback: const ['Roboto'],
    fontWeight: FontWeight.w400,
  );
}

class CoopPlayTitle extends StatelessWidget {
  const CoopPlayTitle({super.key, required this.label, this.size = 20});
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isManga) return Text(label, style: retro.heading(size: size));
    return Semantics(
      header: true,
      label: label,
      child: ExcludeSemantics(child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: MarioMulticolorLabel(
          label: label, fontSize: size, keyPrefix: 'coop-title-$label',
        ),
      )),
    );
  }
}

class CoopPlayIcon extends StatelessWidget {
  const CoopPlayIcon({super.key, this.asset = 'play', this.size = 40});
  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/themes/manga/navigation/$asset.webp',
    width: size, height: size, cacheWidth: 128, cacheHeight: 128,
    excludeFromSemantics: true,
    errorBuilder: (_, _, _) => const Icon(Icons.sports_esports_outlined),
  );
}

class CoopPlayAction extends StatelessWidget {
  const CoopPlayAction({super.key, required this.label, required this.icon,
    required this.onPressed, this.primary = false, this.labelStyle});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isManga) return GameSetupAction(
      label: label, icon: icon, onPressed: onPressed, primary: primary,
    );
    final foreground = primary ? retro.inkOnAccent : retro.ink;
    return Padding(
      padding: const EdgeInsets.only(right: 3, bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: retro.surfaceDecoration(
            color: primary ? retro.accent : retro.surfaceAlt,
            shadowDx: 3, shadowDy: 3,
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: retro.radius,
            child: Opacity(
              opacity: onPressed == null ? 0.5 : 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: [
                    if (primary)
                      const CoopPlayIcon(size: 36)
                    else
                      Icon(icon, color: foreground, size: 24),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label, style: labelStyle ?? retro.heading(
                      size: 18, color: foreground, height: 1.3,
                    ).copyWith(
                      fontFamily: retro.isDeluxe ? 'SupremeSpike' : retro.headingFamily,
                      fontWeight: FontWeight.w400,
                      fontFamilyFallback: const ['Roboto'],
                    ))),
                    if (primary) Icon(Icons.arrow_forward_rounded, color: foreground, size: 20),
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

/// Instrucciones del juego: misma lectura que la introducción, sin lógica de red.
class CoopPlayInstructions extends StatelessWidget {
  const CoopPlayInstructions({super.key, required this.label, this.detail, this.ready});
  final String label;
  final String? detail;
  final bool? ready;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded, color: retro.accentText, size: 24),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: coopPlayBody(retro, size: coopPlayReadingSize, height: 1.4)),
        if (detail != null) ...[
          const SizedBox(height: 4),
          Text(detail!, style: coopPlayBody(retro,
            size: coopPlayReadingSize, color: retro.inkDim, height: 1.4)),
        ],
      ])),
      if (ready != null) ...[
        const SizedBox(width: 8),
        Icon(ready! ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
          color: ready! ? retro.accentText : retro.inkDim, size: 20),
      ],
    ]);
  }
}
