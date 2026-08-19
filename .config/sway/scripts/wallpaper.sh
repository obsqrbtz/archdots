#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="${WALL_DIR:-$HOME/Pictures/walls/desktop}"
STATE="$HOME/.cache/sway/wallpaper"
THUMB_DIR="${WALL_THUMB_DIR:-$HOME/.cache/sway/thumbs}"
THUMB_GEOM="${WALL_THUMB_GEOM:-320x180}"
PICKER_THEME="$HOME/.config/rofi/wallpaper.rasi"
MODE="${SWAYBG_MODE:-fill}"

list_walls() {
    find -L "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) \
        -printf '%f\n' 2>/dev/null | sort
}

thumb_of() {
    printf '%s/%s.jpg\n' "$THUMB_DIR" "$(printf '%s' "$1" | sha1sum | cut -d' ' -f1)"
}

make_thumb() {
    local src="$1" dst tmp
    dst="$(thumb_of "$src")"
    [ -f "$dst" ] && [ "$dst" -nt "$src" ] && return 0

    mkdir -p "$THUMB_DIR"
    tmp="$dst.$$.tmp"
    if magick -define jpeg:size=640x640 "$src" -delete 1--1 -auto-orient \
        -thumbnail "${THUMB_GEOM}^" -gravity center -extent "$THUMB_GEOM" \
        -quality 82 "jpg:$tmp" 2>/dev/null; then
        mv -f "$tmp" "$dst"
    else
        rm -f "$tmp"
        return 1
    fi
}

make_thumbs() {
    local walls="$1"
    printf '%s\n' "$walls" | while IFS= read -r name; do
        [ -n "$name" ] && printf '%s\0' "$WALL_DIR/$name"
    done | xargs -0 -r -P "$(nproc)" -n1 "$0" thumb
}

menu_rows() {
    local walls="$1" name src thumb
    printf '%s\n' "$walls" | while IFS= read -r name; do
        [ -n "$name" ] || continue
        src="$WALL_DIR/$name"
        thumb="$(thumb_of "$src")"
        [ -f "$thumb" ] || thumb="$src"
        printf '%s\0icon\x1f%s\n' "$name" "$thumb"
    done
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
    walls="$(list_walls)"
    [ -n "$walls" ] || exit 0
    make_thumbs "$walls"

    row=0
    if [ -s "$STATE" ]; then
        current="$(basename "$(cat "$STATE")")"
        n="$(printf '%s\n' "$walls" | grep -nxF -- "$current" | cut -d: -f1 | head -1 || true)"
        [ -n "$n" ] && row=$((n - 1))
    fi

    name="$(menu_rows "$walls" |
        rofi -dmenu -i -p wallpaper -show-icons -no-hover-select \
            -theme "$PICKER_THEME" -selected-row "$row")" || exit 0
    [ -n "$name" ] && apply "$WALL_DIR/$name"
    ;;
thumbs)
    make_thumbs "$(list_walls)"
    ;;
thumb)
    make_thumb "${2:-}" || true
    ;;
*)
    echo "usage: ${0##*/} [restore|pick|random|thumbs]" >&2
    exit 1
    ;;
esac
