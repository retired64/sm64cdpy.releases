import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/retro_theme.dart';
import '../l10n/app_localizations.dart';
import '../overlay/overlay_panel.dart';

/// Android's secondary Flutter engine entrypoint implementation.
///
/// Keeping the plugin and panel imports here prevents the Linux bootstrap from
/// acquiring overlay responsibilities. [overlayMain] remains in the root
/// library because the Android engine resolves that public entrypoint by name.
void runAndroidOverlayApp() {
  runZonedGuarded(
    () {
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('[overlay] FlutterError: ${details.exceptionAsString()}');
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('[overlay] Uncaught error: $error\n$stack');
        return true;
      };
      FloatyOverlayApp.run(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: RetroTheme.materialTheme(true).copyWith(
              scaffoldBackgroundColor: RetroTheme.overlay().background,
              colorScheme: RetroTheme.materialTheme(
                true,
              ).colorScheme.copyWith(surface: RetroTheme.overlay().surface),
            ),
            home: const OverlayPanel(),
          ),
        ),
      );
    },
    (error, stack) {
      debugPrint('[overlay] Zone error: $error\n$stack');
    },
  );
}
