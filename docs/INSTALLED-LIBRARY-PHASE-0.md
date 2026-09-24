# Installed Library — Phase 0 findings and contracts

Status: **complete for design and repository fixtures** (2026-09-23).

This document freezes the decisions required before installation identity is
propagated through Flutter, Android, WorkManager, and the overlay. It does not
change production behavior. Physical installation through Android SAF remains
part of the later manual acceptance matrix.

## Evidence reviewed

- Catalogues: general, VIP, DynOS, Touch Controls, OMM Rebirth and Render96.
- Flutter entities, catalogue parsers, version resolver and operation-name
  builders in the main engine and overlay.
- `ModDownloadWorker`, `ModInstallWorker`, `ModInstallerPlugin` and
  `SafZipExtractor`.
- ZIP, 7z and loose-file branches, including current top-level-directory
  detection and SAF delete-before-create behavior.
- Original fixtures under `test/fixtures/installed_library/`.

The general catalogue currently contains 1,269 logical entries, 2,336 version
records and 2,559 downloadable file records. The audit found:

- seven duplicated visible titles with different numeric content IDs;
- 411 groups in which a filename is reused by more than one artefact;
- versions containing several downloadable files;
- 14 versions without downloadable files;
- many non-semantic version labels, such as `Demo`, `Alpha`, `Day One`, `nil`
  and prose labels;
- all 28 Touch Controls entries omit a version;
- DynOS and Touch Controls share the `dynos` destination but are different
  catalogue sections;
- Render96 can target either `mods` or `dynos` and can have no version;
- current operation names for several sections include the title, while
  general-mod file IDs use list indexes that can move after a catalogue update.

Consequently, titles, filenames, version ordering and destination alone are
not stable identities.

## Canonical identity contract

All persisted values use the contract version `v1`. Components are UTF-8 and
percent-encoded with RFC 3986 unreserved characters left intact. A decoder must
reject missing components, unknown contract versions and empty section/content
IDs instead of guessing from a title.

### Section values

The canonical section enum is:

```text
mods | vip | dynos | touch_controls | omm | render96
```

Destination is deliberately not part of section identity. The canonical
destination enum is independently:

```text
mods | dynos
```

This preserves the distinction between DynOS and Touch Controls even though
both install into the same SAF tree.

### Keys

```text
contentKey  = v1|<section>|<contentId>
artifactKey = v1|<section>|<contentId>|<artifactId>
operationKey = artifactKey
```

- `contentId` is the catalogue key/ID, converted to its exact string form.
- `artifactId` identifies one downloadable file from one release.
- A future operation kind must not be appended to `operationKey`; install,
  update and reinstall of the same artefact intentionally address the same
  unique-work identity.
- Display title, destination, URL and filename are metadata, never key parts.

### Artefact ID precedence

Catalogues should eventually publish explicit immutable `version_id` and
`file_id` fields. Until they do, Phase 1 uses this precedence:

1. explicit `file_id`, namespaced by explicit `version_id` when present;
2. stable source identifiers parsed from the catalogue's version/file URL
   (for example numeric version and `file` query IDs), when both are
   unambiguous;
3. `sha256` of canonical UTF-8 JSON containing `versionLabel`, `filename` and
   the canonical catalogue download URL (before network redirects), with keys
   sorted and no insignificant whitespace.

The digest fallback is opaque and lowercase hexadecimal. It intentionally
creates a new artefact if the upstream file identity changes. It must be
implemented once as a shared tested contract and matched byte-for-byte in both
engines; array indexes are allowed only to read legacy active operations and
must not be written to new receipts.

### Version policy

Store two fields:

- `versionLabel`: trimmed source text, nullable when absent;
- `comparableVersion`: parsed normalized numeric version, nullable.

Never invent `1.0` for missing or prose versions. Equality of artefact IDs is
always valid; update ordering is only claimed when both versions are
comparable. Otherwise the UI may offer reinstall or show a new catalogue
artefact without claiming that one prose label is newer.

### Coexistence and replacement

- Several artefacts may belong to one `contentKey` and remain in history.
- One current receipt exists per `artifactKey`.
- Installing the same `artifactKey` again is a reinstall and replaces its
  current receipt atomically while appending a history event.
- A different `artifactKey` for the same `contentKey` is an install/update
  candidate; it does not delete or mark old files absent until SAF verification
  proves their state.
- Multi-file releases are distinct artefacts because users may install only
  one file or several independently.

## Three non-competing sources of truth

| Question | Authority | Meaning |
|---|---|---|
| Is work running now? | WorkManager | pending, downloading, installing, cancelling and terminal Worker result |
| Did SM64CDPY confirm an install? | durable native receipt | evidence written only after all SAF writes succeed |
| Are the recorded files present now? | SAF verification | present, missing, unknown or permission revoked |

A receipt never overrides an active Worker. A receipt records the confirmed
past but does not prove current presence. SAF can invalidate presence but does
not erase history.

## Durable receipt contract v1

Kotlin owns the canonical receipt store because a Worker can finish while both
Flutter engines are dead. Use one atomically replaced JSON file per
`artifactKey` in app-private storage. The filename is a SHA-256 digest of the
`artifactKey`; the full key remains inside the validated JSON. Room is deferred
until query volume or migrations justify it.

Required fields:

```text
schemaVersion = 1
contentKey, artifactKey, operationKey
section, contentId, artifactId
destination
installedAt (UTC ISO-8601)
installWorkerId (UUID)
eventKind = install | update | reinstall
fileCount
sentinels[]
source = sm64cdpy | external
displaySnapshot { title, versionLabel, filename }
packageShape = loose_file | single_root | multiple_roots | root_files
```

Each sentinel stores a normalized relative path and its entry kind. Receipt
JSON must not contain a token, resolved private URL or full SAF URI. Invalid,
corrupt or future-schema receipts are quarantined/ignored individually and
must not prevent the Library from opening.

The initial retention policy is:

- keep current receipts until the user explicitly removes the record;
- keep at most 500 history events, pruning oldest first;
- clearing history does not delete current receipts or game files;
- removing a receipt does not delete game files;
- Hive, if added, is a rebuildable Flutter projection and never installation
  evidence.

## Sentinel selection contract

The extraction layer will later return a bounded write manifest. Phase 0 fixes
the selection rules so packages with thousands of entries remain cheap:

1. include `main.lua` and `mod.lua` paths first;
2. include a loose file's exact relative path;
3. include at least one file from every detected top-level root;
4. fill remaining slots with deterministic lexicographic paths;
5. cap receipts at 32 sentinels and record total `fileCount` separately;
6. never use directories alone as proof that installation is present.

Paths are sanitized exactly as `SafZipExtractor.sanitizeEntryName` does. A
package with two mod roots remains one installed artefact with multiple root
sentinels; discovery may later expose its internal mods, but must not fabricate
catalogue identities for them.

## Fixture matrix and expected extracted paths

The fixtures are legal, original and deliberately tiny. The source tree and a
reproducible generator are stored beside them.

| Fixture | Before extraction | Expected paths after extraction | Shape |
|---|---|---|---|
| `single-root-main.zip` | `sample-main/main.lua`, `sample-main/assets/icon.txt` | same paths under selected tree | single root; `main.lua` |
| `root-files.zip` | `main.lua`, `config.txt` | files directly under selected tree | root files |
| `multiple-roots.zip` | `alpha/main.lua`, `beta/mod.lua` | both roots under selected tree | multiple mods/roots |
| `single-root-mod.7z` | `sample-seven/mod.lua`, `sample-seven/data/value.txt` | same paths under selected tree | single root; `mod.lua`; 7z |
| `sample-loose.lua` | one file | `sample-loose.lua` | loose Lua |
| `sample-loose.luac` | one opaque file | `sample-loose.luac` | loose bytecode-shaped file |

ZIP and 7z listings were verified on 2026-09-23. Android SAF extraction,
provider behavior, revoked permissions and real-device performance remain
explicit Phase 2/4 and manual-acceptance work; static archive inspection is not
presented as a physical installation test.

## Phase 1 hand-off

Phase 1 may add identity models and propagation only. It must first add tests
for encoding/decoding, delimiter characters, same title/different content IDs,
same filename/different artefacts, reordered catalogue versions and parity
between main app and overlay. It must preserve read compatibility with active
legacy keys while ensuring that no new durable receipt uses a legacy key.
