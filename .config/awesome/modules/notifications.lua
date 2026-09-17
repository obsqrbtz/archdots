-- naughty is the notification daemon here; dunst stays sway's.
-- Top right under the bar, flat, same palette as everything else.

local naughty   = require("naughty")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi

local c = beautiful.colors

naughty.config.padding = beautiful.useless_gap * 2
naughty.config.spacing = beautiful.notification_spacing

naughty.config.defaults.timeout      = 6
naughty.config.defaults.position     = "top_right"
naughty.config.defaults.margin       = beautiful.notification_margin
naughty.config.defaults.icon_size    = beautiful.notification_icon_size
naughty.config.defaults.border_width = beautiful.notification_border_width

naughty.config.presets.low.timeout = 4
naughty.config.presets.normal.border_color = c.surface3
naughty.config.presets.low.border_color    = c.surface3
naughty.config.presets.critical = {
    bg           = c.surface,
    fg           = c.fg,
    border_color = c.error,
    timeout      = 0,
}

naughty.config.notify_callback = function(args)
    args.width = args.width or beautiful.notification_width
    args.max_width = dpi(420)
    return args
end

local M = {}

function M.toggle()
    if naughty.is_suspended() then
        naughty.resume()
        naughty.notify({ title = "Notifications", text = "resumed", timeout = 2 })
    else
        naughty.notify({ title = "Notifications", text = "paused", timeout = 2 })
        naughty.suspend()
    end
    awesome.emit_signal("widget::dnd")
end

awesome.connect_signal("notifications::toggle", M.toggle)

return M
