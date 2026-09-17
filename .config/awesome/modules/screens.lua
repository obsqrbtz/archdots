-- Per-screen setup: tags, wallpaper, bar.

local awful     = require("awful")
local beautiful = require("beautiful")

local cfg       = require("config")
local wallpaper = require("modules.wallpaper")
local bar       = require("modules.bar")

screen.connect_signal("property::geometry", wallpaper.apply)

awful.screen.connect_for_each_screen(function(s)
    wallpaper.apply(s)

    for i, t in ipairs(cfg.tags) do
        awful.tag.add(t.name, {
            screen   = s,
            layout   = t.floating and awful.layout.suit.floating or awful.layout.layouts[1],
            selected = i == 1,
            gap_single_client = beautiful.gap_single_client,
        })
    end

    s.padding = beautiful.useless_gap

    bar(s)
end)
