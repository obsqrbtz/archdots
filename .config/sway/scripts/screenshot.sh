#!/usr/bin/env bash
set -euo pipefail

DIR="${XDG_SCREENSHOTS_DIR:-$HOME/Pictures/scrots}"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y%m%d_%Hh%Mm%Ss)_grim.png"

case "${1:-region}" in
screen)
    output="$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')"
    grim -o "$output" "$FILE"
    ;;
region)
    geom="$(slurp)" || exit 0
    grim -g "$geom" "$FILE"
    ;;
window)
    geom="$(swaymsg -t get_tree \
        | jq -r '.. | select(.focused? == true) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' \
        | head -n1)"
    grim -g "$geom" "$FILE"
    ;;
*)
    echo "usage: ${0##*/} [screen|region|window]" >&2
    exit 1
    ;;
esac

wl-copy <"$FILE"
notify-send -a screenshot "Screenshot saved" "${FILE/#$HOME/\~}"
