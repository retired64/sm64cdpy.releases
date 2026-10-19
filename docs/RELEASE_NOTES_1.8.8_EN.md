## SM64CDPY v1.8.8 — Smoother themes and optional faster installation

Version 1.8.8 refines the visual themes for low-end devices and adds an optional direct-storage installation path while preserving the standard folder-access fallback.

### More consistent visual themes

- Minish Cap extends its paper, chapter-sign and wooden-card language across shared surfaces without expensive blur, clipping or per-card textures.
- Mario Kart 64 can now follow the selected cyan, blue, violet, pink, coral, amber, green or lime interface accent while retaining readable contrast.
- The status bar safe area is respected throughout the app, including the drawer and full-screen routes.

### Performance for low-end devices

- Theme backdrops use bounded native painting and cached optimized assets instead of repeated filters or animated decoration.
- Player avoids redundant themed layers around its native preview, while shared cards and navigation retain the optimized rendering path.

### Optional faster installation

- Settings can request optional all-files access on supported Android versions to write directly into compatible primary-storage game folders.
- The permission is optional: users who decline it continue using the existing Android folder picker and SAF installation flow.
- ZIP, 7z and loose-file installation share bounded parallel extraction, cancellation checks, path validation, rollback and verified receipts.
- The library invalidates stale discovery results after automatic and manual installations so the installed state refreshes coherently.
