import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/rom_preparation.dart';
import 'package:sm64cdpy/presentation/providers/rom_preparation_provider.dart';
import 'package:sm64cdpy/services/rom_preparation_service.dart';

class _Service extends RomPreparationService {
  _Service();
  final controller = StreamController<RomPreparationState>.broadcast();
  RomPreparationState current = const RomPreparationState(initialized: true);
  int starts = 0;

  @override
  Stream<RomPreparationState> get events => controller.stream;
  @override
  Future<RomPreparationState> snapshot() async => current;
  @override
  Future<RomPreparationState> pickAndPrepare() async {
    starts++;
    return current = const RomPreparationState(
      phase: RomPreparationPhase.picking,
      operationId: 'one',
      revision: 1,
      initialized: true,
    );
  }

  @override
  Future<RomPreparationState> cancel() async => current;
  @override
  Future<RomPreparationState> discard() async => current;
  @override
  Future<RomPreparationState> export() async => current;
}

class _FailingExportService extends _Service {
  @override
  Future<RomPreparationState> export() =>
      throw PlatformException(code: 'unavailable', message: 'No activity');
}

Future<void> tick() => Future<void>.delayed(Duration.zero);

void main() {
  test('shares one operation and ignores stale native revisions', () async {
    final service = _Service();
    final container = ProviderContainer(
      overrides: [romPreparationServiceProvider.overrideWithValue(service)],
    );
    final subscription = container.listen(
      romPreparationProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(() async {
      subscription.close();
      container.dispose();
      await service.controller.close();
    });
    final notifier = container.read(romPreparationProvider.notifier);
    await tick();
    await notifier.pickAndPrepare();
    expect(service.starts, 1);
    expect(
      container.read(romPreparationProvider).phase,
      RomPreparationPhase.picking,
    );

    service.controller.add(
      const RomPreparationState(
        phase: RomPreparationPhase.converting,
        operationId: 'one',
        revision: 4,
        processedBytes: 4,
        totalBytes: 8,
        initialized: true,
      ),
    );
    await tick();
    expect(container.read(romPreparationProvider).progress, 0.5);

    service.controller.add(
      const RomPreparationState(
        phase: RomPreparationPhase.idle,
        revision: 2,
        initialized: true,
      ),
    );
    await tick();
    expect(
      container.read(romPreparationProvider).phase,
      RomPreparationPhase.converting,
    );
  });

  test('parses bounded progress and unknown phases safely', () {
    final parsed = RomPreparationState.fromMap(const {
      'phase': 'futurePhase',
      'revision': 2,
      'processedBytes': 12,
      'totalBytes': 8,
    });
    expect(parsed.phase, RomPreparationPhase.failed);
    expect(parsed.progress, 1);
  });

  test('keeps a prepared copy retryable after a platform error', () async {
    final service = _FailingExportService()
      ..current = const RomPreparationState(
        phase: RomPreparationPhase.prepared,
        operationId: 'ready',
        revision: 7,
        inputName: 'mario.v64',
        sourceFormat: 'v64',
        canExport: true,
        initialized: true,
      );
    final container = ProviderContainer(
      overrides: [romPreparationServiceProvider.overrideWithValue(service)],
    );
    final subscription = container.listen(
      romPreparationProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(() async {
      subscription.close();
      container.dispose();
      await service.controller.close();
    });

    await tick();
    await container.read(romPreparationProvider.notifier).export();

    final state = container.read(romPreparationProvider);
    expect(state.phase, RomPreparationPhase.failed);
    expect(state.canExport, isTrue);
    expect(state.inputName, 'mario.v64');
    expect(state.errorCode, 'unavailable');
  });
}
