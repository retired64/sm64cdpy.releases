# Player preview third-party notice

The isolated local WebGL preview uses Three.js revision 186, Copyright
2010-2026 three.js authors, MIT. Full license: [vendor/LICENSE](vendor/LICENSE).
The two vendored Three.js modules come from the local launcher; one indentation
whitespace defect in three.core.js is normalized, without changing behavior.

Articulated GeoLayout extraction, idle animation decoding and playback are
adapted from retired64/launcher-coopdx (`internal/playermodel/{model,clips}.go`
and `internal/server/web/player3d.js`), MIT, Copyright 2026 Retired64.
Source snapshot: `f12b7039eaa9a9fd80d5f92a990761b1013d4e0a`.
Full license: [LAUNCHER-LICENSE](LAUNCHER-LICENSE).

The Android ELF/AArch64 GameParser and static Fast3D reader are recovered from
this application's previous local bundle, now isolated as readable modules.
No remote script or CDN is loaded by the viewer.

No Super Mario 64 model, texture, animation data, ROM, or SM64CoopDX binary is
bundled here. At runtime the preview reads the user's authorized USA ROM and
installed game APK; models and clips are derived locally into disposable caches.
Tests generate synthetic input; optional private-input checks never publish assets.

## SHA-256 of engine sources

- `player3d-index.js`: `38a3e8392ecb1c726a932a81a31a49e0b4dd764bee94d1bcdcd10e605f3d0945`
- `player3d-model.js`: `e5e9e53e2ddf7b9658b9fdb74de320354c77846b4dd3919f101497f4d8e8af6d`
- `player3d-clips.js`: `3fd01e4141ed18f1b09be0fd9b12dbd3ee32d015f9280671b77d52cbb02c269e`
- `player3d-renderer.js`: `5ba38b1e06bfaa98a6e034d7dc89ff654c759614298f08e8deb7357f72ad8556`
- `vendor/three.module.js`: `9052042d676cb0fdc1ddfefe193053f34b7ac0513a616fdac4535d49987812ea`
- `vendor/three.core.js`: `859ed43eacd3cd9295c14a568365911793f5e1647916f735c60720dc8fb9a86f`
