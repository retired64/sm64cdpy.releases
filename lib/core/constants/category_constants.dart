import 'package:flutter/material.dart';

class CategoryConstants {
  CategoryConstants._();

  /// Curated categories based on tag analysis
  static const Map<String, List<String>> categoryPatterns = {
    'Characters': [
      'character',
      'char select',
      'custom character',
      'player model',
      'mario',
      'luigi',
      'sonic',
      'wario',
      'waluigi',
      'yoshi',
      'peach',
      'daisy',
      'toad',
      'bowser',
      'rosalina',
      'pikachu',
      'pokemon',
      'kirby',
      'link',
      'zelda',
      'megaman',
      'crash',
      'spyro',
      'spongebob',
      'minecraft',
      'steve',
      'anime',
      'undertale',
      'deltarune',
      'cuphead',
      'sans',
      'papyrus',
      'fnaf',
      'freddy',
      'bendy',
      'shantae',
      'rayman',
      'banjo',
      'conker',
      'earthbound',
      'homestuck',
      'touhou',
      'vtuber',
      'oc',
      'original character',
    ],
    'Game Modes': [
      'gamemode',
      'mariohunt',
      'pvp',
      'hangout',
      'minigame',
      'arena',
      'competitive',
      'coop',
      'ctf',
      'capture the flag',
      'race',
      'speedrun',
      'time attack',
      'hide and seek',
      'prophunt',
      'tag',
      'infection',
      'freeze tag',
      'sandbox',
      'roleplay',
      'challenge',
    ],
    'ROM Hacks & Levels': [
      'romhack',
      'custom level',
      'kaizo',
      'traditional',
      'adventure',
      'platforming',
      'campaign',
      'world',
      'map',
      'maps',
      'level',
      'levels',
      'course',
      'hack',
      'majorhack',
      'minihack',
      'star road',
      'odyssey',
      'galaxy',
      'sunshine',
      'world',
      'zone',
      'secret',
      'maze',
      'obby',
      'platform',
    ],
    'Gameplay & Mechanics': [
      'moveset',
      'custom moveset',
      'difficulty',
      'easy',
      'hard',
      'kaizo',
      'mechanics',
      'movement',
      'jump',
      'fly',
      'longjump',
      'blj',
      'cannon',
      'cap',
      'coins',
      'star',
      'stars',
      'power',
      'ability',
      'weapon',
      'gun',
      'tool',
      'utility',
      'qol',
      'quality of life',
      'cheat',
      'debug',
      'noclip',
      'save',
      'savestate',
      'randomizer',
      'permadeath',
      'one life',
      'yolo',
    ],
    'Visual & Models': [
      'model',
      'custom model',
      'hud',
      'texture',
      'textures',
      'animation',
      'animations',
      'custom animation',
      'custom hud',
      'custom icon',
      'custom cap',
      'custom caps',
      'custom coloring',
      'custom palette',
      'palette preset',
      'recolor',
      'skin',
      'skinpack',
      'costume',
      'visual',
      'graphics',
      'render',
      'lowpoly',
      'retro',
      'hd',
      'remastered',
      'remake',
      'port',
      'render96',
      'n64',
      'snes',
      'ps1',
      'gamecube',
      'wii',
    ],
    'Audio & Voice': [
      'music',
      'custom music',
      'sound',
      'custom sound',
      'custom voice',
      'voice',
      'voice acted',
      'audio',
      'ost',
      'soundtrack',
      'bgm',
      'announcer',
      'taunts',
      'voice lines',
      'voicelines',
      'vocaloid',
      'hatsune miku',
      'dub',
      'dubbing',
    ],
    'Utilities & Tools': [
      'utility',
      'tool',
      'tools',
      'qol',
      'debug',
      'cheat',
      'cheats',
      'moderation',
      'admin',
      'commands',
      'command',
      'api',
      'lua',
      'script',
      'recording',
      'spectate',
      'camera',
      'first person',
      'third person',
      'hud',
      'gui',
      'menu',
      'ui',
      'interface',
      'notification',
      'message',
      'chat',
      'bubble chat',
      'prox chat',
      'translator',
      'translate',
    ],
    'Misc & Fun': [
      'fun',
      'funny',
      'joke',
      'meme',
      'shitpost',
      'random',
      'silly',
      'cool',
      'awesome',
      'epic',
      'cute',
      'spooky',
      'horror',
      'scary',
      'gore',
      'halloween',
      'christmas',
      'easter',
      'holiday',
      'seasonal',
      'event',
      'crossover',
      'cameo',
      'reference',
      'parody',
      'satire',
      'troll',
      'april fools',
      'garbage',
      'trash',
      'bad',
      'worst',
      'best',
      'awesome',
      'classic',
      'old',
      'legacy',
      'beta',
      'demo',
      'prototype',
      'concept',
      'art',
      'painting',
      'graffiti',
      'fanart',
      'commission',
    ],
  };

  /// Normalize tag for matching: lowercase, remove #, replace - with space, trim
  static String normalizeTag(String tag) {
    return tag
        .toLowerCase()
        .replaceAll('#', '')
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .trim();
  }

  /// Get category for a given tag
  static String? getCategoryForTag(String tag) {
    final normalized = normalizeTag(tag);

    // Special cases first
    if (normalized == 'sm64coopdx' ||
        normalized == 'sm64ex-coop' ||
        normalized == 'sm64ex') {
      return null; // Platform tags, not a category
    }

    // Check each category's patterns
    for (final entry in categoryPatterns.entries) {
      for (final pattern in entry.value) {
        if (normalized.contains(pattern) || pattern.contains(normalized)) {
          return entry.key;
        }
      }
    }

    return null; // No category found
  }

  /// Get all available categories
  static List<String> get allCategories => categoryPatterns.keys.toList();

  /// Get icon for each category
  static IconData getIconForCategory(String category) {
    switch (category) {
      case 'Characters':
        return Icons.people_rounded;
      case 'Game Modes':
        return Icons.sports_esports_rounded;
      case 'ROM Hacks & Levels':
        return Icons.map_rounded;
      case 'Gameplay & Mechanics':
        return Icons.gamepad_rounded;
      case 'Visual & Models':
        return Icons.palette_rounded;
      case 'Audio & Voice':
        return Icons.music_note_rounded;
      case 'Utilities & Tools':
        return Icons.build_rounded;
      case 'Misc & Fun':
        return Icons.emoji_emotions_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Get color for each category
  static Color getColorForCategory(String category) {
    switch (category) {
      case 'Characters':
        return Colors.blue;
      case 'Game Modes':
        return Colors.green;
      case 'ROM Hacks & Levels':
        return Colors.orange;
      case 'Gameplay & Mechanics':
        return Colors.purple;
      case 'Visual & Models':
        return Colors.pink;
      case 'Audio & Voice':
        return Colors.teal;
      case 'Utilities & Tools':
        return Colors.brown;
      case 'Misc & Fun':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
