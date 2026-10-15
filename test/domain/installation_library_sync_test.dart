import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/installation_library_sync.dart';

void main() {
  test('old replies cannot replace a newer request within one engine', () {
    final gate = InstallationLibrarySyncGate();
    expect(gate.accept('main-a', 8), isTrue);
    expect(gate.accept('main-a', 7), isFalse);
    expect(gate.accept('main-a', 8), isTrue);
    expect(gate.sessionChanged, isFalse);
  });
  test('a recreated main engine resets ordering and retires the prior session', () {
    final gate = InstallationLibrarySyncGate();
    expect(gate.accept('main-a', 40), isTrue);
    expect(gate.accept('main-b', 1), isTrue);
    expect(gate.sessionChanged, isTrue);
    expect(gate.accept('main-a', 41), isFalse);
    expect(gate.accept('main-b', 1), isTrue);
    expect(gate.sessionChanged, isFalse);
  });
  test('legacy packets work until a session-aware main engine connects', () {
    final gate = InstallationLibrarySyncGate();
    expect(gate.accept(null, 10), isTrue);
    expect(gate.accept('main-new', 1), isTrue);
    expect(gate.accept(null, 11), isFalse);
    expect(gate.accept('main-new', -1), isFalse);
  });
}
