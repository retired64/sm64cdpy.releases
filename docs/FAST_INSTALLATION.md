# Optional fast installation (Android)

This branch integrates the direct writer from `Files-examples/` into the existing
parallel SAF extractor. The example folder is reference material, not packaged
application source. No measured speed target is promised: compare the same
archive on a device before and after granting access.

## Selection and permissions

Settings → Enable faster installation is optional. Android remains the authority:
`hasAllFilesAccess`, `supportsAllFilesAccess` and `requestAllFilesAccess` expose
current platform state through the existing installer channel. Opening Settings
is not success. The tile rechecks on resume and hides after a confirmed grant.
No permission cache or cross-engine singleton is introduced. Each native install
re-evaluates eligibility; declining/revoking broad access leaves SAF available.

Direct writes require the external-storage document provider, a `primary:`
document ID, a retained read/write tree grant, and an existing writable directory.
The path is derived from the **destination document ID**, not the ancestor grant
ID: `mods`, `user/mods`, `dynos/packs`, `user/dynos/packs` all qualify equally.
DynOS and Touch Controls share the same destination; VIP, Render96 and OMM use
their existing destination selection. Opaque providers, secondary volumes,
Android/ trees, traversal and symlink aliases never select direct writes.

- Android 11+: opt-in `MANAGE_EXTERNAL_STORAGE`, checked with
  `Environment.isExternalStorageManager()`.
- Android 7–9: existing runtime `WRITE_EXTERNAL_STORAGE`, requested only after
  tapping the optional action; the permission callback confirms the result.
- Android 10: retain SAF. This app does not enable legacy external storage, so
  requesting WRITE_EXTERNAL_STORAGE here would misleadingly imply acceleration.

The manifest permission affects distribution policy. Direct APK distribution
and Play approval are different; a Play submission must independently satisfy
Google's all-files-access policy. No Play-specific bypass is implemented.

References:
- https://developer.android.com/training/data-storage/manage-all-files
- https://developer.android.com/training/data-storage/shared/documents-files
- https://developer.android.com/about/versions/11/privacy/storage

## Shared write contract

`SafZipExtractor.TreeSink` selects DirectTreeWriter or SafTreeWriter once per
operation. ZIP random access, streaming fallback, 7z and standalone files all
use that abstraction, including manual mods/DynOS copy methods. The manual
copies now run off the main thread and respect delete-before-create behavior.

The existing ZIP path already used ZipFile and parallel SAF before integration;
this change does not claim those earlier improvements as newly measured work.
Concurrency remains bounded to 4–8 workers, with a 256 KiB buffer per thread.
7z has a bounded small-entry queue; reading and writing check cancellation.
ZIP fallback and loose-file chunks are cancellation-aware too. Coroutine scopes
wait for child writers before the caller performs rollback. Worker completion
still requires a persisted receipt; a full progress bar is not terminal success.

Direct paths are canonically contained below the selected directory. Directory
versus file collisions fail instead of recursively deleting unrelated content.
SAF replacement deletion errors propagate, including revoked permissions; they
are no longer swallowed before createDocument. Selection requires the SAF grant
and verifies it again after writing; direct mode does not replace folder consent.

WriteJournal uses filesystem deletion for direct operations, SAF for fallback.
It removes newly created files and only empty newly created directories. **It
is not a transactional restore of overwritten files**: existing entries are not
removed by rollback, but an interrupted overwrite can already have changed their
contents. This is the existing journal limitation, not a backup facility. A
process kill can also prevent in-memory rollback. Reinstall to repair partial
replacement; do not report a failed/cancelled operation as installed.

## Receipts, library and engines

Manifest paths, package shape, sentinel limits and operation identity are the
same in both writers. Filesystem writes target the exact files exposed by SAF;
no URI is fabricated for receipts. InstallationSafVerifier reads fresh bounded
sentinels, and InstallationReceiptStore remains the durable installation evidence.

Successful native installs and failed/cancelled cleanup invalidate InstallationDiscoveryScanner's persisted
cache because replacing nested files need not change root timestamps. New SAF
writer directory indexes are per-operation and discarded at return/failure.
Manual Flutter success also emits the existing library invalidation signal.
Automatic installs retain BgInstallCompleted, receipt refresh and OverlayBridge
synchronization. Game-mod activation reads the actual directories/config and its
existing freshness invalidation still runs after an install. No activation or
configuration writes were moved to an independent cache.

## Verification

Pure JVM coverage checks the four destination layouts, opaque/nonprimary IDs,
Android/ exclusions, traversal, symlink containment and direct journal cleanup.
Existing manifest tests still cover deterministic bounded sentinel generation.
Full Kotlin compilation, Flutter generation/analyze/tests and Android tests must
pass in Testing; compilation against stubs alone is not device validation.

Device matrix (not executable from this Termux session):

- Same ZIP with thousands of files with permission denied/granted/revoked.
- Small .lua and large standalone .bin, preserving their target name.
- Small/large 7z entries, reinstall and file/directory name collisions.
- All four layouts, Touch Controls, OMM DynOS and an opaque SAF provider.
- Cancel during directory preparation and small/large file writes; verify no
  writes continue after cleanup and no final success is shown.
- Two different installs concurrently; change screens, minimize and reopen.
- Fresh library and existing folder replacement; app and floating overlay.
- Android 7–9 permission dialog, Android 10 SAF, Android 11+ Settings return.
