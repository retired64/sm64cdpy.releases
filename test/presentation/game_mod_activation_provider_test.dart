import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/services/game_mod_activation.dart';
import 'package:sm64cdpy/presentation/providers/game_mod_activation_provider.dart';

class FakeGateway extends GameModActivation {
  GameModSnapshot current = const GameModSnapshot(status: 'ready');
  Completer<GameModSnapshot?>? pending;
  bool fail = false;
  int writes = 0;
  @override
  Future<GameModSnapshot> read() async => current;
  @override
  Future<GameModSnapshot?> call(String method, [Map<String, Object>? arguments]) async {
    writes++;
    if (fail) throw PlatformException(code: 'write');
    return pending == null ? current : await pending!.future;
  }
}

void main() {
  late FakeGateway gateway;
  late ProviderContainer container;
  setUp(() {
    gateway = FakeGateway();
    container = ProviderContainer(overrides: [gameModGatewayProvider.overrideWithValue(gateway)]);
  });
  tearDown(() => container.dispose());

  test('selection changes only after native confirmation and blocks parallel mutations', () async {
    await container.read(gameModActivationProvider.future);
    gateway.pending = Completer<GameModSnapshot?>();
    final notifier = container.read(gameModActivationProvider.notifier);
    final first = notifier.perform('setGameModActivation', {'name': 'mod', 'enabled': true});
    await Future<void>.delayed(Duration.zero);
    await expectLater(notifier.perform('setGameModActivation'), throwsStateError);
    expect(container.read(gameModActivationProvider).asData!.value.mods, isEmpty);
    gateway.pending!.complete(const GameModSnapshot(status: 'ready', mods: [GameModEntry(name: 'mod', title: 'Mod', enabled: true, selectable: true)]));
    await first;
    expect(gateway.writes, 1);
    expect(container.read(gameModActivationProvider).asData!.value.mods.single.enabled, isTrue);
  });
  test('write failure preserves confirmed state and releases lock for retry', () async {
    await container.read(gameModActivationProvider.future);
    final notifier = container.read(gameModActivationProvider.notifier);
    gateway.fail = true;
    await expectLater(notifier.perform('setGameModActivation'), throwsA(isA<PlatformException>()));
    expect(container.read(gameModActivationProvider).asData!.value.status, 'ready');
    gateway.fail = false;
    await notifier.perform('setGameModActivation');
    expect(gateway.writes, 2);
  });
  test('cancelled picker preserves selection and refresh observes external edits', () async {
    await container.read(gameModActivationProvider.future);
    final notifier = container.read(gameModActivationProvider.notifier);
    gateway.pending = Completer<GameModSnapshot?>()..complete(null);
    await notifier.perform('selectGameUserFolder');
    expect(container.read(gameModActivationProvider).asData!.value.status, 'ready');
    gateway.current = const GameModSnapshot(status: 'access');
    await notifier.refresh();
    expect(container.read(gameModActivationProvider).asData!.value.status, 'access');
  });
}
