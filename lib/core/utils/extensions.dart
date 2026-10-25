import 'package:intl/intl.dart';

extension IntExt on int {
  String compactFor(String locale) =>
      NumberFormat.compact(locale: locale).format(this);

  /// Formats large numbers: 1200 → "1.2K", 1_500_000 → "1.5M"
  String get compact {
    if (this >= 1_000_000) return '${(this / 1_000_000).toStringAsFixed(1)}M';
    if (this >= 1_000) return '${(this / 1_000).toStringAsFixed(1)}K';
    return toString();
  }
}

extension StringExt on String {
  String truncate(int max) => length <= max ? this : '${substring(0, max)}…';
}

extension DoubleExt on double {
  String starFor(String locale) => NumberFormat('0.0', locale).format(this);

  String get star => toStringAsFixed(1);
}

extension NullableDoubleExt on double? {
  String get star => this == null ? '—' : this!.toStringAsFixed(1);
}

String? formatDate(String? iso, {String? locale}) {
  if (iso == null) return null;
  try {
    final dt = DateTime.parse(iso);
    final fmt = locale != null ? DateFormat.yMMMd(locale) : DateFormat.yMMMd();
    return fmt.format(dt.toLocal());
  } catch (_) {
    return iso;
  }
}

/// Display-only fallback: never changes catalog or installation identity.
String catalogTitle(String title, String fallback) =>
    title.trim().isEmpty || title.trim() == 'N/A' ? fallback : title;
