import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import 'mario_multicolor_label.dart';

/// Cabecera compartida: mismo asset ligero que la opción del menú deslizable.
class MangaSubmenuHeader extends StatelessWidget {
  const MangaSubmenuHeader({
    super.key,
    required this.title,
    required this.asset,
    required this.fallbackIcon,
  });

  final String title;
  final String asset;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
      child: Row(children: [
        Image.asset(
          asset,
          width: 40,
          height: 40,
          cacheWidth: 128,
          cacheHeight: 128,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => Icon(fallbackIcon, color: retro.ink),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            header: true,
            label: title,
            child: ExcludeSemantics(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: MarioMulticolorLabel(
                  label: title,
                  fontSize: 20,
                  keyPrefix: 'manga-submenu-title',
                ),
              ),
            ),
          ),
        ),
        const CloseButton(),
      ]),
    );
  }
}
