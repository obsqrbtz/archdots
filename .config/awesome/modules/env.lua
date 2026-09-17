-- Session environment. The X11 counterpart of ~/.config/sway/env: set here
-- so it works with the stock awesome.desktop session GDM ships, and is
-- inherited by everything awesome spawns.

local GLib = require("lgi").GLib

local env = {
    XDG_CURRENT_DESKTOP = "awesome",
    XDG_SESSION_DESKTOP = "awesome",

    EDITOR       = "nvim",
    XCURSOR_SIZE = "24",
    XDG_SCREENSHOTS_DIR = os.getenv("HOME") .. "/Pictures/scrots",
    XDG_MENU_PREFIX = "plasma-",

    QT_QPA_PLATFORMTHEME = "qt5ct",
    QT_STYLE_OVERRIDE    = "kvantum",
    QT_AUTO_SCREEN_SCALE_FACTOR = "1",

    _JAVA_AWT_WM_NONREPARENTING = "1",
}

for k, v in pairs(env) do
    GLib.setenv(k, v, true)
end

-- sway's autostart pushes its whole environment into systemd --user, which
-- outlives the session. Drop the Wayland-only bits so X11 apps (including
-- dbus-activated ones) don't try to use them. autostart.lua also clears
-- them from systemd.
local wayland_only = {
    "WAYLAND_DISPLAY", "SWAYSOCK", "GDK_BACKEND", "QT_QPA_PLATFORM",
    "QT_WAYLAND_DISABLE_WINDOWDECORATION", "SDL_VIDEODRIVER", "MOZ_ENABLE_WAYLAND",
    "MOZ_GTK_TITLEBAR_DECORATION", "ELECTRON_OZONE_PLATFORM_HINT",
}

for _, k in ipairs(wayland_only) do
    GLib.unsetenv(k)
end

return { vars = env, wayland_only = wayland_only }
