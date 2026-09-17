-- Session menu (Super+Shift+Q, or the power block in the bar).
-- h/l or arrows to move, Return to pick, Escape to close.

local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi

local cfg  = require("config")
local util = require("modules.widgets.util")

local c = beautiful.colors
local M = {}

local entries = {
    { id = "lock",     label = "lock",     icon = 0xF033E, run = function() awful.spawn(cfg.locker) end },
    { id = "logout",   label = "logout",   icon = 0xF0343, run = function() awesome.quit() end },
    { id = "suspend",  label = "suspend",  icon = 0xF0904, run = function() awful.spawn("systemctl suspend") end },
    { id = "reboot",   label = "reboot",   icon = 0xF0709, run = function() awful.spawn("systemctl reboot") end },
    { id = "poweroff", label = "shutdown", icon = 0xF0425, run = function() awful.spawn("systemctl poweroff") end },
}

local function uptime()
    local secs = tonumber((util.read_file("/proc/uptime") or ""):match("^(%d+)")) or 0
    local d, h, m = secs // 86400, secs % 86400 // 3600, secs % 3600 // 60
    if d > 0 then return string.format("up %dd %dh", d, h) end
    return string.format("up %dh %02dm", h, m)
end

local popup, grabber

function M.close()
    if grabber then awful.keygrabber.stop(grabber) grabber = nil end
    if popup then popup.visible = false popup = nil end
end

function M.open(preselect)
    M.close()

    local items = {}
    for _, e in ipairs(entries) do
        if e.id ~= "lock" or cfg.locker ~= "" then table.insert(items, e) end
    end

    local selected = 1
    for i, e in ipairs(items) do
        if e.id == preselect then selected = i end
    end

    local cells = {}
    local function paint()
        for i, cell in ipairs(cells) do
            local on = i == selected
            cell.bg = on and c.accent2 or c.surface
            cell.fg = on and c.on_accent or c.fg
        end
    end
    local function activate(i)
        local e = items[i]
        M.close()
        e.run()
    end

    local row = wibox.layout.fixed.horizontal()
    row.spacing = dpi(8)
    for i, e in ipairs(items) do
        local cell = wibox.widget {
            {
                {
                    {
                        text   = utf8.char(e.icon),
                        font   = beautiful.font_name .. " Propo 22",
                        align  = "center",
                        widget = wibox.widget.textbox,
                    },
                    {
                        text   = e.label,
                        align  = "center",
                        widget = wibox.widget.textbox,
                    },
                    spacing = dpi(10),
                    layout  = wibox.layout.fixed.vertical,
                },
                valign = "center",
                halign = "center",
                widget = wibox.container.place,
            },
            forced_width  = dpi(100),
            forced_height = dpi(100),
            widget        = wibox.container.background,
        }
        cell:connect_signal("mouse::enter", function() selected = i paint() end)
        cell:buttons(awful.button({}, 1, function() activate(i) end))
        cells[i] = cell
        row:add(cell)
    end
    paint()

    local s = awful.screen.focused()
    popup = awful.popup {
        screen       = s,
        ontop        = true,
        visible      = true,
        bg           = c.bg,
        border_width = dpi(1),
        border_color = c.surface3,
        placement    = function(d) awful.placement.centered(d, { parent = s }) end,
        widget = {
            {
                {
                    { markup = util.span("session", c.fg, beautiful.font_bold), widget = wibox.widget.textbox },
                    nil,
                    { markup = util.span(uptime(), c.muted), widget = wibox.widget.textbox },
                    layout = wibox.layout.align.horizontal,
                },
                row,
                spacing = dpi(16),
                layout  = wibox.layout.fixed.vertical,
            },
            margins = dpi(18),
            widget  = wibox.container.margin,
        },
    }

    grabber = awful.keygrabber.run(function(_, key, event)
        if event ~= "press" then return end
        if key == "Escape" or key == "q" then
            M.close()
        elseif key == "Return" or key == "space" then
            activate(selected)
        elseif key == "h" or key == "Left" or key == "ISO_Left_Tab" then
            selected = (selected - 2) % #items + 1
            paint()
        elseif key == "l" or key == "Right" or key == "Tab" then
            selected = selected % #items + 1
            paint()
        end
    end)
end

return M
