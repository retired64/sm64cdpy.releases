import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap/android_overlay_entrypoint.dart';
import 'bootstrap/main_app_bootstrap.dart';
import 'l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/retro_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/widgets/background_operation_coordinator.dart';

/// Instala manejo de errores global para el engine actual.
///
/// Por defecto, una excepción de Dart no capturada en un callback async
/// (p.ej. un listener de EventChannel, un Future sin await) no tiene por
/// qué tumbar el proceso nativo — pero sí puede dejar el engine de Flutter
/// en un estado roto/sin repintar, que desde el punto de vista del usuario
/// se ve igual de mal ("la burbuja dejó de responder"). Sin esto, ese tipo
/// de error simplemente desaparece en la consola de debug y no hay forma
/// de diagnosticarlo en producción.
void _installErrorHandling(String engineLabel) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[$engineLabel] FlutterError details:\n$details');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[$engineLabel] Uncaught error: $error\n$stack');
    return true; // manejado: no relanzar
  };
}

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _installErrorHandling('main');
      await bootstrapMainApp();
      runApp(const ProviderScope(child: SM64CoopDXApp()));
    },
    (error, stack) {
      debugPrint('[main] Zone error: $error\n$stack');
    },
  );
}

class SM64CoopDXApp extends ConsumerStatefulWidget {
  const SM64CoopDXApp({super.key});

  @override
  ConsumerState<SM64CoopDXApp> createState() => _SM64CoopDXAppState();
}

class _SM64CoopDXAppState extends ConsumerState<SM64CoopDXApp> {
  @override
  void initState() {
    super.initState();
    _updateSystemUIOverlayStyle();
  }

  void _updateSystemUIOverlayStyle() {
    final isDark = ref.read(isDarkModeProvider);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: RetroTheme(isDark).background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isDarkModeProvider, (previous, next) {
      _updateSystemUIOverlayStyle();
    });

    final themeMode = ref.watch(themeModeProvider);
    final localeTag = ref.watch(localeNotifierProvider);
    final locale = localeTag != null
        ? LocaleNotifier.localeFromTag(localeTag)
        : null;

    return MaterialApp.router(
      title: 'SM64CoopDX Mods',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: RetroTheme.materialTheme(false),
      darkTheme: RetroTheme.materialTheme(true),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) => BackgroundOperationCoordinator(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

@pragma('vm:entry-point')
void overlayMain() {
  runAndroidOverlayApp();
}
