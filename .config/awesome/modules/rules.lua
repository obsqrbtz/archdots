-- Window rules. Port of ~/.config/sway/config.d/40-rules.conf; X11 class
-- names where sway used Wayland app_ids. Patterns are Lua patterns.
-- Inspect a window with: xprop WM_CLASS WM_NAME WM_WINDOW_ROLE

local awful     = require("awful")
local beautiful = require("beautiful")

local keys = require("modules.keys.client")

-- New floating windows: centered when alone, else the first free spot.
-- Both keep clear of the bar and screen padding.
local function place(c)
    local args = { honor_workarea = true, honor_padding = true, margins = beautiful.useless_gap * 2 }
    for _, other in ipairs(c.screen.clients) do
        if other ~= c and other:isvisible() then
            return (awful.placement.no_overlap + awful.placement.no_offscreen)(c, args)
        end
    end
    return awful.placement.centered(c, args)
end

local function sized(w, h)
    return function(c)
        local wa = c.screen.workarea
        c:geometry({ width = math.floor(wa.width * w), height = math.floor(wa.height * h) })
        awful.placement.centered(c, { honor_workarea = true })
    end
end

awful.rules.rules = {
    { rule = {},
      properties = {
          border_width = beautiful.border_width,
          border_color = beautiful.border_normal,
          focus        = awful.client.focus.filter,
          raise        = true,
          keys         = keys.keys,
          buttons      = keys.buttons,
          screen       = awful.screen.preferred,
          placement    = place,
          size_hints_honor = false,
      } },

    -- Generic dialogs
    { rule_any = {
          type = { "dialog", "splash", "menu" },
          role = { "pop%-up", "bubble", "dialog", "task_dialog" },
      },
      properties = { floating = true, placement = awful.placement.centered } },

    { rule_any = { name = {
          "^Open File", "^Open Folder", "^Save As", "^Select a File", "^Choose wallpaper",
          "^Library$", "^File Upload", "wants to save$", "wants to open$", "Welcome$",
      } },
      properties = { floating = true, placement = awful.placement.centered } },

    -- Floating utilities
    { rule_any = { class = { "^[Pp]avucontrol$", "^org%.pulseaudio%.pavucontrol$", "^Nm%-connection%-editor$", "^Zotero$" } },
      properties = { floating = true },
      callback = sized(0.45, 0.45) },

    { rule_any = {
          class    = { "^[Bb]lueberry%.py$", "^[Bb]lueman%-manager$", "^guifetch$", "bluedevilwizard$" },
          instance = { "^kcm_" },
      },
      properties = { floating = true, placement = awful.placement.centered } },

    -- Screenshot overlay
    { rule = { class = "flameshot" },
      properties = { floating = true, ontop = true, border_width = 0, no_titlebar = true,
                     fullscreen = false, x = 0, y = 0 } },

    -- Picture-in-Picture
    { rule_any = { name = { "^[Pp]icture.?[Ii]n.?[Pp]icture" } },
      properties = { floating = true, sticky = true, ontop = true },
      callback = function(c)
          local wa = c.screen.workarea
          c:geometry({ width = math.floor(wa.width * 0.25), height = math.floor(wa.height * 0.25) })
          awful.placement.bottom_right(c, { honor_workarea = true, margins = beautiful.useless_gap * 4 })
      end },

    -- Dolphin's copy dialog insists on being in the way
    { rule = { name = "^Copying — Dolphin$" },
      properties = { floating = true, x = 40, y = 80 } },
}
