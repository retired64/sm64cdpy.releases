import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/player_profile.dart';
import 'package:sm64cdpy/presentation/providers/player_profile_provider.dart';
import 'package:sm64cdpy/services/player_profile_service.dart';

PlayerProfileSnapshot snapshot(String name, String revision) =>
    PlayerProfileSnapshot(
      status: 'ready',
      revision: revision,
      profile: PlayerProfile(name: name, model: 0, palette: PlayerPalette.mario),
    );

class _Service extends PlayerProfileService {
  PlayerProfileSnapshot cache = snapshot('Cached', 'cached-revision');
  final reading = Completer<PlayerProfileSnapshot>();
  final scanning = Completer<PlayerProfileSnapshot>();
  int reads = 0;
  String? appliedRevision;
  bool cacheFails = false;

  @override
  Future<PlayerProfileSnapshot> cached() async {
    if (cacheFails) throw const FormatException('corrupt');
    return cache;
  }

  @override
  Future<PlayerProfileSnapshot> read() {
    reads++;
    return reading.future;
  }

  @override
  Future<PlayerProfileSnapshot> palettes() => scanning.future;

  @override
  Future<PlayerProfileSnapshot> apply({
    required PlayerProfile profile,
    required String revision,
  }) async {
    appliedRevision = revision;
    throw PlatformException(code: 'conflict');
  }
}

Future<void> tick() => Future<void>.delayed(Duration.zero);

void main() {
  late _Service service;
  late ProviderContainer container;
  setUp(() {
    service = _Service();
    container = ProviderContainer(
      overrides: [playerProfileServiceProvider.overrideWithValue(service)],
    );
  });
  tearDown(() => container.dispose());

  test('shows persistent snapshot before SAF and deduplicates refresh', () async {
    final notifier = container.read(playerProfileProvider.notifier);
    final loading = notifier.load();
    final duplicate = notifier.load(force: true);
    await tick();
    expect(service.reads, 1);
    expect(container.read(playerProfileProvider).draft?.name, 'Cached');
    expect(container.read(playerProfileProvider).refreshing, isTrue);
    expect(await notifier.apply(), isFalse);
    service.reading.complete(snapshot('Live', 'live-revision'));
    await tick();
    expect(container.read(playerProfileProvider).draft?.name, 'Live');
    expect(container.read(playerProfileProvider).refreshing, isFalse);
    expect(container.read(playerProfileProvider).busy, isFalse);
    service.scanning.complete(const PlayerProfileSnapshot(status: 'ready'));
    await Future.wait([loading, duplicate]);
  });

  test('edits during refresh retain original revision for native conflict', () async {
    final notifier = container.read(playerProfileProvider.notifier);
    final loading = notifier.load();
    await tick();
    notifier.setName('My draft');
    service.reading.complete(snapshot('Changed by game', 'new-revision'));
    service.scanning.complete(const PlayerProfileSnapshot(status: 'ready'));
    await loading;
    expect(container.read(playerProfileProvider).draft?.name, 'My draft');
    expect(await notifier.apply(), isFalse);
    expect(service.appliedRevision, 'cached-revision');
    expect(container.read(playerProfileProvider).error, 'conflict');
    expect(container.read(playerProfileProvider).busy, isFalse);
  });

  test('late palette response cannot overwrite a mutation result or error', () async {
    final notifier = container.read(playerProfileProvider.notifier);
    final loading = notifier.load();
    service.reading.complete(snapshot('Live', 'live'));
    await tick();
    notifier.setName('Edit');
    await notifier.apply();
    service.scanning.complete(const PlayerProfileSnapshot(status: 'ready'));
    await loading;
    expect(container.read(playerProfileProvider).error, 'conflict');
    expect(container.read(playerProfileProvider).draft?.name, 'Edit');
  });

  test('unrelated config changes can adopt fresh revision without losing draft', () async {
    final notifier = container.read(playerProfileProvider.notifier);
    final loading = notifier.load();
    await tick();
    notifier.setName('My draft');
    service.reading.complete(snapshot('Cached', 'new-config-revision'));
    service.scanning.complete(const PlayerProfileSnapshot(status: 'ready'));
    await loading;
    expect(container.read(playerProfileProvider).draft?.name, 'My draft');
    await notifier.apply();
    expect(service.appliedRevision, 'new-config-revision');
  });

  test('unavailable folder removes cached profile and write authorization', () async {
    final loading = container.read(playerProfileProvider.notifier).load();
    await tick();
    service.reading.complete(const PlayerProfileSnapshot(status: 'access'));
    await loading;
    expect(container.read(playerProfileProvider).draft, isNull);
    expect(container.read(playerProfileProvider).revision, isNull);
    expect(container.read(playerProfileProvider).refreshing, isFalse);
  });

  test('unexpected read failure releases loading and disables cached writes', () async {
    final notifier = container.read(playerProfileProvider.notifier);
    final loading = notifier.load();
    await tick();
    service.reading.completeError(StateError('provider failed'));
    await loading;
    expect(container.read(playerProfileProvider).draft?.name, 'Cached');
    expect(container.read(playerProfileProvider).revision, isNull);
    expect(container.read(playerProfileProvider).refreshing, isFalse);
    expect(await notifier.apply(), isFalse);
  });

  test('broken cache falls back to real read', () async {
    service.cacheFails = true;
    final loading = container.read(playerProfileProvider.notifier).load();
    service.reading.complete(snapshot('Live', 'live'));
    service.scanning.complete(const PlayerProfileSnapshot(status: 'ready'));
    await loading;
    expect(container.read(playerProfileProvider).draft?.name, 'Live');
    expect(container.read(playerProfileProvider).presets, isEmpty);
  });

  test('an empty verified palette list clears removed cached presets', () async {
    service.cache = PlayerProfileSnapshot(
      status: 'ready',
      profile: service.cache.profile,
      revision: service.cache.revision,
      presets: const [
        PlayerPalettePreset(
          id: 'user:removed',
          name: 'Removed',
          writable: true,
          palette: PlayerPalette.mario,
        ),
      ],
    );
    final loading = container.read(playerProfileProvider.notifier).load();
    await tick();
    expect(container.read(playerProfileProvider).presets, hasLength(1));
    service.reading.complete(snapshot('Live', 'live'));
    service.scanning.complete(const PlayerProfileSnapshot(status: 'ready'));
    await loading;
    expect(container.read(playerProfileProvider).presets, isEmpty);
  });
}
