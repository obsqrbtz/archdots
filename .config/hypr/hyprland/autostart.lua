-- Autostart
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg")
    hl.exec_cmd("/usr/bin/dbus-update-activation-environment --all")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("nm-applet -i")
    hl.exec_cmd("qs -c basedgoose.shell")
    hl.exec_cmd("kdeconnectd")
    hl.exec_cmd("~/.config/hypr/scripts/gtk.sh")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("flameshot")
    hl.exec_cmd("bitwarden-desktop")
end)
