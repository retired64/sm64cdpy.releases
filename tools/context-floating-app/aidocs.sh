#!/usr/bin/env bash
# Wrapper para llamar la CLI como: ./aidocs.sh fetch
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/cli.py" "$@"
