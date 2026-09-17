-- Keyboard layout switching.
--
-- Alt+Shift cycles xkb groups. Debounced, because this keyboard sends every
-- modifier press twice (~16ms apart, once per USB interface); the echo would
-- otherwise switch straight back.

local awful = require("awful")
local gears = require("gears")
local GLib  = require("lgi").GLib
local kbl   = require("awful.widget.keyboardlayout")

local M = {}

function M.names()
    local names = {}
    for _, g in ipairs(kbl.get_groups_from_group_names(awesome.xkb_get_group_names()) or {}) do
        names[g.group_idx or (#names + 1)] = g.file
    end
    return names
end

function M.next()
    local n = math.max(#M.names(), 1)
    awesome.xkb_set_layout_group((awesome.xkb_get_layout_group() + 1) % n)
end

local last = 0
local function debounced_next()
    local now = GLib.get_monotonic_time()
    if now - last < 150000 then return end
    last = now
    M.next()
end

M.keys = gears.table.join(
    awful.key({ "Mod1" }, "Shift_L", debounced_next,
        { description = "switch keyboard layout", group = "session" }),
    awful.key({ "Mod1" }, "Shift_R", debounced_next),
    awful.key({ "Shift" }, "Alt_L", debounced_next),
    awful.key({ "Shift" }, "Alt_R", debounced_next)
)

return M
