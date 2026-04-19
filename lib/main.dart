import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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

    // Listen to theme changes and update system UI
    ref.listen<bool>(isDarkModeProvider, (previous, next) {
      _updateSystemUIOverlayStyle();
    });
  }

  void _updateSystemUIOverlayStyle() {
    final isDark = ref.read(isDarkModeProvider);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: AppTheme.backgroundColor(isDark),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SM64CoopDX Mods',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
