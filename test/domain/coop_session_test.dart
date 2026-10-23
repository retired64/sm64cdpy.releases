import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/coop_session.dart';

void main() {
  group('CoopSessionState', () {
    test(
      'projects a native connected snapshot without losing peer metadata',
      () {
        final state = CoopSessionState.fromMap({
          'phase': 'connected',
          'mode': 'host',
          'sessionId': 'session-1',
          'code': 'ABCD-1234',
          'port': 7777,
          'trackers': 1,
          'friends': [
            {
              'id': 'peer-1',
              'route': 'direct',
              'reconnecting': false,
              'game': true,
            },
          ],
          'gameIn': true,
          'gameHosting': true,
          'gameInstalled': true,
          'revision': 7,
          'initialized': true,
          'toGame': 18,
          'toPage': 21,
          'upDelaySamples': 9,
          'upDelayAverageMs': 4,
          'upDelayMaxMs': 12,
        });

        expect(state.phase, CoopSessionPhase.connected);
        expect(state.mode, CoopSessionMode.host);
        expect(state.phase.active, isTrue);
        expect(state.canStart, isFalse);
        expect(state.peers, hasLength(1));
        expect(state.peers.single.route, 'direct');
        expect(state.peers.single.game, isTrue);
        expect(state.revision, 7);
        expect(state.diagnostics.toGame, 18);
        expect(state.diagnostics.toPage, 21);
        expect(state.diagnostics.upDelayAverageMs, 4);
        expect(state.diagnostics.upDelayMaxMs, 12);
      },
    );

    test('uses safe fallbacks for malformed native enum values', () {
      final state = CoopSessionState.fromMap({
        'phase': 'future-phase',
        'mode': 'future-mode',
        'initialized': true,
      });

      expect(state.phase, CoopSessionPhase.failed);
      expect(state.mode, CoopSessionMode.join);
      expect(state.canStart, isTrue);
    });

    test('preserves the previously detected game installation state', () {
      final state = CoopSessionState.fromMap({
        'phase': 'waiting',
        'initialized': true,
        'gameInstalled': true,
      });

      expect(state.copyWith().gameInstalled, isTrue);
      expect(state.copyWith(gameInstalled: false).gameInstalled, isFalse);
    });

    test('normalizes ambiguous Crockford characters before validation', () {
      expect(normalizeCoopCode('ouil-12ab'), '0V11-12AB');
      expect(isValidCoopCode(normalizeCoopCode('ouil-12ab')), isTrue);
      expect(isValidCoopCode(normalizeCoopCode('short')), isFalse);
    });

    test('projects Android battery optimization capability', () {
      final state = CoopBatteryOptimizationState.fromMap({
        'supported': true,
        'ignored': true,
        'settingsOpened': true,
      });

      expect(state.supported, isTrue);
      expect(state.ignored, isTrue);
      expect(state.settingsOpened, isTrue);
    });
  });
}
