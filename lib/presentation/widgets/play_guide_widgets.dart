import 'package:flutter/material.dart';

import '../../core/theme/app_theme_design.dart';
import '../../core/theme/retro_theme.dart';

/// A chapter's visual language follows the actual theme's materials and shapes.
/// No ROM image, blur, looped animation or fixed text-height is needed.
class PlayGuideChapter extends StatelessWidget {
  const PlayGuideChapter({super.key, required this.number, required this.label,
    required this.title, required this.icon});
  final int number;
  final String label, title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final minimal = retro.design.surfaceTreatment == AppSurfaceTreatment.minimal;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: retro.surfaceDecoration(shadowDx: 4, shadowDy: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('$label ${number.toString().padLeft(2, '0')} / 06',
            style: retro.body(size: 12, weight: FontWeight.w800, color: retro.accentText))),
          MarioGameIcon(icon, size: 28, color: retro.accentText),
        ]),
        const SizedBox(height: 12),
        Text(title, style: retro.heading(size: 23, height: 1.2)),
        const SizedBox(height: 16),
        if (minimal)
          Divider(height: 1, color: retro.border)
        else
          SizedBox(height: 10, width: double.infinity,
            child: CustomPaint(painter: _ChapterTrim(retro: retro))),
      ]),
    );
  }
}

/// Each action or explanation gets a separate reading surface and a clear anchor.
class PlayGuideCard extends StatelessWidget {
  const PlayGuideCard({super.key, required this.text, required this.number,
    this.tipLabel, this.title});
  final String text;
  final int number;
  final String? tipLabel, title;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final minimal = retro.design.surfaceTreatment == AppSurfaceTreatment.minimal;
    final manga = retro.design.id == AppThemeId.retroManga;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: minimal ? BoxDecoration(color: retro.surface,
          borderRadius: retro.radius, border: Border.all(color: retro.border)) : retro.surfaceDecoration(
          color: tipLabel == null ? retro.surface : retro.surfaceAlt,
          shadowDx: manga ? 3 : 1, shadowDy: manga ? 3 : 1,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: minimal ? Colors.transparent : retro.accent,
                borderRadius: retro.radius,
                border: minimal ? Border.all(color: retro.border) : null,
              ),
              child: tipLabel != null
                ? Icon(Icons.lightbulb_outline_rounded, size: 20,
                    color: minimal ? retro.accentText : retro.inkOnAccent)
                : Text(number.toString().padLeft(2, '0'), textAlign: TextAlign.center,
                    style: retro.heading(size: 15,
                      color: minimal ? retro.ink : retro.inkOnAccent)),
            ),
            const SizedBox(width: 10),
            if (title != null || tipLabel != null)
              Expanded(child: Text(title ?? tipLabel!, style: retro.heading(size: 17, height: 1.25)))
            else
              Expanded(child: Divider(color: retro.border.withValues(alpha: 0.25))),
          ]),
          const SizedBox(height: 12),
          SelectableText(text, style: retro.body(size: 16, color: retro.ink, height: 1.45)),
        ]),
      ),
    );
  }
}

class PlayGuideRail extends StatelessWidget {
  const PlayGuideRail({super.key, required this.titles, required this.selected,
    required this.onSelected});
  final List<String> titles;
  final int selected;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Row(children: List.generate(titles.length, (index) {
      final active = selected == index;
      return Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Semantics(selected: active, button: true,
          label: '${index + 1}. ${titles[index]}',
          child: ExcludeSemantics(child: Material(
            color: active ? retro.accent : retro.surface,
            shape: RoundedRectangleBorder(borderRadius: retro.radius,
              side: BorderSide(color: active ? retro.accentText : retro.border,
                width: retro.borderWidth(active ? 2.5 : 1))),
            child: InkWell(
              key: ValueKey('guide-stage-$index'),
              borderRadius: retro.radius,
              onTap: onSelected == null ? null : () => onSelected!(index),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('${index + 1}', style: retro.heading(size: 17,
                    color: active ? retro.inkOnAccent : retro.ink)),
                )),
              ),
            ),
          )),
        ),
      ));
    }));
  }
}

class _ChapterTrim extends CustomPainter {
  const _ChapterTrim({required this.retro});
  final RetroTheme retro;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final treatment = retro.design.surfaceTreatment;
    final paint = Paint()..color = retro.accent;
    if (treatment == AppSurfaceTreatment.racing) {
      // A finish-line strip rather than stars or generic decorative sparkles.
      final square = size.height / 2;
      for (var x = 0.0; x < size.width; x += square) {
        for (var row = 0; row < 2; row++) {
          paint.color = ((x / square).round() + row).isEven ? retro.ink : retro.surface;
          canvas.drawRect(Rect.fromLTWH(x, row * square, square, square), paint);
        }
      }
    } else if (treatment == AppSurfaceTreatment.folio) {
      paint.color = retro.border;
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2),
        paint..strokeWidth = 2);
      for (final x in [4.0, size.width - 4]) {
        canvas.drawCircle(Offset(x, size.height / 2), 3, paint);
      }
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.7, size.height), paint);
      paint.color = retro.ink;
      for (var x = size.width * 0.74; x < size.width - 8; x += 12) {
        canvas.drawPath(Path()..moveTo(x, size.height)..lineTo(x + 5, 0)
          ..lineTo(x + 9, 0)..lineTo(x + 4, size.height)..close(), paint);
      }
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(_ChapterTrim old) => old.retro != retro;
}
