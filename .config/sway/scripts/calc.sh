#!/usr/bin/env bash
set -euo pipefail

# rofi-calc (libqalculate) -- Enter copies the result to the clipboard.
rofi -show calc -modes calc \
    -theme ~/.config/rofi/calc.rasi \
    -no-show-match \
    -no-sort \
    -calc-command 'printf "%s" "{result}" | wl-copy'
