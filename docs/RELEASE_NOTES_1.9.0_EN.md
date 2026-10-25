## SM64CDPY v1.9.0 — Play together, prepare your ROM and explore in five languages

Version 1.9.0 adds the Play multiplayer flow, local ROM preparation, a complete How to Play guide, French and Italian, richer mod media and a polished Manga interface with faster cached Library and Save Files entry.

### Play with friends

- Play is a top-level destination. Create a room or enter an eight-character code, copy or share the invitation as plain text, then open SM64CoopDX from the same flow.
- The Android bridge uses a foreground service only for an active session, releases network and CPU locks when stopped, and reports connection, game traffic and recovery diagnostics without exposing IP addresses.
- Network consent is explicit and versioned. Battery-optimization exemption is optional, user initiated and rechecked when returning from Android settings.
- Recent join codes are stored locally with a small limit. Terminal failures cleanly stop signaling, WebRTC, UDP and service resources before retry.

### Setup and ROM tools

- The new How to Play guide uses themed cards, chapter navigation and contextual actions for installing the Android game, preparing a ROM, selecting the game folder and installing a first mod.
- Prepare ROM detects z64, v64 and n64 by header, validates the expected USA dump, converts natively in bounded blocks and verifies the exported copy without modifying the source file.
- Progress, cancellation, retry and actionable errors stay responsive on low-memory devices; prepared and externally saved copies are shown as distinct states.

### Interface, media and performance

- Retro Manga receives compact slide navigation, consistent paper-and-ink controls and expanded styling across Home, Catalog, Popular, Favorites, Library, mod details, Player, Save Files, Prepare ROM and Play.
- Manga Deluxe adds its own typography, optimized artwork, optional moving backdrop, compact welcome, themed navigation and dedicated visuals for ROM, saves and multiplayer.
- Ambient music, menu sounds and Home card sounds have separate persisted enable and volume controls, with conservative defaults.
- Library and Save Files show a persisted snapshot immediately and validate it in the background. Player profile state is also restored without unnecessary visible rebuilding.
- Mod details support normalized description images, video thumbnails and external YouTube playback while keeping loading and error states bounded.

### Languages and catalog data

- French and Italian join English, Spanish and Brazilian Portuguese across the main Flutter interface, shared diagnostics and native Android notifications.
- The chosen language persists across launches. Dates, numbers, pagination, course labels and Render96 categories use localized presentation.
- Touch Controls now display creator attribution in listings, details and favorites, with Release Soon when the source has no author.

### Before publishing

- This candidate does not force an update. The release timestamp remains provisional until publication.
- Physical validation is still required for multiplayer continuity, battery settings, ROM providers, low storage, rotation, five-language layouts, media previews and all three ABI APKs.
- The floating overlay language and the planned safe-uninstall workflow are not part of version 1.9.0.
