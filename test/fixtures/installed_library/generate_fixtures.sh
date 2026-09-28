#!/usr/bin/env sh
set -eu

fixture_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
source_dir="$fixture_dir/source"

rm -f \
  "$fixture_dir/single-root-main.zip" \
  "$fixture_dir/root-files.zip" \
  "$fixture_dir/multiple-roots.zip" \
  "$fixture_dir/single-root-mod.7z"

(
  cd "$source_dir/single-root-main"
  zip -X -q -r "$fixture_dir/single-root-main.zip" sample-main
)

(
  cd "$source_dir/root-files"
  zip -X -q "$fixture_dir/root-files.zip" main.lua config.txt
)

(
  cd "$source_dir/multiple-roots"
  zip -X -q -r "$fixture_dir/multiple-roots.zip" alpha beta
)

(
  cd "$source_dir/single-root-mod"
  7z a -bd -bb0 -mtc=off -mta=off -mtm=off \
    "$fixture_dir/single-root-mod.7z" sample-seven >/dev/null
)

