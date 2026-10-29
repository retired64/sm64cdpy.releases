# Changelog

## Unreleased — Game mod activation

- Match CoopDX header truncation instead of rejecting long descriptions; unreadable disabled mods no longer block other mods.
- Explain unreadable scripts separately from active incompatibilities and refresh sibling switches after confirmed writes.
- Add native and Flutter regression coverage. Local Flutter/Dart and Gradle wrapper are unavailable; generation, compilation, tests and device validation remain pending.

## Unreleased — Repository maintenance

- Restore the standard MIT license text and move project clarifications into a separate disclaimer without additional licensing conditions.

- Keep the English README and repository-wide AGENTS.md in the project root; move translated READMEs and other documentation into docs and repair their relative links.

- Preserve ROM preparation and custom-theme documentation, repair local links, and separate release records and historical audits.
- Group branding, screenshots and optional tools; retire unused desktop scaffolding, copied external references and generated previews.
- Keep authored documentation visible to Git and exclude generated Android deliverables. Runtime code and release manifests are unchanged.

## 1.9.1 — Fluid navigation and guided permissions

- Route Android Back, the classic drawer, the Retro Manga menu, the dock, internal links and the themed Back arrow through one in-memory history of main destinations: secondary screens pop, query strings survive, repeated destinations do not duplicate entries and Back only exits from Home without history.
- Keep Player draft protection intact, so leaving with unsaved changes still asks first and a confirmed discard returns to the previous destination through the same navigation policy.
- Add a Permissions & access center, reachable from Settings, that re-reads the real Android state on every visit and on resume, with cards for the game folder, notifications, all-files access where supported, the floating overlay and battery optimization.
- Add a four-step guided setup — welcome, game folder, automatic installation and ready — shown once on first launch and replayable from the permissions center. It records only educational progress and never stores whether a permission is currently granted.

This patch keeps the Android minimum, storage layout, download/install contract and forced-update policy of 1.9.0; the floating overlay remains unchanged.

## 1.9.0 — Released

- Add a complete, swipeable How to Play guide and a local ROM preparation tool for valid user-provided USA `.z64`, `.v64` and `.n64` dumps.
- Add Play: create or join compatible multiplayer sessions with a short code, share the code as text, keep the connection alive while the game is open and expose privacy, diagnostics and optional battery controls.
- Replace Manga-theme drawer navigation with a responsive slide menu and add the Manga Deluxe interface, themed ROM/Save screens, ambient music and independently configurable UI sounds.
- Improve Library and Save Files startup with persisted snapshots refreshed in the background, and make Player profile restoration more immediate.
- Display supported images and video previews in mod descriptions; YouTube links open through Android's recognized URL handler.
- Add precomputed mod-description translations for Spanish, Brazilian Portuguese, French and Italian, with an offline themed toggle to return to the original English and a safe English fallback for older catalogs.
- Shorten screen transitions to a fade-and-slide that leaves the previous screen static, removing full-screen scaling and overlapping dock, shimmer and first-load animations.
- Expand Retro Manga/Manga Deluxe styling across Home, Catalog, Popular, Favorites, Library, mod details, Prepare ROM, Save Files and Play while retaining low-end-device safeguards.
- Add complete French and Italian UI localization, persistent language selection and localized Android notifications.
- Show Touch Controls creator credits, including favorites, with `Release Soon` as the safe fallback.
- Classify the Android application as a game with `android:appCategory="game"`.
- Keep technical diagnostics behind user actions and add regression coverage for navigation, localization, ROM preparation, Play, caching, themes and media metadata.

The floating overlay language remains unchanged in 1.9.0. The final physical-device matrix is still pending after publication.
