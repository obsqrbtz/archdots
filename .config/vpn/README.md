# vpn

Subscription-driven sing-box VPN setup for the sway/waybar.

```
vpnctl      the engine: subscriptions, config generation, service control, ping
menu.sh     the rofi front-end
install.sh  one-time system setup (systemd units + polkit rule)
```

## Install

```bash
~/.config/vpn/install.sh
~/.config/vpn/menu.sh add     # paste a subscription url
```

## Using it

| where | action |
| --- | --- |
| waybar, left click | open the menu |
| waybar, right click | toggle on/off |
| waybar, middle click | jump straight to the node picker |
| `$mod+Shift+v` | open the menu |
| `$mod+Ctrl+v` | toggle on/off |

## Routing rules

Off by default: everything goes through the tunnel. Turn it on and the rules in
`rules.json` are applied instead.

```bash
vpnctl routing            # on / off
vpnctl routing toggle     # also on the rofi menu as "routing: off"
vpnctl routing --list     # what would apply
```

`rules.json`:

```json
{
  "rules": [
    { "name": "ads",    "action": "block",  "category": ["category-ads-all"] },
    { "name": "home",   "action": "direct", "category": ["category-ru"], "geoip": ["ru"] },
    { "name": "work",   "action": "proxy",  "domain": ["github.com"] },
    { "name": "p2p",    "action": "direct", "protocol": ["bittorrent"] }
  ]
}
```

`action` is `direct`, `proxy` or `block`. Matchers:

| field | matches | example |
| --- | --- | --- |
| `domain` | a domain and everything under it | `["github.com", ".only-subs.net"]` |
| `ip` | an address or CIDR block | `["8.8.8.8", "10.0.0.0/8"]` |
| `category` | a geosite list | `["category-ru", "category-ads-all"]` |
| `geoip` | a geoip list | `["ru"]` |
| `protocol` | a sniffed protocol | `["bittorrent", "quic"]` |

### Naming a category

`category` and `geoip` names must match the upstream list exactly. Country
umbrella lists are `category-<cc>` on the geosite side but a bare `<cc>` on the geoip side.

Browse the full lists at
[sing-geosite](https://github.com/SagerNet/sing-geosite/tree/rule-set) and
[sing-geoip](https://github.com/SagerNet/sing-geoip/tree/rule-set).

### IPv6 and the direct path

The tun device advertises IPv6 regardless of whether the uplink has any. So when no IPv6 uplink is detected, `vpnctl` compiles direct rules with:

- `"strategy": "ipv4_only"` on their DNS mirrors, so those names resolve A-only
- `"ip_version": 4` on their route rules, so an IPv6 destination that slipped
  past the resolver falls through to the proxy rather than failing outright

Both disappear automatically on a machine with real IPv6.

## Reverting

```bash
sudo systemctl disable --now vpn-tun.service
systemctl --user disable --now vpn-subs-update.timer
sudo rm -f /etc/systemd/system/vpn-tun.service /etc/polkit-1/rules.d/49-vpn-tun.rules
sudo rm -rf /etc/vpn
rm -f ~/.config/systemd/user/vpn-*.{service,timer}
rm -rf ~/.local/state/vpn
sudo systemctl daemon-reload
```
