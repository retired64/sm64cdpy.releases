import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';

/// Settings-only surfaces. The visual policy belongs to the bundled design;
/// it never changes catalogue cards or installation state.
extension SettingsSurfaces on RetroTheme {
  BoxDecoration settingsPanel({
    Color? borderColor,
    double width = 2,
    double dx = 2,
    double dy = 2,
  }) {
    final soft = design.softSettingsPanels;
    if (usesBeveledSurfaces) {
      return surfaceDecoration(
        borderColor: border.withValues(alpha: 0.75),
        border: 1.5,
        shadowDx: dx,
        shadowDy: dy,
      );
    }
    return BoxDecoration(
      color: surface,
      borderRadius: radius,
      border: Border.all(
        color: borderColor ?? (soft ? border.withValues(alpha: 0.4) : border),
        width: borderWidth(soft ? 1 : width),
      ),
      boxShadow: soft
          ? [
              BoxShadow(
                color: shadowColor.withValues(alpha: isDark ? 0.2 : 0.08),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ]
          : hardShadow(dx: dx, dy: dy),
    );
  }
}

/// Shared header/options presentation with the language selector's original
/// 200 ms arrow rotation and 220 ms size animation. An optional controlled
/// value lets a selector collapse after awaiting its own save.
class SettingsExpansionGroup extends StatefulWidget {
  const SettingsExpansionGroup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    this.expanded,
    this.onExpansionChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  final bool? expanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<SettingsExpansionGroup> createState() => _SettingsExpansionGroupState();
}

class _SettingsExpansionGroupState extends State<SettingsExpansionGroup> {
  bool _expanded = false;
  bool _restored = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restored) return;
    _restored = true;
    final saved = PageStorage.maybeOf(context)?.readState(context);
    if (saved is bool && widget.expanded == null) _expanded = saved;
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final expanded = widget.expanded ?? _expanded;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          child: InkWell(
            borderRadius: retro.radius,
            onTap: () {
              if (widget.expanded == null) {
                setState(() => _expanded = !expanded);
                PageStorage.maybeOf(context)?.writeState(context, !expanded);
              }
              widget.onExpansionChanged?.call(!expanded);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(widget.icon, color: retro.accentText),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: retro.heading(size: 14)),
                        const SizedBox(height: 3),
                        Text(widget.subtitle, style: retro.body(size: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.expand_more,
                      color: expanded ? retro.accentText : retro.inkDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.children,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: retro.design.softSettingsPanels
            ? retro.settingsPanel()
            : const BoxDecoration(),
        child: content,
      ),
    );
  }
}

class SettingsSelectionOption extends StatelessWidget {
  const SettingsSelectionOption({
    super.key,
    required this.label,
    required this.leading,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final Widget leading;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        selected: selected,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            side: BorderSide(
              color: selected ? retro.accent : retro.border,
              width: retro.borderWidth(2),
            ),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: retro.heading(size: 14))),
              if (selected)
                MarioMenuGlyph(
                  retro: retro,
                  asset: 'hand',
                  fallback: retro.isMario
                      ? Icons.pan_tool_alt_rounded
                      : Icons.check_circle,
                  color: retro.design.playfulSelection
                      ? retro.secondaryAccent
                      : retro.accentText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
