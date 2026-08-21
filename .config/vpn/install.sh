#!/usr/bin/env bash
# One-time system setup for the vpn module. Re-running it is harmless.
#
# Installs:
#   /etc/systemd/system/vpn-tun.service   system-wide tunnel (sing-box, TUN)
#   /etc/polkit-1/rules.d/49-vpn-tun.rules  lets $USER start/stop it without a password
#   /etc/vpn                              config drop-dir, writable by $USER
#   ~/.config/systemd/user/vpn-proxy.service        socks/http-only fallback
#   ~/.config/systemd/user/vpn-subs-update.{service,timer}  subscription refresh
set -euo pipefail

VPN_USER="${SUDO_USER:-$USER}"
VPN_HOME="$(getent passwd "$VPN_USER" | cut -d: -f6)"
USER_UNITS="$VPN_HOME/.config/systemd/user"

if [ "$(id -u)" -ne 0 ]; then
    echo "re-running with sudo..."
    exec sudo -- "$0" "$@"
fi

command -v sing-box >/dev/null || { echo "sing-box is not installed" >&2; exit 1; }
getent passwd sing-box >/dev/null || { echo "the sing-box system user is missing" >&2; exit 1; }

install -d -o "$VPN_USER" -g sing-box -m 2750 /etc/vpn

# --- system tunnel ---------------------------------------------------------
cat >/etc/systemd/system/vpn-tun.service <<'UNIT'
[Unit]
Description=VPN tunnel (sing-box, managed by vpnctl)
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target
StartLimitIntervalSec=60
StartLimitBurst=4

[Service]
User=sing-box
StateDirectory=vpn
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/sing-box -D /var/lib/vpn run -c /etc/vpn/config.json
Restart=on-failure
RestartSec=3s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
UNIT

# --- passwordless control for the desktop user -----------------------------
cat >/etc/polkit-1/rules.d/49-vpn-tun.rules <<RULES
// Let $VPN_USER toggle the VPN tunnel from waybar/rofi without a password
// prompt. Scoped to this one unit and to a local, active login session.
polkit.addRule(function (action, subject) {
    if (action.id !== "org.freedesktop.systemd1.manage-units") return;
    if (subject.user !== "$VPN_USER" || !subject.local || !subject.active) return;
    if (action.lookup("unit") !== "vpn-tun.service") return;

    var verb = action.lookup("verb");
    if (verb === "start" || verb === "stop" || verb === "restart") {
        return polkit.Result.YES;
    }
});
RULES

systemctl daemon-reload

# --- user services ---------------------------------------------------------
install -d -o "$VPN_USER" -g "$VPN_USER" "$USER_UNITS"

cat >"$USER_UNITS/vpn-proxy.service" <<'UNIT'
[Unit]
Description=VPN proxy (sing-box, socks/http on 127.0.0.1:2080)

[Service]
Type=simple
ExecStart=/usr/bin/sing-box -D %h/.local/state/vpn run -c %h/.local/state/vpn/config.json
Restart=on-failure
RestartSec=3s
UNIT

cat >"$USER_UNITS/vpn-subs-update.service" <<'UNIT'
[Unit]
Description=Refresh VPN subscriptions

[Service]
Type=oneshot
ExecStart=%h/.config/vpn/vpnctl sub update --all --stale-only --quiet
UNIT

cat >"$USER_UNITS/vpn-subs-update.timer" <<'UNIT'
[Unit]
Description=Refresh VPN subscriptions periodically

[Timer]
OnStartupSec=2min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
UNIT

chown "$VPN_USER:$VPN_USER" "$USER_UNITS"/vpn-*.service "$USER_UNITS"/vpn-*.timer

runuser -u "$VPN_USER" -- systemctl --user daemon-reload || true
runuser -u "$VPN_USER" -- systemctl --user enable --now vpn-subs-update.timer || true

cat <<DONE

vpn setup complete.

  tun mode    system-wide, no password prompt (polkit rule for $VPN_USER)
  proxy mode  socks/http on 127.0.0.1:2080, no root needed
  auto-update hourly timer, refreshing subs older than \`vpnctl autoupdate\` hours

Next: add a subscription with

  ~/.config/vpn/menu.sh add

DONE
