-- Titlebars only where windows float: on floating tags, or for windows
-- floated on a tiling tag. Tiled windows stay bare, as in sway.
--
--   title                                     ● ●
--                                    maximize ┘ └ close
--
-- Drag to move, right-drag to resize, double-click to maximize,
-- middle-click to close.

local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi
local GLib      = require("lgi").GLib

local c = beautiful.colors

local function dot(cl, color, action)
    local w = wibox.widget {
        wibox.widget.base.empty_widget(),
        forced_width  = dpi(11),
        forced_height = dpi(11),
        shape         = gears.shape.circle,
        widget        = wibox.container.background,
    }
    local hovered = false
    local function paint()
        if hovered then
            w.bg = color
        else
            w.bg = client.focus == cl and color .. "B0" or c.surface3
        end
    end
    w:connect_signal("mouse::enter", function() hovered = true  paint() end)
    w:connect_signal("mouse::leave", function() hovered = false paint() end)
    cl:connect_signal("focus",   paint)
    cl:connect_signal("unfocus", paint)
    w:buttons(awful.button({}, 1, function() action(cl) end))
    paint()
    return wibox.container.place(w)
end

local function build(cl)
    local last_click = 0
    local drag = gears.table.join(
        awful.button({}, 1, function()
            -- double click maximizes
            local now = GLib.get_monotonic_time()
            if now - last_click < 300000 then
                cl.maximized = not cl.maximized
                last_click = 0
                return
            end
            last_click = now
            cl:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(cl)
        end),
        awful.button({}, 2, function() cl:kill() end),
        awful.button({}, 3, function()
            cl:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(cl)
        end)
    )

    local title = awful.titlebar.widget.titlewidget(cl)
    title.font = beautiful.font

    awful.titlebar(cl, { size = beautiful.titlebar_height, position = "top" }):setup {
        {
            title,
            left    = dpi(12),
            buttons = drag,
            widget  = wibox.container.margin,
        },
        {
            buttons = drag,
            layout  = wibox.layout.flex.horizontal,
        },
        {
            {
                dot(cl, c.success, function(x) x.maximized = not x.maximized x:raise() end),
                dot(cl, c.error,   function(x) x:kill() end),
                spacing = dpi(8),
                layout  = wibox.layout.fixed.horizontal,
            },
            left   = dpi(8),
            right  = dpi(10),
            widget = wibox.container.margin,
        },
        layout = wibox.layout.align.horizontal,
    }
end

local function wants_titlebar(cl)
    if cl.no_titlebar or cl.requests_no_titlebar then return false end
    if cl.type ~= "normal" and cl.type ~= "dialog" then return false end
    if cl.fullscreen then return false end
    local t = cl.first_tag
    return cl.floating or (t ~= nil and t.layout == awful.layout.suit.floating)
end

local function update(cl)
    if not cl.valid then return end
    if wants_titlebar(cl) then
        if not cl.has_titlebar then
            build(cl)
            cl.has_titlebar = true
        end
        awful.titlebar.show(cl, "top")
    elseif cl.has_titlebar then
        awful.titlebar.hide(cl, "top")
    end
end

client.connect_signal("manage", update)
client.connect_signal("tagged", update)
for _, p in ipairs({ "floating", "fullscreen" }) do
    client.connect_signal("property::" .. p, update)
end
tag.connect_signal("property::layout", function(t)
    for _, cl in ipairs(t:clients()) do update(cl) end
end)
