import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_snackbar.dart';

/// Localized recovery guidance; the original diagnostic is available to copy.
class CatalogErrorDetails extends StatelessWidget {
  const CatalogErrorDetails({
    super.key,
    required this.details,
    this.style,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
  });

  final String details;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.catalogLoadFailed,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ),
        TextButton.icon(
          onPressed: () async {
            await AppSnackbar.copyDetails(context, details);
          },
          icon: const Icon(Icons.copy_rounded, size: 16),
          label: Text(l10n.sharedCopyDetails),
        ),
      ],
    );
  }
}
