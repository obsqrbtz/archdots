#!/usr/bin/env bash
# X11 twin of ~/.config/sway/scripts/screenshot.sh, on flameshot.
# usage: screenshot.sh screen | region | window WxH+X+Y
set -euo pipefail

DIR="${XDG_SCREENSHOTS_DIR:-$HOME/Pictures/scrots}"
case "$DIR" in
"~") DIR="$HOME" ;;
"~"/*) DIR="$HOME/${DIR#\~/}" ;;
esac
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y%m%d_%Hh%Mm%Ss)_flameshot.png"

case "${1:-region}" in
screen)
    flameshot screen -c -p "$FILE"
    ;;
region)
    # flameshot notifies on its own and handles cancel
    exec flameshot gui -c -p "$DIR"
    ;;
window)
    flameshot screen -c -p "$FILE" --region "${2:?window geometry}"
    ;;
*)
    echo "usage: ${0##*/} [screen|region|window WxH+X+Y]" >&2
    exit 1
    ;;
esac

[ -f "$FILE" ] && notify-send -a screenshot "Screenshot saved" "${FILE/#$HOME/\~}"
