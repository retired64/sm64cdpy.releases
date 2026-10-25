# Precomputed mod-description translations

This pipeline is intentionally separate from `coopdx64.py`. It accepts a
completed catalogue, keeps the original English descriptions and produces a
second JSON suitable for review before Flutter consumes it.

## Output contract

Every mod retains `description` and receives:

```json
{
  "description_source_hash": "sha256:...",
  "description_translations": {
    "es": "...",
    "pt_BR": "...",
    "fr": "...",
    "it": "..."
  }
}
```

The root receives `translation_metadata`. Because translations are part of the
`mods` payload, the script recalculates `catalog_id` and preserves the prior ID
as `translation_metadata.source_catalog_id`.

## Local use

Use Python 3.11. The requirements explicitly select the CPU-only PyTorch
wheel on Linux so the translation environment does not download CUDA packages.

```bash
python3.11 -m venv .venv-translations
source .venv-translations/bin/activate
python -m pip install --upgrade pip
python -m pip install -r scripts/catalog_translation_requirements.txt
python scripts/precompute_catalog_translations.py \
  assets/db/database_sm64coopdx.json \
  /tmp/database_sm64coopdx.translated.json \
  --download-models
python scripts/validate_translated_catalog.py \
  /tmp/database_sm64coopdx.translated.json \
  --source assets/db/database_sm64coopdx.json
```

The SQLite cache is keyed by description hash, locale and translation-engine
version. Unchanged descriptions are therefore reused on subsequent runs.
If a run is interrupted or a description fails, launch the same command again:
completed descriptions are read from the cache instead of being translated
again. Decorative lines made only from symbols are preserved verbatim.

## Manual workflow

`Preview translated mod catalogue` has three inputs:

- `catalog_url`: optional HTTPS input; blank uses the bundled catalogue.
- `locales`: defaults to every non-English app locale.
- `upload_to_drive`: when enabled, uploads only the validated translated JSON.

The workflow never commits the result, publishes a release or creates a GitHub
artifact. Google Drive credentials are configured only for the optional upload
step and removed afterward.
