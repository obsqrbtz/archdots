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
