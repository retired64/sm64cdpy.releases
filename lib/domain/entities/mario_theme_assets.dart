/// Private, immutable generation produced by Android from a user-selected ROM.
/// No ROM bytes, document URI or game paths cross into presentation.
class MarioThemeAssets {
  const MarioThemeAssets({this.generation, this.files = const {}, this.version = 1});
  final String? generation;
  final int version;
  final Map<String, String> files;
  bool get available => generation != null && files.length >= 15;

  bool get complete => available && version >= 2 &&
      ['panel_light', 'panel_dark', 'sky_day', 'sky_night', 'font_menu', 'font_dialog', 'font_hud', 'menu_file', 'menu_score', 'mario_save', 'mario_new']
          .every(files.containsKey);

  factory MarioThemeAssets.fromMap(Map<Object?, Object?>? data) {
    if (data == null ||
        data['generation'] is! String ||
        data['files'] is! Map) {
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
      version: data['version'] is int ? data['version'] as int : 1,
      files: Map.unmodifiable(files),
    );
  }
}
