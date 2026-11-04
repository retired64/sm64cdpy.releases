## SM64CDPY v1.9.2 — More resilient downloads and animated Player previews

Version 1.9.2 integrates the R2 fallback branch into main: optional mirror-first downloads, enriched catalog support, game-aligned Library activation and articulated previews for all five Player characters.

### Downloads and catalog

- A valid Cloudflare R2 mirror can recover an unavailable or invalid original download. The mirror-first setting reverses the order without removing the original fallback.
- Main app, manual downloads and overlay share source resolution; switching source preserves operation identity and the background installation chain.
- Catalog readers retain optional artifact metadata and older catalog compatibility. Selecting a source does not change which artifact is installed.

### Library activation

- Long Lua descriptions follow the game header truncation behavior instead of making an otherwise readable mod invalid.
- Unreadable disabled scripts no longer block unrelated selections; active incompatibilities retain their checks.
- After a confirmed write, sibling switches refresh from the actual selection. Activation still configures the next game launch.

### Animated Player

- The local WebView/Three.js preview reconstructs articulated rigs for all five characters and plays idle clips derived from the user ROM. Optional invalid animation falls back to the reference pose.
- A stable AndroidView surface and uniform scaling prevent repeated buffer resizing during slow vertical scrolling.
- Both build workflows test the local JavaScript engine and verify the actual nested module graph inside each APK before artifact upload. No ROM or extracted character assets are bundled.

### Release preparation

- Candidate version 1.9.2+30 keeps the existing package, signing configuration, Android minimum and ABI-specific APK names. It does not force an update.
- The final merged candidate still needs its own testing build and device checks for downloads, activation, preview gestures and lifecycle. Successful tests on the source branch are not proof of a newly built release APK.
- The manifest timestamp is provisional until publication. Creating this candidate does not publish a tag, GitHub Release, Discord announcement or website update.
