import 'package:flutter/services.dart';

import '../domain/entities/rom_preparation.dart';

class RomPreparationService {
  const RomPreparationService();
  static const _methods = MethodChannel('sm64cdpy/rom_preparation');
  static const _events = EventChannel('sm64cdpy/rom_preparation_events');

  Stream<RomPreparationState> get events =>
      _events.receiveBroadcastStream().map(
        (event) => RomPreparationState.fromMap(
          Map<Object?, Object?>.from(event as Map),
        ),
      );

  Future<RomPreparationState> snapshot() => _call('snapshot');
  Future<RomPreparationState> pickAndPrepare() => _call('pickAndPrepare');
  Future<RomPreparationState> export() => _call('export');
  Future<RomPreparationState> cancel() => _call('cancel');
  Future<RomPreparationState> discard() => _call('discard');

  Future<RomPreparationState> _call(String method) async {
    final value = await _methods.invokeMapMethod<Object?, Object?>(method);
    return RomPreparationState.fromMap(value ?? const {});
  }
}
