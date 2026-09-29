import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/data/repositories/read_only_installation_library_repository.dart';

void main() {
  group('ReadOnlyInstallationLibraryRepository', () {
    final repository = ReadOnlyInstallationLibraryRepository();

    test('never exposes Android receipts as Linux evidence', () async {
      final snapshot = await repository.verifyAll();

      expect(snapshot.receipts, isEmpty);
      expect(snapshot.history, isEmpty);
      expect(snapshot.discoveries, isEmpty);
      expect(snapshot.issues, isEmpty);
    });

    test('all phase-one mutations remain safe no-ops', () async {
      final results = await Future.wait([
        repository.synchronize(),
        repository.discover(force: true),
        repository.verifyArtifact('mods:test:file'),
        repository.clearHistory(),
        repository.forgetContent('mods:test'),
        repository.removeHistoryEvent('worker'),
      ]);

      for (final snapshot in results) {
        expect(snapshot.receipts, isEmpty);
        expect(snapshot.history, isEmpty);
      }
    });
  });
}
