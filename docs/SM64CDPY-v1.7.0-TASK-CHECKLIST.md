# Task Checklist Manager — SM64CDPY v1.7.0

> Incremental stabilization and pre-release plan for `1.7.0+18`.

| Field | Value |
|---|---|
| Project | SM64CDPY — SM64CoopDX Mods Browser |
| Target version | 1.7.0+18 |
| Intended channel | GitHub pre-release |
| Platform | Android 7.0+ (`minSdk 24`) |
| Checklist created | 2026-09-20 |
| Current phase | Stabilization and validation |
| Release owner | Retired64 |

## How to use this checklist

- Complete tasks in priority order when possible.
- Add the test date, device, Android version and result next to every manual test.
- Do not mark a group complete because the feature exists in code; mark it only after verification.
- Record bugs under **Findings and decisions** and link the issue or commit when available.
- A failed optional item does not necessarily block a pre-release. Every item marked **release gate** does.

## Current assessment

| Area | Score | Assessment |
|---|---:|---|
| Product and concept | 8.5/10 | Useful mobile companion with a distinctive overlay concept |
| Architecture | 7.5/10 | Sound Flutter/Kotlin split; state recovery still needs consolidation |
| Functional implementation | 7.5/10 | The difficult download/install pipeline is present |
| Verifiable quality | 5/10 | No automated test suite or recorded device matrix yet |
| Maintainability | 7/10 | Navigable code and clean canonical static analysis |
| Stable-release readiness | 6/10 | Suitable for pre-release after the release gates below |
| Overall | **7.2/10** | Promising and worth continuing; stabilize before expanding scope |

## Confirmed implementation baseline

- [x] Main and auxiliary JSON catalogues exist.
- [x] Search, filters, sorting, pagination and favourites exist.
- [x] English, Spanish and Brazilian Portuguese localization exists.
- [x] SAF folder selection and persisted Android permissions exist.
- [x] WorkManager download → install chains exist.
- [x] Foreground notifications, progress and cancellation exist.
- [x] ZIP, 7z and standalone file handling exists.
- [x] GitHub Release URL resolution and OTA update flow exist.
- [x] The floating overlay and main-engine bridge exist.
- [x] DynOS and Touch Controls share one destination and respect the global auto-install preference in the drawer flow.
- [x] DynOS and Touch Controls use friendly download errors while retaining copyable technical details.
- [x] `flutter analyze lib` completed with no issues on 2026-09-20.
- [ ] Verify every item above at runtime on a clean physical device.

## P0 — Pre-release gates

These items should be completed before publishing `v1.7.0` as a GitHub pre-release.

### Reproducible environment

- [ ] Decide the single Flutter version for local development and GitHub Actions.
  - Repository/workflows now declare Flutter `3.41.7`.
  - The environment used during the documentation audit reported Flutter `3.38.7`.
  - Do not change CI blindly: first run a clean successful build with the chosen version.
- [ ] Pin the chosen Flutter version consistently in both workflows and documentation.
- [ ] Confirm Java 17 and the Android SDK/NDK versions used by the successful build.
- [ ] Run `flutter clean` followed by `flutter pub get`.
- [ ] Run `flutter analyze lib` successfully.
- [ ] Produce a signed arm64 release APK.
- [ ] Install the signed APK on a physical device.
- [ ] Record the exact tool versions and build date below.

Environment record:

```text
Flutter:
Dart:
Java:
Android SDK:
NDK:
Host OS:
Build date:
Result:
```

### Core smoke test — release gate

- [ ] Clean installation opens without crashing.
- [ ] Bundled catalogue loads without a network connection.
- [ ] Remote database refresh succeeds.
- [ ] Search, category filters, ordering and pagination work.
- [ ] A favourite survives closing and reopening the app.
- [ ] Favourite export and import work with UTF-8 content.
- [ ] Theme selection survives restart.
- [ ] EN, ES and PT-BR selection survives restart.
- [ ] The app detects and launches SM64CoopDX when installed.
- [ ] The missing-game path provides understandable feedback.

### Download and installation — release gate

- [ ] Select the normal mods destination through SAF.
- [ ] Select the DynOS/Touch Controls destination through SAF.
- [ ] Download and install one ZIP successfully.
- [ ] Download and install one 7z successfully.
- [ ] Download and copy one standalone Lua or other supported file.
- [ ] Progress changes during both download and extraction.
- [ ] Completion is shown in the app and notification.
- [ ] Cancel an active download from the app.
- [ ] Cancel an active operation from the notification.
- [ ] Confirm a failed URL produces an error instead of an infinite spinner.
- [ ] Confirm a denied notification permission does not crash the operation.
- [ ] Revoke the SAF permission and confirm the app requests folder selection again.

### Overlay — release gate

- [ ] Grant overlay permission and open the bubble.
- [ ] Deny overlay permission and verify useful feedback.
- [ ] Open and close the bubble repeatedly without freezing either engine.
- [ ] Search and change overlay sections.
- [ ] Start a download from the overlay.
- [ ] Receive live download and installation progress in the overlay.
- [ ] Cancel from the overlay.
- [ ] Close and reopen the panel during an active operation.
- [ ] Toggle auto-install in Settings and confirm the bridge immediately uses the new value.
- [ ] Keep the game open while the overlay operates.
- [ ] Document any engine/process recreation failure as a known pre-release limitation.

### GitHub pre-release pipeline — release gate

- [ ] Confirm `pubspec.yaml` contains the intended `versionName` and `versionCode`.
- [ ] Confirm the matching entry exists in `changelog_screen.dart`.
- [ ] Confirm `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD` and `KEY_ALIAS` secrets.
- [ ] Run `buildAndroid-testing.yml` successfully first.
- [ ] Download and install its arm64 artifact.
- [ ] Run `buildAndroid.yaml` with `prerelease: true`.
- [ ] Confirm arm64, arm32 and x86_64 assets are attached.
- [ ] Confirm filenames are recognized by `UpdateConfig`.
- [ ] Confirm release notes and SHA-256 hashes are present.
- [ ] Confirm the pre-release is not incorrectly marked as latest stable.
- [ ] Test the OTA check against the published pre-release behavior and document the result.

## P1 — Stabilization work

### WorkManager as the source of truth

- [x] Reconcile restored `BackgroundInstallService._infoMap` entries with actual WorkManager state.
- [x] Remove or correct stale active entries after process death.
- [x] Define behavior when the stored Work UUID no longer exists.
- [x] Restore download and installation progress after reopening the app where possible.
- [ ] Add a test for RUNNING, ENQUEUED, SUCCEEDED, FAILED and CANCELLED restoration.

### Unique identities and parallel operations

- [x] Stop using sanitized display titles as the only work identity.
- [x] Define an operation key such as `section + modId + fileId`.
- [x] Derive temporary filenames/directories, unique work names and notification IDs from an operation/Worker identity.
- [ ] Test two different mods whose titles sanitize to the same value.
- [ ] Test two different mods in parallel.
- [ ] Test a repeated tap on the same mod and confirm intentional replacement.
- [ ] Confirm download and install notifications cannot collide across active operations.

### Async persistence and cancellation

- [x] Replace or explicitly document the fire-and-forget persistence in `_persistToPrefs()`.
- [x] Ensure asynchronous SharedPreferences failures are contained without escaping the event listener.
- [x] Make `cancelMod()` await native WorkManager cancellation.
- [x] Avoid showing a final cancelled state before native cancellation is confirmed.
- [ ] Review every unawaited Future in download, overlay and persistence paths.

### Favourites initialization

- [ ] Remove the race between the initial SharedPreferences read and an immediate favourite toggle.
- [ ] Represent loading explicitly or await initialization before mutation.
- [ ] Add tests for toggle-before-load, import, export and restart.

### Locale synchronization

- [ ] Decide whether the overlay follows the device locale or the app-selected locale.
- [ ] If it follows the device, remove the unused `app_locale` mirror.
- [ ] If it follows the app, send the selected locale through the engine bridge and apply it safely.
- [ ] Identify every writer and reader before changing this shared value.
- [ ] Test locale changes while the overlay is open.

## P1 — Required test matrix

| Android | Device/emulator | Focus | Result | Date |
|---|---|---|---|---|
| 7 / API 24 |  | Minimum supported SDK | ⬜ |  |
| 10 / API 29 |  | Legacy/scoped storage boundary | ⬜ |  |
| 12 / API 31 |  | Background execution restrictions | ⬜ |  |
| 13 / API 33 |  | Notification permission | ⬜ |  |
| 14 / API 34 |  | Foreground service dataSync type | ⬜ |  |
| 15 |  | Modern lifecycle/storage behavior | ⬜ |  |
| 16 |  | Latest behavior and orientation limitations | ⬜ |  |

ABI checks:

- [ ] arm64-v8a physical device.
- [ ] armeabi-v7a build/install validation.
- [ ] x86_64 emulator validation.
- [ ] OTA asset selection for each ABI.

Network and file checks:

- [ ] Direct file URL.
- [ ] Multiple HTTP redirects.
- [ ] GitHub latest release URL.
- [ ] GitHub tagged release URL.
- [ ] HTTP 403, 404 and 410.
- [ ] Timeout or disconnected network.
- [ ] Response without `Content-Length`.
- [ ] Truncated response.
- [ ] Corrupted ZIP.
- [ ] Corrupted 7z.
- [ ] Archive with unsafe `../` path segments.
- [ ] Device with insufficient free storage.

Lifecycle checks:

- [ ] App moved to background during download.
- [ ] App process terminated during download.
- [ ] App process terminated during installation.
- [ ] Device reboot with queued/running work.
- [ ] Overlay engine closed while main engine stays alive.
- [ ] Main activity recreated while overlay stays visible.
- [ ] SAF permission revoked after selection.
- [ ] Notification permission revoked after first launch.

## P2 — Automated tests

- [ ] Create the initial `test/` directory and test conventions.
- [ ] Test `sanitizeModTitle` and collision cases.
- [ ] Test OTA semantic version comparison.
- [ ] Test ABI-specific APK selection.
- [ ] Test GitHub download URL resolution.
- [ ] Test each JSON catalogue parser with valid and malformed fixtures.
- [ ] Test favourites UTF-8 import/export.
- [ ] Test native event → `BgInstallInfo` state transitions.
- [ ] Test persisted install-state serialization and restoration.
- [ ] Test safe archive-path normalization.
- [ ] Test overlay states: pending, progress, error, cancelled and completed.
- [ ] Add MethodChannel/EventChannel fakes for integration-oriented service tests.
- [ ] Add at least one automated application smoke test.

## P2 — CI/CD improvements

- [ ] Add a `pull_request` validation workflow.
- [ ] Run `flutter analyze lib` or ensure ignored local reference repos cannot enter analysis scope.
- [ ] Run the automated test suite once it exists.
- [ ] Add an arm64 build check for pull requests or the main branch.
- [ ] Fix the release message that says only `versionCode` must change when an existing tag actually requires a new `versionName`.
- [ ] Validate that the Dart changelog parser found the requested version before publishing.
- [ ] Consider pinning third-party GitHub Actions to immutable commit SHAs.
- [ ] Decide whether the hard-coded Discord role ID belongs in repository configuration or a variable/secret.
- [ ] Confirm keystore cleanup runs after every failure path.

## P2 — Diagnostics and installation records

- [ ] Design an install record containing mod ID, version, source URL, destination, date and copied files.
- [ ] Persist successful install records independently from transient progress events.
- [ ] Add an installation/download queue screen backed by durable state.
- [ ] Add retry, cancel and clear-history actions.
- [ ] Add an exportable diagnostic report with app version, Android version, ABI, permissions and recent non-sensitive errors.
- [ ] Avoid exporting personal paths, tokens, webhook URLs or complete private URIs.
- [ ] Add preflight checks for available storage and current SAF access.

## P3 — Feature ideas after stabilization

- [ ] Installed-mod history.
- [ ] Mod update detection using installed version records.
- [ ] Repair or reinstall an existing mod.
- [ ] Safe uninstall based only on recorded files owned by that installation.
- [ ] Compatibility metadata and warnings.
- [ ] Improved overlay recovery and active-download summary/badge.
- [ ] Better download provenance and checksum verification when the source provides hashes.

Defer until the core is stable:

- [ ] Accounts or cloud synchronization.
- [ ] Social features or comments.
- [ ] A proprietary marketplace/backend.
- [ ] Automatic bulk downloads.
- [ ] Additional desktop/mobile platforms.
- [ ] Large architectural or visual rewrites without a concrete defect.

## Pre-release acceptance criteria

The current version may be published as a pre-release when:

- [ ] Every P0 release gate has passed or has a clearly documented known limitation.
- [ ] The app builds reproducibly with one declared Flutter version.
- [ ] At least one physical arm64 device passes the complete smoke test.
- [ ] ZIP, 7z and standalone installation each pass once.
- [ ] Download failure and cancellation provide visible feedback.
- [ ] The overlay completes one end-to-end installation or its limitation is prominently included in release notes.
- [ ] No known issue risks writing outside the selected SAF tree.
- [ ] Release assets, filenames and SHA-256 hashes are correct.
- [ ] The release is marked **pre-release**, not stable/latest.

## Stable-release acceptance criteria

Do not promote the version to stable until:

- [ ] WorkManager state is reconciled after process death.
- [ ] Parallel operations and identity collisions have been tested.
- [ ] The representative Android matrix has no unresolved critical failures.
- [ ] A minimum automated test suite covers parsing, state transitions, URL resolution and OTA selection.
- [ ] Known limitations are documented and acceptable.

## Findings and decisions log

Use this section as the checklist is executed.

| Date | Area | Finding or decision | Status / link |
|---|---|---|---|
| 2026-09-20 | Static analysis | `flutter analyze lib` passed with no issues | Confirmed |
| 2026-09-20 | Local workspace | Root analysis includes ignored example repositories and reports unrelated issues | Use canonical source scope |
| 2026-09-20 | Toolchain | Repository and workflows aligned to Flutter 3.41.7 | Updated; verify the release build in GitHub Actions |
| 2026-09-20 | Tests | No `test/` or `integration_test/` suite exists | Open |
| 2026-09-20 | Release plan | Publish current 1.7.0 as a GitHub pre-release after P0 gates | Decided |
| 2026-09-20 | DynOS / Touch Controls | Unified automatic WorkManager flow, manual post-download confirmation, shared-folder wording, background card progress and friendly 404 handling; the DynOS-targeted OMM sibling was aligned too | Implemented; runtime test pending |

## Notes

- Keep Komi Store, Floating Apps examples, `run-actions-github`, and other cloned references local and ignored. They are research material, not project modules.
- Before changing any shared preference, cached flag, Worker identity or notification ID, follow the synchronization checklist in `AGENTS.md`.
- Record every intentional fire-and-forget Future in the corresponding change summary.
