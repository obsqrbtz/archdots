#!/usr/bin/env bash
set -euo pipefail

cliphist list \
    | rofi -dmenu -i -p clipboard \
    | cliphist decode \
    | wl-copy
