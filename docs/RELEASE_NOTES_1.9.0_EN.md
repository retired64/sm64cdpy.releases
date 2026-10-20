## SM64CDPY v1.9.0 — Prepare your ROM and a more consistent Retro Manga

Version 1.9.0 adds a local ROM preparation tool for the Android game and completes Retro Manga's paper-and-ink visual system across cards, dialogs, fields, menus and secondary controls, while keeping the other themes isolated.

### Local ROM preparation

- Open ROM preparation from How to Play chapter 2 or from GameTool. Both entries share the same service, provider and operation state.
- Choose your own .z64, .v64 or .n64 file. The tool detects the format from its header, normalizes it if needed and validates the expected 8 MiB USA dump and MD5.
- Conversion runs natively in bounded blocks with an isolated staging file. The original remains read-only and no ROM byte is sent to Flutter.
- Export uses Android's document picker, then reopens the new copy to verify its size and hash before reporting success. A broad all-files permission is not required.
- Real phase progress, cancellation, retry and actionable errors are available. A prepared private copy and a verified exported copy are reported as different states.

### Retro Manga consistency

- Neutral cards and panels complete their ink border and hard shadow automatically, including ROM preparation, Save Files, settings groups and active drawer rows.
- Dialogs, text fields, menus, chips, standard buttons, switches, checkboxes, sliders, progress bars, tabs, ExpansionTile and tooltips now share the same rectangular paper-and-ink geometry.
- Save Files, How to Play, mod detail, Player and post-install dialogs no longer override the shared theme with local borders or rounded controls.
- Section headers keep their slanted manga identity, apply the theme's uppercase labels and truncate long titles only when space is limited.
- Minimal, Minish Cap, Mario Kart 64, Mario 64 and SM64 Intro keep their own treatments. The floating overlay is also unchanged.

### Smaller optimizations

- A single shared decoration policy replaces repeated per-screen conditions and avoids redundant local style overrides.
- No new blur, shaders, animations or raster assets are introduced. The halftone backdrop remains isolated in its RepaintBoundary.
- Theme transitions keep compatible text styles, and narrow-screen tests cover 320/360 px layouts with enlarged Spanish text.

### Known limits

- The preparer accepts the original USA Super Mario 64 dump for the Android game. It does not change regions, apply patches, repair dumps or read ZIP/7z archives.
- This release exports a verified copy; it does not replace the ROM already used by the game. Close the game before moving the copy manually.
- Physical validation with local, remote and slow SAF providers, rotation, low storage, cancellation and a real cartridge dump is still pending.

### Getting started

- The localized How to Play guide explains the Android game, your own ROM, game folders and the first mod. Launching without the game offers the guide.
- Use GameTool to reopen ROM preparation at any time without walking through the whole guide again.
