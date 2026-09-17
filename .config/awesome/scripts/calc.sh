#!/usr/bin/env bash
set -euo pipefail

# rofi-calc (libqalculate) -- Enter copies the result when xclip is installed.
copy='true'
command -v xclip >/dev/null && copy='printf "%s" "{result}" | xclip -selection clipboard'

rofi -show calc -modes calc \
    -theme ~/.config/rofi/calc.rasi \
    -no-show-match \
    -no-sort \
    -calc-command "$copy"
