#!/usr/bin/env bash
# Xorg picks 60Hz by default. Run every connected output at its preferred
# resolution and the highest refresh rate available for it
# (sway's 10-output.conf does this for HDMI-A-2 at 1920x1080@100).
set -euo pipefail

xrandr --query | awk '
    / connected/          { out = $1; pref = ""; next }
    /^[^ ]/               { out = ""; next }
    out && pref == "" && /\+/ {
        pref = $1; best = 0
        for (i = 2; i <= NF; i++) { r = $i; gsub(/[*+]/, "", r); if (r + 0 > best + 0) best = r }
        print out, pref, best
    }
' | while read -r out mode rate; do
    xrandr --output "$out" --mode "$mode" --rate "$rate"
done
