import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/installation_library.dart';

import '../helpers/installation_receipt_fixture.dart';

void main() {
  test('parses schema v1 without losing identity or UTC time', () {
    final record = InstallationRecord.fromMap(installationReceiptFixture());

    expect(record.artifactKey, 'v1|mods|content-1|file-1');
    expect(record.installedAt.isUtc, isTrue);
    expect(record.packageShape, InstallationPackageShape.singleRoot);
    expect(record.sentinels.single.relativePath, 'sample/main.lua');
  });

  test('rejects future schemas', () {
    final value = installationReceiptFixture()..['schemaVersion'] = 2;
    expect(
      () => InstallationRecord.fromMap(value),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects empty and oversized sentinel manifests', () {
    final empty = installationReceiptFixture()
      ..['sentinels'] = <Map<String, dynamic>>[];
    final oversized = installationReceiptFixture()
      ..['sentinels'] = List.generate(
        33,
        (index) => {'relativePath': 'root/$index.lua', 'kind': 'file'},
      );

    expect(
      () => InstallationRecord.fromMap(empty),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => InstallationRecord.fromMap(oversized),
      throwsA(isA<FormatException>()),
    );
  });

  test('parses all bounded SAF verification states', () {
    final verifiedAt = DateTime.parse('2026-09-25T13:00:00Z');
    for (final status in InstallationVerificationStatus.values) {
      final verification = InstallationVerification.fromMap({
        'artifactKey': 'v1|mods|content-1|file-1',
        'status': status.name,
        if (status == InstallationVerificationStatus.missing)
          'missingPath': 'sample/main.lua',
      }, verifiedAt);
      expect(verification.status, status);
    }
  });
}
