import 'package:intl/intl.dart';

extension IntExt on int {
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
  String get star => toStringAsFixed(1);
}

extension NullableDoubleExt on double? {
  String get star => this == null ? '—' : this!.toStringAsFixed(1);
}

String? formatDate(String? iso) {
  if (iso == null) return null;
  try {
    final dt = DateTime.parse(iso);
    return DateFormat('MMM d, yyyy').format(dt.toLocal());
  } catch (_) {
    return iso;
  }
}
