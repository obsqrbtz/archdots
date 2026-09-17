-- awesome
-- https://awesomewm.org/doc/api/
--
-- Split across modules/, loaded below in order:
--   errors  env  theme  layouts  screens  rules  titlebars  notifications
--   keys  autostart
--
-- Settings shared by every module (apps, tags, paths) live in config.lua.

pcall(require, "luarocks.loader")

local gears     = require("gears")
local beautiful = require("beautiful")
require("awful.autofocus")

local cfg = require("config")

require("modules.errors")
require("modules.env")

beautiful.init(cfg.dir .. "theme/theme.lua")

require("modules.layouts")
require("modules.screens")
require("modules.rules")
require("modules.titlebars")
require("modules.notifications")
require("modules.keys")
require("modules.autostart")

-- Sloppy focus, like sway's focus_follows_mouse
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus  end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Newly spawned windows go below the focused one, not at master
client.connect_signal("manage", function(c)
    if awesome.startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            require("awful").placement.no_offscreen(c)
        end
    else
        require("awful").client.setslave(c)
    end
end)

gears.timer.start_new(10, function() collectgarbage("step", 20000) return true end)
