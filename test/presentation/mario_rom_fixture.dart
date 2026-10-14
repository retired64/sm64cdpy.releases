import 'package:sm64cdpy/domain/entities/mario_theme_assets.dart';
import 'package:sm64cdpy/services/mario_theme_assets_service.dart';

MarioThemeAssets completeMarioFixture() => MarioThemeAssets(generation: 'synthetic', version: 2,
  files: {for (final id in ['stone', 'stone_dark', 'hand', 'hand_pressed', 'star',
    ...List.generate(10, (i) => 'digit_$i'), 'panel_light', 'panel_dark', 'sky_day', 'sky_night',
    'font_menu', 'font_dialog', 'font_hud', 'menu_file', 'menu_score', 'mario_save', 'mario_new']) id: '/synthetic/$id'});

class ReadyMarioRomService extends MarioThemeAssetsService {
  @override
  Future<MarioThemeAssets?> call(String method) async => completeMarioFixture();
}
