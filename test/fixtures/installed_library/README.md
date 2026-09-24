# Installed Library fixtures

These fixtures are original, minimal test data created for SM64CDPY. They do
not contain third-party mods, artwork, game files, or executable Lua logic.

Run `./generate_fixtures.sh` from this directory to recreate the ZIP and 7z
archives from `source/`. The cases intentionally cover the package shapes that
the installed-library manifest must support:

| Fixture | Package shape | Expected sentinels |
|---|---|---|
| `single-root-main.zip` | one common directory with `main.lua` | `sample-main/main.lua`, `sample-main/assets/icon.txt` |
| `root-files.zip` | files written directly at the SAF root | `main.lua`, `config.txt` |
| `multiple-roots.zip` | two independent mods in one archive | `alpha/main.lua`, `beta/mod.lua` |
| `single-root-mod.7z` | one common directory in 7z format | `sample-seven/mod.lua`, `sample-seven/data/value.txt` |
| `sample-loose.lua` | one loose source file | `sample-loose.lua` |
| `sample-loose.luac` | opaque loose bytecode-shaped fixture | `sample-loose.luac` |

The `.luac` file is deliberately opaque test data, not valid executable Lua
bytecode. Tests must treat it as a file whose extension and bytes are preserved,
not execute or parse it.

