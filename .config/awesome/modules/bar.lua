-- Top bar: flat blocks on the base color.
--
--   [arch] [1 2 3] [tile] title         [Thu 17 Sep  20:14]        [media] [cpu] [mem] [vol] [kb] [tray] [power]

local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local dpi       = require("beautiful.xresources").apply_dpi

local cfg       = require("config")
local util      = require("modules.widgets.util")
local sysinfo   = require("modules.widgets.sysinfo")
local taglist   = require("modules.widgets.taglist")
local layouts   = require("modules.layouts")
local powermenu = require("modules.powermenu")

local c = beautiful.colors

local function icon(cp, color)
    return wibox.widget {
        markup = util.span(utf8.char(cp), color, beautiful.font_icon),
        align  = "center",
        widget = wibox.widget.textbox,
    }
end

local function launcher()
    local w = util.block(icon(0xF303, c.on_accent), { bg = c.accent, pad = dpi(11) })
    w:buttons(awful.button({}, 1, function() awful.spawn(cfg.launcher) end))
    return util.hover(w, c.accent, c.accent2)
end

local function layoutbox(s)
    local value = wibox.widget.textbox()
    local w = util.block(value)
    local function update()
        local l = awful.layout.get(s)
        value.markup = util.span(layouts.name(l), l == awful.layout.suit.floating and c.warning or c.muted)
    end
    tag.connect_signal("property::layout", update)
    tag.connect_signal("property::selected", update)
    update()
    w:buttons(gears.table.join(
        awful.button({}, 1, function() awesome.emit_signal("tag::toggle_floating") end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(-1) end),
        awful.button({}, 5, function() awful.layout.inc( 1) end)
    ))
    return util.hover(w)
end

-- Focused window title, plain text on the bar background
local function title(s)
    local w = wibox.widget {
        widget = wibox.widget.textbox,
        forced_width = dpi(420),
    }
    local function update()
        local cl = client.focus
        if cl and cl.screen == s then
            w.markup = util.span(cl.name or cl.class or "", c.muted)
        else
            w.markup = ""
        end
    end
    client.connect_signal("focus", update)
    client.connect_signal("unfocus", update)
    client.connect_signal("property::name", function(cl) if cl == client.focus then update() end end)
    tag.connect_signal("property::selected", update)
    return wibox.container.margin(w, dpi(8), 0)
end

-- Shown while a keygrabber mode (resize) is active
local function mode()
    local value = wibox.widget.textbox()
    local w = util.block(value, { bg = c.warning })
    w.visible = false
    awesome.connect_signal("mode::changed", function(name)
        w.visible = name ~= nil
        value.markup = util.span(name or "", c.on_accent, beautiful.font_bold)
    end)
    return w
end

-- Shown while notifications are paused (Super+Shift+N)
local function dnd()
    local w = util.block(icon(0xF009B, c.warning))
    w.visible = false
    awesome.connect_signal("widget::dnd", function() w.visible = naughty.is_suspended() end)
    w:buttons(awful.button({}, 1, function() awesome.emit_signal("notifications::toggle") end))
    return util.hover(w)
end

local calendar
local function clock(s)
    local w = util.block(wibox.widget.textclock(
        util.span("%a %d %b", c.muted) .. "  " .. util.span("%H:%M", c.fg, beautiful.font_bold), 15))
    if not calendar then
        calendar = awful.widget.calendar_popup.month {
            start_sunday = false,
            long_weekdays = false,
            margin = dpi(8),
            style_month = { padding = dpi(12), border_width = dpi(1), border_color = c.surface3 },
        }
        awesome.connect_signal("calendar::toggle", function()
            calendar:call_calendar(0, "tc", awful.screen.focused())
            calendar.visible = not calendar.visible
        end)
    end
    w:buttons(awful.button({}, 1, function() awesome.emit_signal("calendar::toggle") end))
    return util.hover(w)
end

local function tray()
    local st = wibox.widget.systray()
    st.base_size = dpi(16)
    local w = util.block(wibox.container.place(st), { pad = dpi(8) })
    -- Hide the empty block when nothing is docked
    gears.timer {
        timeout = 2, autostart = true, call_now = true,
        callback = function() w.visible = awesome.systray() > 0 end,
    }
    return w
end

local function power()
    local w = util.block(icon(0xF0425, c.error), { pad = dpi(11) })
    w:buttons(awful.button({}, 1, function() powermenu.open() end))
    return util.hover(w)
end

-- One copy of each shared (non-screen) widget; the systray can only live once
local shared

return function(s)
    shared = shared or {
        media = sysinfo.media(),
        cpu   = sysinfo.cpu(),
        mem   = sysinfo.mem(),
        vol   = sysinfo.volume(),
        kb    = sysinfo.keyboard(),
        dnd   = dnd(),
        tray  = tray(),
        power = power(),
    }

    s.bar = awful.wibar {
        screen   = s,
        position = "top",
        height   = beautiful.bar_height,
        bg       = c.bg,
        fg       = c.fg,
    }

    local right = s == screen.primary and {
        shared.media, shared.dnd, shared.cpu, shared.mem, shared.vol, shared.kb, shared.tray, shared.power,
        spacing = beautiful.block_spacing,
        layout  = wibox.layout.fixed.horizontal,
    } or nil

    s.bar:setup {
        {
            {
                launcher(),
                taglist(s),
                layoutbox(s),
                mode(),
                title(s),
                spacing = beautiful.block_spacing,
                layout  = wibox.layout.fixed.horizontal,
            },
            clock(s),
            right,
            expand = "none",
            layout = wibox.layout.align.horizontal,
        },
        left   = dpi(10),
        right  = dpi(10),
        top    = beautiful.bar_padding,
        bottom = beautiful.bar_padding,
        widget = wibox.container.margin,
    }
end
