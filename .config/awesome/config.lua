-- Settings shared by every module. The sway equivalents are the `set $...`
-- variables at the top of ~/.config/sway/config.

local gfs = require("gears.filesystem")

local home = os.getenv("HOME")
local dir  = gfs.get_configuration_dir()

local cfg = {}

cfg.dir     = dir
cfg.scripts = dir .. "scripts/"

-- Applications
-- server: no GTK headerbar under X11 (sway gets this via xdg-decoration)
cfg.terminal    = "ghostty --window-decoration=server"
cfg.filemanager = "nautilus"
cfg.launcher    = "rofi -show drun"
cfg.runner      = "rofi -show run"
cfg.switcher    = "rofi -show window"
cfg.calculator  = cfg.scripts .. "calc.sh"
cfg.screenshot  = cfg.scripts .. "screenshot.sh"
cfg.monitor     = cfg.terminal .. " -e btop"
cfg.mixer       = "pavucontrol"
cfg.network     = "nm-connection-editor"
cfg.bluetooth   = "blueman-manager"
cfg.vpn_menu    = home .. "/.config/vpn/menu.sh"
cfg.vpn_toggle  = home .. "/.config/vpn/vpnctl toggle"
-- Left empty: nothing is installed. i3lock / xsecurelock / slock all work.
cfg.locker      = ""

cfg.modkey = "Mod4"

-- Keyboard: same layouts as sway's 20-input.conf. Alt+Shift switches them,
-- but through awesome (modules/keyboard.lua), not grp:alt_shift_toggle:
-- the SHINETEK board reports modifiers on two interfaces, so the XKB toggle
-- fires twice and cancels itself out.
cfg.xkb_layout  = "us,ru"
cfg.xkb_options = ""

-- Wallpaper: the one pywal last ran on, else a plain fill.
-- Super+W picks a new one from wallpaper_dir.
cfg.wallpaper_dir   = home .. "/Pictures/walls/desktop"
cfg.wallpaper_state = home .. "/.cache/awesome/wallpaper"
cfg.wallpaper_pywal = home .. "/.cache/wal/wal"

-- Workspaces. `floating = true` starts the tag in the classic floating
-- layout; Super+Shift+F flips any tag between tiling and floating at runtime.
cfg.tags = {
    { name = "1" }, { name = "2" }, { name = "3" }, { name = "4" },
    { name = "5" }, { name = "6" }, { name = "7" }, { name = "8" },
    { name = "9", floating = true },
    { name = "10", floating = true },
}

-- Autostart (run once per login, skipped on Super+Shift+C reload)
cfg.autostart = {
    "/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "udiskie",
    "kdeconnectd",
    "flameshot",
    "bitwarden-desktop",
    "seafile-applet",
}

return cfg
