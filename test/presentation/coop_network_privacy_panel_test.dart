import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/widgets/coop_network_privacy_panel.dart';

void main() {
  for (final language in ['en', 'es', 'pt']) {
    testWidgets('Disclaimer privacy review is informational: $language', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      // Sin ProviderScope ni servicios: consultar no usa el motor de conexión.
      await tester.pumpWidget(MaterialApp(
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: RetroTheme.materialTheme(true),
        home: const Scaffold(body: SingleChildScrollView(child: CoopNetworkPrivacyPanel())),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('disclaimer-review-network')));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(AlertDialog));
      final l = AppLocalizations.of(context);
      expect(find.text(l.coopConsentEncrypted), findsOneWidget);
      expect(find.text(l.coopConsentIp), findsOneWidget);
      expect(find.text(l.coopConsentThirdParty), findsOneWidget);
      expect(find.text(l.coopConsentAccept), findsNothing);
      await tester.tap(find.text(MaterialLocalizations.of(context).closeButtonLabel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
