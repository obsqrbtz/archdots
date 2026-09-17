-- Workspaces, sway-style: only occupied and focused tags are shown.
-- Floating tags carry a thin underline so you can tell them apart at a glance.

local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi

local c = beautiful.colors
local modkey = require("config").modkey

local function paint(self, t)
    local mark = self:get_children_by_id("float_mark")[1]
    local floating = t.layout == awful.layout.suit.floating
    mark.bg = not floating and "#00000000" or (t.selected and c.on_accent or c.warning)
end

local buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end)
)

return function(s)
    local list = awful.widget.taglist {
        screen  = s,
        filter  = function(t) return t.selected or t.urgent or #t:clients() > 0 end,
        buttons = buttons,
        layout  = { layout = wibox.layout.fixed.horizontal },
        widget_template = {
            {
                { wibox.widget.base.empty_widget(), forced_height = dpi(2), widget = wibox.container.background },
                {
                    {
                        id     = "text_role",
                        align  = "center",
                        widget = wibox.widget.textbox,
                    },
                    forced_width = dpi(34),
                    widget = wibox.container.place,
                },
                {
                    {
                        wibox.widget.base.empty_widget(),
                        id            = "float_mark",
                        forced_height = dpi(2),
                        widget        = wibox.container.background,
                    },
                    left   = dpi(9),
                    right  = dpi(9),
                    widget = wibox.container.margin,
                },
                layout = wibox.layout.align.vertical,
            },
            id     = "background_role",
            widget = wibox.container.background,
            create_callback = function(self, t) paint(self, t) end,
            update_callback = function(self, t) paint(self, t) end,
        },
    }

    -- The taglist doesn't watch layouts on its own.
    tag.connect_signal("property::layout", function(t)
        if t.screen == s then list._do_taglist_update() end
    end)

    return list
end
