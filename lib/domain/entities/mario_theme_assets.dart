/// Private, immutable generation produced by Android from a user-selected ROM.
/// No ROM bytes, document URI or game paths cross into presentation.
class MarioThemeAssets {
  const MarioThemeAssets({this.generation, this.files = const {}});
  final String? generation;
  final Map<String, String> files;
  bool get available => generation != null && files.length == 15;

  factory MarioThemeAssets.fromMap(Map<Object?, Object?>? data) {
    if (data == null || data['generation'] is! String || data['files'] is! Map) {
      return const MarioThemeAssets();
    }
    final files = <String, String>{};
    for (final entry in (data['files'] as Map).entries) {
      if (entry.key is String && entry.value is String) {
        files[entry.key as String] = entry.value as String;
      }
    }
    const required = ['stone', 'stone_dark', 'hand', 'hand_pressed', 'star'];
    if (!required.every(files.containsKey) ||
        !List.generate(10, (i) => 'digit_$i').every(files.containsKey)) {
      return const MarioThemeAssets();
    }
    return MarioThemeAssets(
      generation: data['generation'] as String,
      files: Map.unmodifiable(files),
    );
  }
}
