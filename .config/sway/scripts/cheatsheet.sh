#!/usr/bin/env bash
set -euo pipefail

CONF="$HOME/.config/sway/config.d/50-keybinds.conf"

awk '
    /^[[:space:]]*#:[[:space:]]/ {
        sub(/^[[:space:]]*#:[[:space:]]*/, "")
        desc = $0
        next
    }
    /^[[:space:]]*bindsym / {
        if (desc != "") {
            key = $0
            sub(/^[[:space:]]*bindsym[[:space:]]+/, "", key)
            while (key ~ /^--[a-z-]+[[:space:]]/) sub(/^--[a-z-]+[[:space:]]+/, "", key)
            sub(/[[:space:]].*$/, "", key)
            print key "\t" desc
        }
        desc = ""
        next
    }
    { desc = "" }
' "$CONF" \
    | sed -E -e 's/\$mod/Super/g' \
             -e 's/\$left/h/; s/\$down/j/; s/\$up/k/; s/\$right/l/' \
    | column -t -s $'\t' \
    | rofi -dmenu -i -p keybinds -l 20 >/dev/null
