# Mod catalog database contract

This document defines the production boundary between the `coopdx64.py`
scraper and the Android application. A scraper run is a candidate artifact;
it is not automatically a production database.

## Current contract: schema 2

The root object contains `schema_version`, `catalog_id`, `catalog_status`,
`generated_at`, `source`, `mod_count`, `resolution_summary` and `mods`.
The application accepts legacy schema 1 and schema 2. It rejects unknown
future schemas and every schema-2 catalog marked `partial`.

## Durable identity

Array position is presentation only and must never identify installed content.

- A mod uses its numeric source `id`.
- A version uses `version_id`, normally derived from `/version/{id}`.
- A file uses `file_id`, derived from a provider/source attachment ID when
  available and from a deterministic canonical fallback otherwise.
- `source_url` preserves the stable URL before redirects or temporary CDNs.
- `download_url` is the best known URL at scrape time.

Flutter and the overlay use `mod id + version_id + file_id`. They also expose
legacy positional aliases so receipts written by 1.8.0 remain recognizable
after the first schema-2 refresh.

## Provider behavior

- GitHub release assets remain on stable `/releases/download/` URLs.
- MediaFire stores its stable file page. The app resolves its temporary CDN
  URL immediately before downloading.
- GameBanana item pages can be resolved through its public Core API at
  download time.
- Google Drive file links are normalized at download time.
- Google Drive folders are only considered resolved when the scraper can list
  compatible files. Otherwise the UI offers the source folder and never
  reports a false installation.

RAR files are not a supported automatic installation format. They must not be
promoted as automatically installable until the native installer has a tested
RAR extractor and rollback coverage.

## Application acceptance transaction

1. Download over HTTPS with a bounded timeout.
2. Decode UTF-8 and validate root, schema and generation status.
3. Validate mod IDs, version/file shapes and stable schema-2 IDs.
4. Parse every record with the same model used by the catalog UI.
5. Verify `mod_count` and reject an unexpected shrink greater than 25%.
6. Write and flush a sibling temporary file.
7. Move the prior database to `last-good` and atomically promote the candidate.
8. Keep the parsed candidate as the in-memory cache.

If a persisted database cannot be parsed on startup, it is quarantined, the
valid last-good copy is attempted, and the APK-bundled database remains the
final fallback.

## Publication gates

- The scraper has zero failed mods and emits `catalog_status: complete`.
- `mod_count` equals the array length and all stable IDs are unique in scope.
- Added, removed and changed counts are reviewed.
- Unresolved-provider and unsupported-extension reports are reviewed.
- Flutter model, identity and catalog tests pass.
- A testing APK refreshes the candidate and exercises direct, MediaFire,
  GameBanana and Google Drive samples.
- Released app versions retain their existing schema endpoint until retired.

Do not silently change the semantics of a production endpoint used by released
clients. Prefer versioned paths such as `db/v1/` and `db/v2/`.
