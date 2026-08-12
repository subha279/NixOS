#!/usr/bin/env bash

set -euo pipefail

RUNTIME_CONFIG="$HOME/.cache/wallust/fuzzel.ini"

if [[ -f "$RUNTIME_CONFIG" ]]; then
  exec fuzzel --config="$RUNTIME_CONFIG"
else
  exec fuzzel
fi
