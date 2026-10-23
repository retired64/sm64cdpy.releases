import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';

/// Consulta informativa: no acepta términos ni inicia/conecta una sesión.
/// El consentimiento obligatorio permanece en el coordinador de Play.
class CoopNetworkPrivacyPanel extends StatelessWidget {
  const CoopNetworkPrivacyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    return Container(
      key: const ValueKey('disclaimer-network-privacy'),
      padding: const EdgeInsets.all(16),
      decoration: retro.surfaceDecoration(shadowDx: 2, shadowDy: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(Icons.shield_outlined, color: retro.accentText),
            const SizedBox(width: 12),
            Expanded(child: Text(l.coopConsentTitle, style: retro.heading(size: 16))),
          ]),
          const SizedBox(height: 12),
          Text(l.coopPrivacy, style: retro.body(size: 14, height: 1.45)),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const ValueKey('disclaimer-review-network'),
              icon: const Icon(Icons.privacy_tip_outlined),
              label: Text(l.coopConsentReview),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l.coopConsentTitle),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.coopConsentIntro),
                        for (final text in [
                          l.coopConsentEncrypted,
                          l.coopConsentIp,
                          l.coopConsentThirdParty,
                        ]) ...[
                          const SizedBox(height: 16),
                          Text(text),
                        ],
                      ],
                    ),
                  ),
                  actions: [TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                  )],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
