import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/auto_install_provider.dart';
import 'package:sm64cdpy/presentation/providers/game_folder_provider.dart';
import 'package:sm64cdpy/presentation/widgets/app_shell.dart';
import 'package:sm64cdpy/presentation/widgets/game_setup_widgets.dart';
import 'package:sm64cdpy/services/auto_install_preference_service.dart';
import 'package:sm64cdpy/services/game_folder_service.dart';

class _OnboardingFolderService extends GameFolderService {
  bool dismissed = false;

  @override
  Future<GameFolderConnection?> call(String method) async {
    if (method == 'dismissGameFolderGuide') dismissed = true;
    return GameFolderConnection(dismissed: dismissed);
  }
}

// The widget test controls persistence completion explicitly. Real Hive and
// SharedPreferences persistence are covered by the provider tests below.
class _OnboardingAutoInstallNotifier extends AutoInstallNotifier {
  final saved = Completer<void>();
  bool? selected;

  @override
  AutoInstallSettings build() => const AutoInstallSettings(
    decision: AutoInstallDecision.undecided,
  );

  @override
  Future<bool> setEnabled(bool enabled) async {
    selected = enabled;
    state = AutoInstallSettings(decision: state.decision, isSaving: true);
    await saved.future;
    if (!ref.mounted) return false;
    state = AutoInstallSettings(
      decision: enabled
          ? AutoInstallDecision.enabled
          : AutoInstallDecision.disabled,
    );
    return true;
  }
}

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('auto-install-test-');
    Hive.init(directory.path);
    await Hive.openBox<String>(AppConstants.settingsBoxKey);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('a fresh install remains undecided until the user chooses', () async {
    await AutoInstallPreferenceService.init();

    expect(
      AutoInstallPreferenceService.decision,
      AutoInstallDecision.undecided,
    );
    expect(
      Hive.box<String>(
        AppConstants.settingsBoxKey,
      ).get(AutoInstallPreferenceService.hiveKey),
      isNull,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(AppConstants.autoInstallModsKey), isFalse);
  });

  test(
    'an explicit legacy boolean migrates to Hive without prompting',
    () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.autoInstallModsKey: true,
      });

      await AutoInstallPreferenceService.init();

      expect(
        AutoInstallPreferenceService.decision,
        AutoInstallDecision.enabled,
      );
      expect(
        Hive.box<String>(
          AppConstants.settingsBoxKey,
        ).get(AutoInstallPreferenceService.hiveKey),
        'enabled',
      );
    },
  );

  test('the Hive decision repairs a stale interoperability mirror', () async {
    await Hive.box<String>(
      AppConstants.settingsBoxKey,
    ).put(AutoInstallPreferenceService.hiveKey, 'disabled');
    SharedPreferences.setMockInitialValues({
      AppConstants.autoInstallModsKey: true,
    });

    await AutoInstallPreferenceService.init();

    expect(AutoInstallPreferenceService.decision, AutoInstallDecision.disabled);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AppConstants.autoInstallModsKey), isFalse);
  });

  test(
    'one provider writer persists and publishes the accepted choice',
    () async {
      await AutoInstallPreferenceService.init();
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(autoInstallProvider).needsDecision, isTrue);
      expect(
        await container.read(autoInstallProvider.notifier).setEnabled(true),
        isTrue,
      );
      expect(container.read(autoInstallProvider).isEnabled, isTrue);
      expect(container.read(autoInstallProvider).isSaving, isFalse);
      expect(
        Hive.box<String>(
          AppConstants.settingsBoxKey,
        ).get(AutoInstallPreferenceService.hiveKey),
        'enabled',
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppConstants.autoInstallModsKey), isTrue);
    },
  );

  test('download-only is an explicit durable decision', () async {
    await AutoInstallPreferenceService.init();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      await container.read(autoInstallProvider.notifier).setEnabled(false),
      isTrue,
    );
    expect(
      container.read(autoInstallProvider).decision,
      AutoInstallDecision.disabled,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(AppConstants.autoInstallModsKey), isFalse);
    expect(
      Hive.box<String>(
        AppConstants.settingsBoxKey,
      ).get(AutoInstallPreferenceService.hiveKey),
      'disabled',
    );
  });

  testWidgets('first-run decisions appear as two sequential dialogs', (
    tester,
  ) async {
    final preference = _OnboardingAutoInstallNotifier();
    final folderService = _OnboardingFolderService();
    final container = ProviderContainer(
      overrides: [
        autoInstallProvider.overrideWith(() => preference),
        gameFolderServiceProvider.overrideWithValue(folderService),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppShell(currentRoute: '/', child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(MaterialBanner), findsNothing);
    expect(find.text('Install mods after downloading?'), findsOneWidget);
    expect(find.byType(GameSetupAction), findsNWidgets(2));

    await tester.tap(find.byType(GameSetupAction).first);
    await tester.pumpAndSettle();

    expect(preference.selected, isTrue);
    expect(container.read(autoInstallProvider).isSaving, isTrue);
    expect(find.text('Connect SM64CoopDX'), findsNothing);

    // Only the persistence acknowledgement allows the folder dialog to open.
    preference.saved.complete();
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Connect SM64CoopDX'), findsOneWidget);
    expect(find.text('Install mods after downloading?'), findsNothing);

    final notNow = find.byType(GameSetupAction).last;
    await tester.ensureVisible(notNow);
    await tester.tap(notNow);
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(folderService.dismissed, isTrue);
    expect(container.read(autoInstallProvider).isEnabled, isTrue);
    expect(tester.takeException(), isNull);

    // Dispose routes/providers before the shared tearDown closes Hive.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }, timeout: const Timeout(Duration(seconds: 30)));
}
