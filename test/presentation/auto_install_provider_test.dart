import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/presentation/providers/auto_install_provider.dart';
import 'package:sm64cdpy/services/auto_install_preference_service.dart';
import 'package:sm64cdpy/services/guided_setup_service.dart';

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

  test(
    'guided setup status is durable but not a permission authority',
    () async {
      await GuidedSetupService.reset();
      expect(GuidedSetupService.needsPrompt, isTrue);

      await GuidedSetupService.dismiss();
      await GuidedSetupService.init();
      expect(GuidedSetupService.status, GuidedSetupStatus.dismissed);

      await GuidedSetupService.complete();
      await GuidedSetupService.init();
      expect(GuidedSetupService.status, GuidedSetupStatus.completed);
    },
  );
}
