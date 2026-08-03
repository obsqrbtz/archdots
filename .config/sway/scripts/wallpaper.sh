#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="${WALL_DIR:-$HOME/Pictures/walls}"
STATE="$HOME/.cache/sway/wallpaper"
MODE="${SWAYBG_MODE:-fill}"

list_walls() {
    find -L "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) \
        -printf '%f\n' 2>/dev/null | sort
}

apply() {
    local wall="$1"
    [ -f "$wall" ] || return 1

    mkdir -p "$(dirname "$STATE")"
    printf '%s\n' "$wall" >"$STATE"

    pkill -x swaybg 2>/dev/null || true
    swaybg -i "$wall" -m "$MODE" >/dev/null 2>&1 &
    disown
}

case "${1:-pick}" in
restore)
    wall=""
    [ -s "$STATE" ] && wall="$(cat "$STATE")"
    if [ ! -f "$wall" ]; then
        name="$(list_walls | shuf -n1 || true)"
        [ -n "$name" ] && wall="$WALL_DIR/$name"
    fi
    apply "$wall" || exit 0
    ;;
random)
    name="$(list_walls | shuf -n1 || true)"
    [ -n "$name" ] && apply "$WALL_DIR/$name"
    ;;
pick)
    name="$(list_walls | rofi -dmenu -i -p wallpaper)" || exit 0
    [ -n "$name" ] && apply "$WALL_DIR/$name"
    ;;
*)
    echo "usage: ${0##*/} [restore|pick|random]" >&2
    exit 1
    ;;
esac
