#!/usr/bin/env python3
"""Validate and render SM64CDPY release manifests without third-party packages."""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


REQUIRED_LOCALES = ("en", "es", "pt-BR")
SEMVER_PATTERN = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?$")


class ManifestError(ValueError):
    pass


def _non_empty(value: Any, path: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ManifestError(f"{path} must be a non-empty string")
    return value.strip()


def _exact_keys(value: dict[str, Any], expected: set[str], path: str) -> None:
    actual = set(value)
    if actual != expected:
        missing = sorted(expected - actual)
        extra = sorted(actual - expected)
        raise ManifestError(f"{path} keys mismatch; missing={missing}, extra={extra}")


def load_manifest(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ManifestError(f"cannot read {path}: {error}") from error
    if not isinstance(value, dict):
        raise ManifestError("manifest root must be an object")
    return value


def validate_manifest(manifest: dict[str, Any]) -> None:
    _exact_keys(
        manifest,
        {"schemaVersion", "version", "build", "publishedAt", "forceUpdate", "locales"},
        "manifest",
    )
    if manifest["schemaVersion"] != 1:
        raise ManifestError("schemaVersion must be 1")
    version = _non_empty(manifest["version"], "version")
    if not SEMVER_PATTERN.fullmatch(version):
        raise ManifestError(f"version is not supported SemVer: {version}")
    build = manifest["build"]
    if isinstance(build, bool) or not isinstance(build, int) or build < 1:
        raise ManifestError("build must be a positive integer")
    published_at = _non_empty(manifest["publishedAt"], "publishedAt")
    try:
        parsed_date = datetime.fromisoformat(published_at.replace("Z", "+00:00"))
    except ValueError as error:
        raise ManifestError("publishedAt must be an ISO-8601 date-time") from error
    if parsed_date.tzinfo is None:
        raise ManifestError("publishedAt must include a timezone")
    if not isinstance(manifest["forceUpdate"], bool):
        raise ManifestError("forceUpdate must be a boolean")

    locales = manifest["locales"]
    if not isinstance(locales, dict):
        raise ManifestError("locales must be an object")
    _exact_keys(locales, set(REQUIRED_LOCALES), "locales")
    for locale in REQUIRED_LOCALES:
        localized = locales[locale]
        path = f"locales.{locale}"
        if not isinstance(localized, dict):
            raise ManifestError(f"{path} must be an object")
        _exact_keys(localized, {"title", "summary", "highlights", "sections"}, path)
        _non_empty(localized["title"], f"{path}.title")
        _non_empty(localized["summary"], f"{path}.summary")
        highlights = localized["highlights"]
        if not isinstance(highlights, list) or not highlights:
            raise ManifestError(f"{path}.highlights must be a non-empty array")
        for index, highlight in enumerate(highlights):
            _non_empty(highlight, f"{path}.highlights[{index}]")
        sections = localized["sections"]
        if not isinstance(sections, list) or not sections:
            raise ManifestError(f"{path}.sections must be a non-empty array")
        for section_index, section in enumerate(sections):
            section_path = f"{path}.sections[{section_index}]"
            if not isinstance(section, dict):
                raise ManifestError(f"{section_path} must be an object")
            _exact_keys(section, {"heading", "items"}, section_path)
            _non_empty(section["heading"], f"{section_path}.heading")
            items = section["items"]
            if not isinstance(items, list) or not items:
                raise ManifestError(f"{section_path}.items must be a non-empty array")
            for item_index, item in enumerate(items):
                _non_empty(item, f"{section_path}.items[{item_index}]")


def read_pubspec_version(path: Path) -> tuple[str, int]:
    try:
        content = path.read_text(encoding="utf-8")
    except OSError as error:
        raise ManifestError(f"cannot read {path}: {error}") from error
    match = re.search(r"^version:\s*([^+\s]+)\+([0-9]+)\s*$", content, re.MULTILINE)
    if match is None:
        raise ManifestError(f"{path} must contain version: <version>+<build>")
    return match.group(1), int(match.group(2))


def validate_pubspec(manifest: dict[str, Any], pubspec: Path) -> None:
    version, build = read_pubspec_version(pubspec)
    if manifest["version"] != version or manifest["build"] != build:
        raise ManifestError(
            "manifest/pubspec mismatch: "
            f"manifest={manifest['version']}+{manifest['build']}, pubspec={version}+{build}"
        )


def render_markdown(manifest: dict[str, Any], locale: str, include_force: bool) -> str:
    localized = manifest["locales"][locale]
    lines = [
        f"## SM64CDPY v{manifest['version']} — {localized['title']}",
        "",
        localized["summary"],
        "",
    ]
    for section in localized["sections"]:
        lines.extend((f"### {section['heading']}", ""))
        lines.extend(f"- {item}" for item in section["items"])
        lines.append("")
    if include_force and manifest["forceUpdate"]:
        lines.extend(("[FORCE]", ""))
    return "\n".join(lines).rstrip() + "\n"


def write_output(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--pubspec", type=Path)
    parser.add_argument("--github-output", type=Path)
    parser.add_argument("--discord-output", type=Path)
    args = parser.parse_args()

    try:
        manifest = load_manifest(args.manifest)
        validate_manifest(manifest)
        if args.pubspec is not None:
            validate_pubspec(manifest, args.pubspec)
        if args.github_output is not None:
            write_output(args.github_output, render_markdown(manifest, "en", include_force=True))
        if args.discord_output is not None:
            write_output(args.discord_output, render_markdown(manifest, "es", include_force=False))
    except ManifestError as error:
        print(f"release manifest error: {error}", file=sys.stderr)
        return 1

    print(f"validated release manifest v{manifest['version']}+{manifest['build']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
