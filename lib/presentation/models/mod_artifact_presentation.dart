import '../../domain/entities/mod_entity.dart';

enum ModArtifactRole { primary, lite, api, textures, voices, optional }

class ModArtifactPresentation {
  const ModArtifactPresentation({
    required this.role,
    required this.isRecommended,
    this.displayName = '',
    this.requiresPrimary = false,
  });

  final ModArtifactRole role;
  final bool isRecommended;
  final String displayName;
  final bool requiresPrimary;
}

/// Adds conservative presentation hints without changing catalogue identity.
///
/// The filename and stable IDs remain authoritative. These hints only help the
/// user distinguish a main package from optional companion downloads until the
/// catalogue publishes explicit `role` and `recommended` metadata.
List<ModArtifactPresentation> describeModArtifacts({
  required String modTitle,
  required List<ModFileEntity> files,
}) {
  if (files.isEmpty) return const [];

  var primaryIndex = 0;
  var primaryScore = -100000;
  for (var index = 0; index < files.length; index++) {
    final score = _primaryScore(modTitle, files[index].filename);
    if (score > primaryScore) {
      primaryIndex = index;
      primaryScore = score;
    }
  }

  return [
    for (var index = 0; index < files.length; index++)
      _presentationFor(
        files[index],
        inferredPrimary: index == primaryIndex,
        hasAlternatives: files.length > 1,
      ),
  ];
}

ModArtifactPresentation _presentationFor(
  ModFileEntity file, {
  required bool inferredPrimary,
  required bool hasAlternatives,
}) {
  final explicitRole = _parseRole(file.role);
  return ModArtifactPresentation(
    role: explicitRole ?? _roleFor(file.filename, inferredPrimary),
    isRecommended: hasAlternatives && (file.recommended ?? inferredPrimary),
    displayName: file.displayName.trim(),
    requiresPrimary: file.requiresPrimary ?? !inferredPrimary,
  );
}

ModArtifactRole? _parseRole(String value) =>
    switch (value.trim().toLowerCase()) {
      'primary' => ModArtifactRole.primary,
      'lite' => ModArtifactRole.lite,
      'api' => ModArtifactRole.api,
      'textures' => ModArtifactRole.textures,
      'voices' => ModArtifactRole.voices,
      'optional' => ModArtifactRole.optional,
      _ => null,
    };

ModArtifactRole _roleFor(String filename, bool isPrimary) {
  final value = filename.toLowerCase();
  if (_containsToken(value, 'lite')) return ModArtifactRole.lite;
  if (_containsToken(value, 'api')) return ModArtifactRole.api;
  if (value.contains('texture')) return ModArtifactRole.textures;
  if (value.contains('voice')) return ModArtifactRole.voices;
  return isPrimary ? ModArtifactRole.primary : ModArtifactRole.optional;
}

int _primaryScore(String modTitle, String filename) {
  final lower = filename.toLowerCase();
  var score = 0;
  if (_roleFor(filename, false) != ModArtifactRole.optional) {
    score -= 1000;
  }

  final title = _identityText(modTitle);
  final stem = _identityText(filename.replaceFirst(RegExp(r'\.[^.]+$'), ''));
  if (title.isNotEmpty && (stem == title || stem.startsWith(title))) {
    score += 100;
  }
  if (lower.endsWith('.zip')) {
    score += 5;
  }
  score -= stem.length;
  return score;
}

bool _containsToken(String value, String token) => RegExp(
  '(^|[^a-z0-9])${RegExp.escape(token)}([^a-z0-9]|\$)',
).hasMatch(value);

String _identityText(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'v?\d+(?:[._-]\d+)+'), '')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '');
