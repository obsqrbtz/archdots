#!/usr/bin/env bash
# rofi front-end for vpnctl.
set -euo pipefail

VPNCTL="$(dirname "$(readlink -f "$0")")/vpnctl"

notify() {
    notify-send -a vpn -t "${2:-3000}" vpn "$1" 2>/dev/null || true
}

mesg() {
    "$VPNCTL" status --line
}

pick() {
    rofi -dmenu -i "$@"
}

prompt_text() {
    rofi -dmenu -i -p "$1" -l 0 -format f -filter "${2:-}" \
        -kb-accept-entry "" -kb-accept-custom "Return,KP_Enter" </dev/null
}

report() {
    local out
    if out="$("$VPNCTL" "$@" 2>&1)"; then
        notify "${out:-done}"
    else
        notify "${out:-failed}" 6000
    fi
}

# --------------------------------------------------------------- nodes ----

node_menu() {
    local sub_id="$1" ids rows choice rc node_id
    choice=0

    while true; do
        # --rofi and --json list the same nodes in the same order, so the row
        # index rofi hands back indexes the id list too.
        ids="$("$VPNCTL" nodes "$sub_id" --json | jq -r '.[].id')"
        rows="$("$VPNCTL" nodes "$sub_id" --rofi)"
        if [ -z "$rows" ]; then
            notify "that subscription has no nodes"
            return
        fi

        set +e
        # -selected-row keeps your place when alt+p / alt+u redraw the list
        choice="$(printf '%s\n' "$rows" | pick -p node -format i -l 15 \
            -mesg "$(mesg)   ·   alt+p ping   alt+u update" \
            -selected-row "${choice:-0}" \
            -kb-custom-1 "Alt+p" -kb-custom-2 "Alt+u")"
        rc=$?
        set -e

        case $rc in
        0)
            [ -n "$choice" ] || return
            node_id="$(sed -n "$((choice + 1))p" <<<"$ids")"
            report use "$node_id" --sub "$sub_id" --connect
            return
            ;;
        10)
            notify "pinging nodes..." 1500
            "$VPNCTL" ping "$sub_id" >/dev/null 2>&1 || notify "ping failed"
            ;;
        11)
            notify "updating subscription..." 1500
            report sub update "$sub_id"
            ;;
        *) return ;;
        esac
    done
}

# Two-step picker: subscription first, then a node inside it.
sub_picker() {
    local ids rows choice rc

    ids="$("$VPNCTL" sub list --json | jq -r '.[].id')"
    rows="$("$VPNCTL" sub list --rofi)"
    if [ -z "$rows" ]; then
        notify "no subscriptions imported yet"
        sub_add
        return
    fi

    set +e
    choice="$(printf '%s\n' "$rows" | pick -p subscription -format i -l 10 -mesg "$(mesg)")"
    rc=$?
    set -e
    [ $rc -eq 0 ] && [ -n "${choice:-}" ] || return

    node_menu "$(sed -n "$((choice + 1))p" <<<"$ids")"
}

# ------------------------------------------------------- subscriptions ----

sub_add() {
    local clip url

    # prefill with the clipboard when it already holds a subscription link
    clip="$(wl-paste -n 2>/dev/null || true)"
    [[ "$clip" =~ ^https?:// ]] || clip=""

    set +e
    url="$(prompt_text "sub url" "$clip")"
    set -e
    [ -n "${url:-}" ] || return

    notify "importing subscription..." 1500
    report sub add "$url"
}

sub_actions() {
    local sub_id="$1" name="$2" choice new confirm

    set +e
    choice="$(printf '%s\n' nodes update rename remove back \
        | pick -p "$name" -l 5 -mesg "$(mesg)")"
    set -e

    case "${choice:-}" in
    nodes) node_menu "$sub_id" ;;
    update)
        notify "updating $name..." 1500
        report sub update "$sub_id"
        ;;
    rename)
        set +e
        new="$(prompt_text "new name" "$name")"
        set -e
        [ -n "${new:-}" ] && report sub rename "$sub_id" "$new"
        ;;
    remove)
        set +e
        confirm="$(printf '%s\n' no yes | pick -p "remove $name?" -l 2)"
        set -e
        [ "${confirm:-no}" = yes ] && report sub remove "$sub_id"
        ;;
    esac
}

sub_manager() {
    local ids names rows choice rc idx

    while true; do
        ids="$("$VPNCTL" sub list --json | jq -r '.[].id')"
        names="$("$VPNCTL" sub list --json | jq -r '.[].name')"
        rows="$("$VPNCTL" sub list --rofi)"

        set +e
        choice="$(printf '%s\n' "+ add subscription" "↻ update all" ${rows:+"$rows"} \
            | pick -p subs -format i -l 12 -mesg "$(mesg)")"
        rc=$?
        set -e
        [ $rc -eq 0 ] && [ -n "${choice:-}" ] || return

        case "$choice" in
        0) sub_add ;;
        1)
            notify "updating subscriptions..." 1500
            report sub update --all
            ;;
        *)
            idx=$((choice - 1))
            sub_actions "$(sed -n "${idx}p" <<<"$ids")" "$(sed -n "${idx}p" <<<"$names")"
            ;;
        esac
    done
}

# ----------------------------------------------------------- main menu ----

main_menu() {
    local status connected mode rows choice other

    while true; do
        status="$("$VPNCTL" status --json)"
        connected="$(jq -r .connected <<<"$status")"
        mode="$(jq -r .configured_mode <<<"$status")"

        [ "$connected" = true ] && rows="disconnect" || rows="connect"
        rows="$rows
nodes
subscriptions
ping
update
check
mode: $mode
logs"

        set +e
        choice="$(printf '%s\n' "$rows" | pick -p vpn -l 8 -mesg "$(mesg)")"
        set -e
        [ -n "${choice:-}" ] || return

        case "$choice" in
        connect)
            report up
            return
            ;;
        disconnect)
            report down
            return
            ;;
        nodes)
            sub_picker
            return
            ;;
        subscriptions) sub_manager ;;
        ping)
            notify "pinging nodes..." 1500
            report ping
            ;;
        update)
            notify "updating subscriptions..." 1500
            report sub update --all
            ;;
        check)
            notify "testing connection..." 1500
            report check
            ;;
        "mode: $mode")
            [ "$mode" = tun ] && other=proxy || other=tun
            report mode "$other"
            ;;
        logs)
            if [ "$mode" = tun ]; then
                setsid ghostty -e journalctl -u vpn-tun.service -n 100 -f >/dev/null 2>&1 &
            else
                setsid ghostty -e journalctl --user -u vpn-proxy.service -n 100 -f >/dev/null 2>&1 &
            fi
            return
            ;;
        esac
    done
}

setsid "$VPNCTL" sub update --all --stale-only --quiet >/dev/null 2>&1 &

case "${1:-menu}" in
menu)  main_menu ;;
nodes) sub_picker ;;
subs)  sub_manager ;;
add)   sub_add ;;
*)     echo "usage: ${0##*/} [menu|nodes|subs|add]" >&2; exit 1 ;;
esac
