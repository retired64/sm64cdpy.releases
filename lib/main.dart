import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';

import 'overlay/overlay_panel.dart';
import 'overlay/overlay_bridge.dart';
import 'l10n/app_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/retro_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'services/background_install_service.dart';
import 'services/update_service.dart';

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
    debugPrint('[$engineLabel] FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[$engineLabel] Uncaught error: $error\n$stack');
    return true; // manejado: no relanzar
  };
}

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _installErrorHandling('main');
    await _bootstrapMainApp();
    runApp(const ProviderScope(child: SM64CoopDXApp()));
  }, (error, stack) {
    debugPrint('[main] Zone error: $error\n$stack');
  });
}

Future<void> _bootstrapMainApp() async {

  // Lock to portrait + landscape (phone only)
  // Android 16+ (API 36): screenOrientation constraints are ignored
  // on devices with smallestWidth >= 600dp (tablets, foldables).
  // This is documented platform behavior, not a bug.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Configure file downloader
  FileDownloader.setLogEnabled(kDebugMode); // Enable logs for debugging
  FileDownloader.setMaximumParallelDownloads(3); // Limit concurrent downloads

  // Transparent status bar (will be set dynamically based on theme)
  // SystemChrome.setSystemUIOverlayStyle will be configured in SM64CoopDXApp

  // Hive (favourites persistence)
  try {
    await Hive.initFlutter();
    await Hive.openBox<String>(AppConstants.settingsBoxKey);
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
    // Continue without Hive (favourites won't persist)
  }

  // OTA — Obtiene versión instalada para comparar con GitHub Releases
  await UpdateService.init();

  // Background install service — EventChannel listener
  BackgroundInstallService.instance.init();

  // Overlay ↔ app download bridge
  OverlayBridge.init();
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
    final locale =
        localeTag != null ? LocaleNotifier.localeFromTag(localeTag) : null;

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
    );
  }
}

@pragma('vm:entry-point')
void overlayMain() {
  runZonedGuarded(() {
    _installErrorHandling('overlay');
    FloatyOverlayApp.run(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // locale: null → usa el locale del sistema.
          // SharedPreferences NO se lee acá: este engine no tiene
          // acceso seguro a todos los plugins nativos que el engine
          // principal sí tiene inicializados, y llamar a
          // SharedPreferences.getInstance() desde el overlay causaba
          // crash nativo intermitente (el channel del plugin no está
          // del todo listo en el momento en que floaty_chatheads
          // arranca este segundo engine).
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: RetroTheme.materialTheme(true).copyWith(
            scaffoldBackgroundColor: RetroTheme.overlay().background,
            colorScheme: RetroTheme.materialTheme(true).colorScheme.copyWith(
              surface: RetroTheme.overlay().surface,
            ),
          ),
          home: const OverlayPanel(),
        ),
      ),
    );
  }, (error, stack) {
    debugPrint('[overlay] Zone error: $error\n$stack');
  });
}
