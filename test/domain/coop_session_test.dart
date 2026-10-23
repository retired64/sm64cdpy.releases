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
        });

        expect(state.phase, CoopSessionPhase.connected);
        expect(state.mode, CoopSessionMode.host);
        expect(state.phase.active, isTrue);
        expect(state.canStart, isFalse);
        expect(state.peers, hasLength(1));
        expect(state.peers.single.route, 'direct');
        expect(state.peers.single.game, isTrue);
        expect(state.revision, 7);
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
  });
}
