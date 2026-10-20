import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/rom_preparation.dart';
import '../../services/rom_preparation_service.dart';

final romPreparationServiceProvider = Provider(
  (ref) => const RomPreparationService(),
);
final romPreparationProvider =
    NotifierProvider<RomPreparationNotifier, RomPreparationState>(
      RomPreparationNotifier.new,
    );

class RomPreparationNotifier extends Notifier<RomPreparationState> {
  StreamSubscription<RomPreparationState>? _subscription;

  @override
  RomPreparationState build() {
    final service = ref.read(romPreparationServiceProvider);
    _subscription = service.events.listen(_accept, onError: _platformError);
    ref.onDispose(() {
      final subscription = _subscription;
      if (subscription != null) {
        unawaited(subscription.cancel().catchError((_) {}));
      }
    });
    unawaited(_initialize(service));
    return const RomPreparationState();
  }

  Future<void> _initialize(RomPreparationService service) async {
    try {
      _accept(await service.snapshot());
    } catch (error) {
      _platformError(error);
    }
  }

  void _accept(RomPreparationState next) {
    if (!ref.mounted || (state.initialized && next.revision < state.revision)) {
      return;
    }
    state = next;
  }

  void _platformError(Object error) {
    if (!ref.mounted) return;
    state = RomPreparationState(
      phase: RomPreparationPhase.failed,
      operationId: state.operationId,
      revision: state.revision + 1,
      inputName: state.inputName,
      outputName: state.outputName,
      sourceFormat: state.sourceFormat,
      errorCode: error is PlatformException ? error.code : 'unexpected',
      technicalDetail: error is PlatformException
          ? error.message
          : error.runtimeType.toString(),
      canExport: state.canExport,
      initialized: true,
    );
  }

  Future<void> pickAndPrepare() => _run((service) => service.pickAndPrepare());
  Future<void> export() => _run((service) => service.export());
  Future<void> cancel() => _run((service) => service.cancel());
  Future<void> discard() => _run((service) => service.discard());

  Future<void> _run(
    Future<RomPreparationState> Function(RomPreparationService) call,
  ) async {
    try {
      _accept(await call(ref.read(romPreparationServiceProvider)));
    } catch (error) {
      _platformError(error);
    }
  }
}
