## SM64CDPY v1.8.5 — Build and preview your player

Version 1.8.5 adds a complete Player workspace for customizing your in-game identity and previewing palette changes on an interactive 3D character before applying them.

### A complete Player workspace

- Choose Mario, Luigi, Toad, Waluigi or Wario and edit the player name from one focused screen.
- Customize the cap, hair, skin, gloves, overalls, shirt, shoes and emblem with precise RGB and hexadecimal color controls.
- Reset the draft, load an existing palette or save the current colors as a reusable preset without leaving the editor.

### Interactive 3D preview

- The preview builds the selected character from the locally installed game and the user's connected US ROM; the APK does not include game models, textures or ROM data.
- Character and palette changes update in place, and the model can be rotated to inspect the result from different angles.
- A compact preview remains visible while editing controls farther down the screen, and the renderer is kept alive to avoid repeated loading while scrolling.

### Safe game integration

- The editor keeps changes in a draft until you choose Apply to game; the game uses the saved profile on its next start.
- Applying a profile uses the same ordered configuration lock, private backup and byte verification as Library mod controls.
- Clear setup and recovery states explain when the game folder, game installation or compatible ROM must be connected.
