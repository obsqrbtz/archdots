-- cpu, memory, volume, media and keyboard layout blocks.
-- /proc is read directly; only volume and media shell out.

local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local cfg  = require("config")
local util = require("modules.widgets.util")

local c = beautiful.colors
local M = {}

function M.cpu()
    local block, value = util.labeled("cpu")
    local prev_total, prev_idle = 0, 0
    gears.timer {
        timeout = 2, autostart = true, call_now = true,
        callback = function()
            local line = (util.read_file("/proc/stat") or ""):match("^cpu%s+([^\n]+)")
            if not line then return end
            local total, idle, i = 0, 0, 0
            for field in line:gmatch("%d+") do
                local n = tonumber(field)
                i = i + 1
                total = total + n
                if i == 4 or i == 5 then idle = idle + n end
            end
            local dt = total - prev_total
            local pct = dt > 0 and math.floor((1 - (idle - prev_idle) / dt) * 100 + 0.5) or 0
            prev_total, prev_idle = total, idle
            value.markup = util.span(string.format("%d%%", pct), pct >= 85 and c.warning or c.fg)
        end,
    }
    block:buttons(awful.button({}, 1, function() awful.spawn(cfg.monitor) end))
    return util.hover(block)
end

function M.mem()
    local block, value = util.labeled("mem")
    gears.timer {
        timeout = 5, autostart = true, call_now = true,
        callback = function()
            local info = util.read_file("/proc/meminfo") or ""
            local total = tonumber(info:match("MemTotal:%s+(%d+)")) or 0
            local avail = tonumber(info:match("MemAvailable:%s+(%d+)")) or 0
            local used = (total - avail) / 1048576
            value.markup = util.span(string.format("%.1fG", used),
                total > 0 and avail / total < 0.1 and c.warning or c.fg)
        end,
    }
    block:buttons(awful.button({}, 1, function() awful.spawn(cfg.monitor) end))
    return util.hover(block)
end

-- Refreshed on a timer and immediately after the volume keys fire
-- (they emit "widget::volume").
function M.volume()
    local block, value = util.labeled("vol")
    local function update()
        awful.spawn.easy_async({ "wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@" }, function(out)
            local vol = tonumber(out:match("([%d%.]+)"))
            if not vol then
                value.markup = util.span("n/a", c.muted)
            elseif out:find("MUTED") then
                value.markup = util.span("mute", c.muted)
            else
                value.markup = util.span(string.format("%d%%", math.floor(vol * 100 + 0.5)), c.fg)
            end
        end)
    end
    gears.timer { timeout = 5, autostart = true, call_now = true, callback = update }
    awesome.connect_signal("widget::volume", update)

    local function wpctl(...)
        awful.spawn.easy_async({ "wpctl", ... }, update)
    end
    block:buttons(gears.table.join(
        awful.button({}, 1, function() wpctl("set-mute", "@DEFAULT_AUDIO_SINK@", "toggle") end),
        awful.button({}, 3, function() awful.spawn(cfg.mixer) end),
        awful.button({}, 4, function() wpctl("set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", "2%+") end),
        awful.button({}, 5, function() wpctl("set-volume", "@DEFAULT_AUDIO_SINK@", "2%-") end)
    ))
    return util.hover(block)
end

-- Now playing. Hidden when no player is running.
function M.media()
    local value = wibox.widget.textbox()
    local block = util.block(value)
    block.visible = false
    local icon_play, icon_pause = utf8.char(0xF04B), utf8.char(0xF04C)

    local function update()
        awful.spawn.easy_async({ "playerctl", "metadata", "--format", "{{status}}\t{{artist}}\t{{title}}" },
            function(out, _, _, code)
                local status, artist, title = out:match("^(%a+)\t([^\t]*)\t([^\n]*)")
                if code ~= 0 or not status or title == "" then
                    block.visible = false
                    return
                end
                local text = artist ~= "" and (artist .. " — " .. title) or title
                if #text > 48 then text = text:sub(1, 46):gsub("[\128-\191]*$", "") .. "…" end
                block.visible = true
                value.markup = util.span(status == "Playing" and icon_play or icon_pause, c.muted, beautiful.font_icon)
                    .. "  " .. util.span(text, status == "Playing" and c.fg or c.muted)
            end)
    end
    gears.timer { timeout = 3, autostart = true, call_now = true, callback = update }
    awesome.connect_signal("widget::media", update)

    local function ctl(cmd)
        return function() awful.spawn.easy_async({ "playerctl", cmd }, update) end
    end
    block:buttons(gears.table.join(
        awful.button({}, 1, ctl("play-pause")),
        awful.button({}, 3, ctl("next")),
        awful.button({}, 4, ctl("previous")),
        awful.button({}, 5, ctl("next"))
    ))
    return util.hover(block)
end

-- Current xkb group; click to cycle.
function M.keyboard()
    local keyboard = require("modules.keyboard")
    local block, value = util.labeled("kb")
    local names = {}

    local function status()
        local group = awesome.xkb_get_layout_group() + 1
        value.markup = util.span(names[group] or "?", c.fg)
    end
    local function map()
        names = keyboard.names()
        status()
    end
    map()
    awesome.connect_signal("xkb::map_changed", map)
    awesome.connect_signal("xkb::group_changed", status)

    block:buttons(awful.button({}, 1, keyboard.next))
    return util.hover(block)
end

return M
