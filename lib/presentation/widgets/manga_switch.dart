import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';

/// Interruptor de tinta y papel: la posición y el relleno comunican el estado.
/// El valor pertenece al consumidor; aquí no se guarda ni se anticipa estado.
class MangaSwitch extends StatelessWidget {
  const MangaSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final enabled = onChanged != null;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 140);
    void toggle() => onChanged?.call(!value);
    return Semantics(
      toggled: value,
      enabled: enabled,
      onTap: enabled ? toggle : null,
      child: ExcludeSemantics(
        child: SizedBox(
          width: 56,
          height: 48,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? toggle : null,
              canRequestFocus: enabled,
              customBorder: const RoundedRectangleBorder(),
              focusColor: retro.accent.withValues(alpha: 0.2),
              hoverColor: retro.accent.withValues(alpha: 0.1),
              child: Center(
                child: Opacity(
                  opacity: enabled ? 1 : 0.45,
                  child: AnimatedContainer(
                    duration: duration,
                    width: 52,
                    height: 30,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: value ? retro.ink : retro.surfaceAlt,
                      border: Border.all(color: retro.ink, width: retro.borderWidth(2)),
                    ),
                    child: AnimatedAlign(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: value ? retro.background : retro.surface,
                          border: Border.all(
                            color: value ? retro.background : retro.ink,
                            width: retro.borderWidth(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Conserva SwitchListTile Material en los demás temas; Manga usa el mismo
/// control rectangular que Biblioteca y Ajustes, con toda la fila pulsable.
class ThemedSwitchListTile extends StatelessWidget {
  const ThemedSwitchListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.secondary,
  });
  final Widget title;
  final Widget? subtitle;
  final Widget? secondary;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (!RetroTheme.of(context).showJapaneseDecorations) {
      return SwitchListTile(
        title: title, subtitle: subtitle, secondary: secondary,
        value: value, onChanged: onChanged,
      );
    }
    return MergeSemantics(
      child: ListTile(
        leading: secondary,
        title: title,
        subtitle: subtitle,
        enabled: onChanged != null,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        trailing: MangaSwitch(value: value, onChanged: onChanged),
      ),
    );
  }
}
