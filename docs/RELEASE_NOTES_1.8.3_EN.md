<!-- Generated preview from release-manifests/v1.8.3.json; edit that manifest, not this file. -->

## SM64CDPY v1.8.3 — Game mod controls and the Mario 64 interface

Version 1.8.3 brings verified game mod activation to Library, unifies local mod information, and adds the Mario 64 interface alongside Retro Manga with consistent Settings selectors.

### Library and game mod controls

- Game mods is the main Library view. It replaces the separate Detected tab and lists both existing mods and content installed by SM64CDPY when they match the game’s supported structure.
- Activation uses the real folder or Lua filename. Local search, enabled/disabled filters, counters and read-only details include author, category, version labels and descriptions when available.
- Select the game’s user folder once to grant persistent access to sm64config.txt. Close the game before editing: selections apply to its next start, and DynOS/Touch Controls retain their separate configuration.
- Saving checks known local incompatibilities and the game’s size limit, preserves unrelated configuration lines, creates a private backup and verifies the written result. Previous configuration can be restored with confirmation.
- Cards, controls, progress, dialogs and save feedback follow the selected interface theme. The retired discovery view no longer triggers a second automatic scan; installation receipts, update checks and history keep their distinct roles.

### Retro Manga and Mario 64 themes

- Retro Manga remains the default. Mario 64 rebuilds the main interface around original file-select materials, square frames, game skies and HUD accents in light and dark modes.
- Themes are remembered after reopening. Choosing Mario 64 requests the ROM once when its complete local resource set is missing; cancellation preserves the previous theme. Brightness remains independent.
- Mario 64 uses menu, dialog and HUD typography generated privately from the ROM. Colored headings use original glyphs; characters missing from the US ROM retain readable language fallbacks.
- An unmodified US .z64 ROM supplies 151 images and three generated fonts, including menu materials, cursors, icons and Clouds/BBH skies. Resources stay private outside Android backup, and no ROM or extracted artwork is bundled. Older 15-texture imports can be reimported without losing the previous set on cancellation.

### Consistent Settings

- Interface theme, appearance mode and language show the current choice and reveal their options through matching expandable selectors.
- The language selector keeps its arrow and expansion animations and closes after the choice is saved.
- Mario 64 gives Settings themed menu surfaces, beveled frames and consistent selection indicators.

### Appearance recovery and readability

- Appearance changes are confirmed after saving; simultaneous requests are blocked and failed saves preserve the previous selection.
- Older installations retain their appearance mode. Missing or unavailable design IDs fall back to Retro Manga.
- Filled buttons, badges, filters and progress surfaces use the matching foreground contrast role.

### Floating panel and updates

- The floating panel keeps its independent fixed dark design. Theme selection and game mod editing apply to the main app.
- Download and installation behavior is preserved. Version 1.8.3 is an optional update.
