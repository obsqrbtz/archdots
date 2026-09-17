-- Autostart. Port of ~/.config/sway/config.d/60-autostart.conf.
-- Session setup runs on every (re)start; apps only when not already running,
-- so Super+Shift+C doesn't spawn duplicates.
-- AWESOME_NO_AUTOSTART=1 skips all of it (for testing in a nested X server).

local awful = require("awful")
local gears = require("gears")

local cfg = require("config")
local env = require("modules.env")

if os.getenv("AWESOME_NO_AUTOSTART") then return end

local home = os.getenv("HOME")
local user = os.getenv("USER")

-- Input and outputs
local xkb = { "setxkbmap", "-layout", cfg.xkb_layout, "-option", "" }
if cfg.xkb_options ~= "" then
    table.insert(xkb, "-option")
    table.insert(xkb, cfg.xkb_options)
end
awful.spawn(xkb)
awful.spawn({ "xrdb", "-merge", home .. "/.Xresources" })
awful.spawn(cfg.scripts .. "displays.sh")

-- Hand the X11 environment to systemd/dbus-activated services, and drop
-- whatever a previous sway session left there
local names = { "DISPLAY", "XAUTHORITY" }
for k in pairs(env.vars) do table.insert(names, k) end

awful.spawn.easy_async(
    gears.table.join({ "systemctl", "--user", "unset-environment" }, env.wayland_only),
    function()
        awful.spawn.easy_async(gears.table.join({ "dbus-update-activation-environment", "--systemd" }, names),
            function()
                for _, cmd in ipairs(cfg.autostart) do
                    local bin = cmd:match("^(%S+)")
                    awful.spawn.easy_async({ "pgrep", "-u", user, "-f", bin }, function(_, _, _, code)
                        if code ~= 0 then awful.spawn(cmd, false) end
                    end)
                end
            end)
    end)
