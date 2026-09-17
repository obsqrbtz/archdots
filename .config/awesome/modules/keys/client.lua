-- Per-window keys and mouse bindings (attached through rules.lua).

local awful = require("awful")
local gears = require("gears")

local cfg        = require("config")
local scratchpad = require("modules.scratchpad")

local modkey = cfg.modkey

local M = {}

M.keys = gears.table.join(
    awful.key({ modkey }, "q", function(c) c:kill() end,
        { description = "close window", group = "session" }),

    awful.key({ modkey }, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, { description = "fullscreen", group = "layout" }),

    awful.key({ modkey, "Shift" }, "space", function(c)
        c.floating = not c.floating
        if c.floating then
            local wa = c.screen.workarea
            c:geometry({
                width  = math.min(c.width,  math.floor(wa.width  * 0.6)),
                height = math.min(c.height, math.floor(wa.height * 0.6)),
            })
            awful.placement.centered(c, { honor_workarea = true })
        end
        c:raise()
    end, { description = "floating toggle", group = "layout" }),

    awful.key({ modkey }, "p", function(c)
        c.sticky = not c.sticky
        c.ontop  = c.sticky and c.floating
    end, { description = "pin window (sticky)", group = "layout" }),

    awful.key({ modkey }, "x", function(c)
        c.maximized = not c.maximized
        c:raise()
    end, { description = "maximize", group = "layout" }),

    awful.key({ modkey, "Shift" }, "Return", function(c)
        c:swap(awful.client.getmaster())
    end, { description = "swap with master", group = "layout" }),

    awful.key({ modkey, "Shift" }, "s", function(c) scratchpad.send(c) end,
        { description = "send to scratchpad", group = "scratchpad" }),

    awful.key({ "Control" }, "Print", function(c)
        local g = c:geometry()
        awful.spawn({ cfg.screenshot, "window",
            string.format("%dx%d+%d+%d", g.width, g.height, g.x, g.y) })
    end, { description = "screenshot: focused window", group = "screenshots" })
)

-- sway's floating_modifier: Super+LMB drags, Super+RMB resizes
M.buttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end),
    awful.button({ modkey }, 4, function(c) awful.tag.viewprev(c.screen) end),
    awful.button({ modkey }, 5, function(c) awful.tag.viewnext(c.screen) end)
)

return M
