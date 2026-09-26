#!/usr/bin/env bash

set -euo pipefail

# Uses awww's built-in restore command which reads the daemon's saved state.
awww restore
