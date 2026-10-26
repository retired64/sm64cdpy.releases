## SM64CDPY v1.9.1 — Smoother navigation and guided permissions

Version 1.9.1 is a navigation patch: Back, the menus, the dock and the visual Back arrow share one history of main destinations, and a new Permissions & access center with a four-step guided setup explains and requests Android access only when it is actually needed.

### Navigation that goes back where you expect

- Main destinations share one history of at most 20 entries, identified by route path, with consecutive duplicates collapsed and query strings preserved.
- The Back order is explicit: close the drawer, dialog, modal or submenu; pop a secondary screen; return to the previous main destination; return to Home; and allow the app to exit only from Home without history.
- The classic drawer, the Retro Manga menu, the dock, internal links and the themed Back arrow all use the same policy, so the same action is reached from every entry point.
- Main destinations keep the menu button where their theme expects it and secondary screens show a themed Back arrow, including Permissions & access.
- Player keeps its unsaved-changes dialog; a confirmed discard returns to the previous destination through the same policy instead of a separate pop path.

### Guided permissions

- Permissions & access is a secondary screen inside Settings and shows the game folder, notifications, all-files access where the device supports it, the floating overlay and battery optimization.
- Each card reports allowed, not allowed or optional, exposes a Manage action and blocks parallel requests, and the snapshot is refreshed when the app resumes.
- Notifications are requested at the moment a background operation starts; declining them never blocks downloading or installation.
- The guided setup covers welcome, folder selection, automatic installation and a final ready check, with a progress indicator and the option to postpone it on the first step.
- Only the educational progress is persisted, so a permission revoked from Android settings is shown as not allowed the next time the screen is opened.

### Before publishing

- This patch does not force an update and keeps the 1.9.0 download, installation, storage and overlay behavior.
- The release timestamp is provisional until publication.
- Physical validation is still required for Back from every destination, the open drawer and dialogs, Player drafts, rotation and reopening.
- Physical validation is also required for granting and revoking each permission, returning from Android settings, notification denial on Android 13+ and a revoked game folder.
