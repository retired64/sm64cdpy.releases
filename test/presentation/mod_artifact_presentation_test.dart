import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/mod_entity.dart';
import 'package:sm64cdpy/presentation/models/mod_artifact_presentation.dart';

ModFileEntity file(String name) => ModFileEntity(
  id: name,
  filename: name,
  downloadUrl: 'https://example.com/$name',
);

void main() {
  test('explicit catalogue metadata wins over filename inference', () {
    final result = describeModArtifacts(
      modTitle: 'Ambiguous Mod',
      files: [
        ModFileEntity(
          id: 'addon',
          filename: 'looks-like-main.zip',
          downloadUrl: 'https://example.com/addon.zip',
          displayName: 'Online extras',
          role: 'optional',
          recommended: false,
          requiresPrimary: true,
        ),
        ModFileEntity(
          id: 'main',
          filename: 'unknown.bin',
          downloadUrl: 'https://example.com/main.zip',
          displayName: 'Complete package',
          role: 'primary',
          recommended: true,
          requiresPrimary: false,
        ),
      ],
    );

    expect(result.first.role, ModArtifactRole.optional);
    expect(result.first.displayName, 'Online extras');
    expect(result.first.requiresPrimary, isTrue);
    expect(result.last.role, ModArtifactRole.primary);
    expect(result.last.isRecommended, isTrue);
    expect(result.last.displayName, 'Complete package');
  });

  test('MarioHunt marks the full package as recommended', () {
    final result = describeModArtifacts(
      modTitle: 'MarioHunt',
      files: [
        file('api_stuff.zip'),
        file('MarioHunt.zip'),
        file('MarioHunt_Lite.zip'),
        file('mh-textures.zip'),
      ],
    );

    expect(result.map((item) => item.role), [
      ModArtifactRole.api,
      ModArtifactRole.primary,
      ModArtifactRole.lite,
      ModArtifactRole.textures,
    ]);
    expect(result.map((item) => item.isRecommended), [
      false,
      true,
      false,
      false,
    ]);
  });

  test('Mega Man X distinguishes its optional voices package', () {
    final result = describeModArtifacts(
      modTitle: 'Mega Man X',
      files: [file('mmx_v1.2.14.zip'), file('mmx_v1.2.14_extra_voices.zip')],
    );

    expect(result.first.role, ModArtifactRole.primary);
    expect(result.first.isRecommended, isTrue);
    expect(result.last.role, ModArtifactRole.voices);
    expect(result.last.isRecommended, isFalse);
  });
}
