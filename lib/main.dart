import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';

import 'overlay/overlay_panel.dart';
import 'l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/retro_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'services/background_install_service.dart';
import 'services/update_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  FileDownloader.setLogEnabled(true); // Enable logs for debugging
  FileDownloader.setMaximumParallelDownloads(3); // Limit concurrent downloads

  // Transparent status bar (will be set dynamically based on theme)
  // SystemChrome.setSystemUIOverlayStyle will be configured in SM64CoopDXApp

  // Hive (favourites persistence)
  try {
    await Hive.initFlutter();
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
    // Continue without Hive (favourites won't persist)
  }

  // OTA — Obtiene versión instalada para comparar con GitHub Releases
  await UpdateService.init();

  // Background install service — EventChannel listener
  BackgroundInstallService.instance.init();

  runApp(const ProviderScope(child: SM64CoopDXApp()));
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
  WidgetsFlutterBinding.ensureInitialized();
  FloatyOverlay.setUp();
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _KeyboardSafe(child: OverlayPanel()),
      ),
    ),
  );
}

/// Prevents the system keyboard from pushing overlay content off-screen.
/// In a floating window, viewInsets should not affect layout.
class _KeyboardSafe extends StatelessWidget {
  const _KeyboardSafe({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        viewInsets: EdgeInsets.zero,
      ),
      child: child,
    );
  }
}
