import 'package:flutter/services.dart';

import '../domain/entities/coop_session.dart';

class CoopSessionService {
  const CoopSessionService();

  static const _methods = MethodChannel('sm64cdpy/coop_session');
  static const _events = EventChannel('sm64cdpy/coop_session_events');

  Stream<CoopSessionState> get events => _events.receiveBroadcastStream().map(
    (event) =>
        CoopSessionState.fromMap(Map<Object?, Object?>.from(event as Map)),
  );

  Future<CoopSessionState> snapshot() => _state('snapshot');
  Future<String> generateCode() async =>
      await _methods.invokeMethod<String>('generateCode') ?? '';

  Future<CoopSessionState> start({
    required CoopSessionMode mode,
    required String code,
    bool relayOnly = false,
  }) => _state('start', {
    'mode': mode.name,
    'code': code,
    'relayOnly': relayOnly,
  });

  Future<CoopSessionState> stop() => _state('stop');
  Future<bool> openGame() async =>
      await _methods.invokeMethod<bool>('openGame') ?? false;
  Future<bool> gameInstalled() async =>
      await _methods.invokeMethod<bool>('gameInstalled') ?? false;

  Future<CoopBatteryOptimizationState> batteryOptimizationStatus() =>
      _batteryState('batteryOptimizationStatus');

  Future<CoopBatteryOptimizationState> requestBatteryOptimizationExemption() =>
      _batteryState('requestBatteryOptimizationExemption');

  Future<CoopBatteryOptimizationState> openBatteryOptimizationSettings() =>
      _batteryState('openBatteryOptimizationSettings');

  Future<CoopSessionState> _state(String method, [Object? arguments]) async {
    final result = await _methods.invokeMapMethod<Object?, Object?>(
      method,
      arguments,
    );
    return CoopSessionState.fromMap(result ?? const {});
  }

  Future<CoopBatteryOptimizationState> _batteryState(String method) async {
    final result = await _methods.invokeMapMethod<Object?, Object?>(method);
    return CoopBatteryOptimizationState.fromMap(result ?? const {});
  }
}
