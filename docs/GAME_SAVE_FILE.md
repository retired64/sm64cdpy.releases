# GameTool → Save File

Android-only editor for the original game's 512-byte EEPROM save. The reference
is the checked-out SM64CoopDX source, not the Python tool's comments.

## Native contract

`GameSaveCodec` preserves the byte order detected from signatures, all unrelated
bytes and the independent primary/alternate copies. It uses four pairs of
56-byte blocks, 25 star bytes, 15 coin records and two 32-byte menu blocks.
Cannons use course number (BOB=1), while stars use course index (BOB=0).
Castle stars use flag bits 24–28; unknown flag bits survive editing. Completing
120 stars is an explicit draft action and does not write until Apply is confirmed.
100-coin stars enforce a minimum visible coin score of 100 as the game does,
including saves produced by external editors with a raw score below 100.
Copy preserves the distinct alternate copy. Erase clears both copies and signs
the primary. Copy/erase update menu score ages and both menu copies only when ages change,
requiring a valid or untouched all-zero primary menu block. Invalid nonempty slot blocks cannot be edited/copied.

`GameSaveStore` resolves `user/sm64_save_file.bin` from the existing SAF grant.
It never creates a missing game save and does not search arbitrary paths. Read
is bounded, conversion runs through the existing gameTask background channel,
and mutations share InstallationSafAccessCoordinator.lock with other SAF work.
Active download/install Workers block mutations. The game itself must be closed:
the manager cannot lock the game's process or prevent a concurrent external
write after its final hash check.

Every mutation checks document identity and SHA-256 revision, saves and verifies
a private full backup, checks the original again, writes and rereads the exact
expected bytes. SAF does not guarantee atomic rename/replace. A failed write
never reports success; recovery backups remain available after refreshing,
including when a truncated or unrecognized save cannot be parsed. Backup IDs
are generated UUID names under a document-specific hash directory. Backups are
retained without automatic pruning; they are local and are removed on uninstall.
Snapshots contain all four slots and menu data; restoration replaces the entire
file. They do not contain config, mods, DynOS or mod-specific save files.

## Flutter and UX

Drawer submenu GameTool → Save File routes to `/game-tool/save-file`. The main
engine provider owns load/mutation state and keeps last-confirmed data on error.
Folder changes reset its projection and retire old responses. Draft editors
capture the original document identity and revision; refresh/resume cannot
silently rebase a stale draft. The UI uses RetroTheme panels/typography and
Material semantic controls for all six themes, with primary/alternate selection,
four tappable file cards, expandable course details, confirmation and timestamped backups.
Library and Player also live under GameTool; their existing routes stay compatible.
The main copy is the default. Secondary copies are tucked inside an explained
advanced section; they are not dated application backups. Each editor identifies
the selected slot and copy, shows a live draft star total, and saves only after
Apply plus confirmation. Completing 120 stars is an explicit overflow-menu
action, never a status badge. Clearing stars changes the draft only.
No Python runtime is included; sm64_savetool.py remains a reference outside the
product build. No state is shared with the independent overlay engine.

## Verification

Native tests cover both byte orders, exact preservation of other copies, cannon
indexing, castle-star removal, coin normalization, copy/erase and corrupt input.
Run Flutter generation/format/analyze/tests and native release unit tests in
Testing. Physical checks: existing/missing/revoked user folder; valid/invalid
copies; both modes of all six themes; text scale; cancel draft/confirmation;
refresh/resume; concurrent folder change; verified backup/restore; failed write.
Compatibility is limited to original SM64 course semantics; a 512-byte ROM-hack
save is not proof that its levels or progress match the original game.

Menu regression checks passed in Testing run 39172228152: Flutter analysis and
the Flutter suite, including opening slot B independently from a completed A,
previewing 120 stars and cancelling without changing confirmed progress across
all six designs. Generated localization and Dart formatting are synced from the
runner. Device checks and light/dark visual review remain necessary.

Coin editing is not exposed in the application. Edit requests omit `coins`, so
the native codec preserves the original 15 raw coin records exactly, including
when applying the 120-star preset. The game can still derive an effective score
of at least 100 from a hundred-coin star; this does not require rewriting those
records. Older explicit coin payloads remain accepted for compatibility. Whole
slot copy/erase and full backup/restore retain their existing semantics.
