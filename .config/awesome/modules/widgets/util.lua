-- Building blocks for the bar: flat rectangles with a muted label and a
-- value, in the spirit of `VOL 32%`.

local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi

local M = {}

function M.span(text, color, font)
    return string.format('<span foreground="%s"%s>%s</span>',
        color, font and (' font="' .. font .. '"') or "",
        gears.string.xml_escape(tostring(text)))
end

function M.block(widget, args)
    args = args or {}
    return wibox.widget {
        {
            widget,
            left   = args.pad or beautiful.block_pad,
            right  = args.pad or beautiful.block_pad,
            widget = wibox.container.margin,
        },
        bg     = args.bg or beautiful.block_bg,
        fg     = args.fg or beautiful.fg_normal,
        widget = wibox.container.background,
    }
end

-- Returns the block and the value textbox to update.
function M.labeled(label, args)
    local value = wibox.widget.textbox()
    local block = M.block(wibox.widget {
        { markup = M.span(label, beautiful.colors.muted), widget = wibox.widget.textbox },
        value,
        spacing = dpi(7),
        layout  = wibox.layout.fixed.horizontal,
    }, args)
    return block, value
end

-- Swap background on hover so clickable blocks read as clickable.
function M.hover(w, normal, hovered)
    normal  = normal  or beautiful.block_bg
    hovered = hovered or beautiful.colors.surface2
    w:connect_signal("mouse::enter", function() w.bg = hovered end)
    w:connect_signal("mouse::leave", function() w.bg = normal end)
    return w
end

function M.read_file(path)
    local f = io.open(path)
    if not f then return nil end
    local s = f:read("*a")
    f:close()
    return s
end

return M
