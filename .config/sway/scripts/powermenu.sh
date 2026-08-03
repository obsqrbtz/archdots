#!/usr/bin/env bash
set -euo pipefail

entries="lock\nlogout\nsuspend\nhibernate\nreboot\nshutdown"
command -v swaylock >/dev/null || entries="${entries/lock\\n/}"

choice="$(printf '%b' "$entries" | rofi -dmenu -i -p power -l 6)" || exit 0

case "$choice" in
lock)      swaylock -f -c 111111 ;;
logout)    swaymsg exit ;;
suspend)   systemctl suspend ;;
hibernate) systemctl hibernate ;;
reboot)    systemctl reboot ;;
shutdown)  systemctl poweroff ;;
esac
