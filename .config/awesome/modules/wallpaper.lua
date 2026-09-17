-- Wallpaper: last pick from Super+W, else pywal's current one, else a fill.

local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")

local cfg  = require("config")
local util = require("modules.widgets.util")

local M = {}

local function first_line(path)
    local s = util.read_file(path)
    return s and s:match("^([^\n]+)")
end

function M.current()
    for _, source in ipairs({ cfg.wallpaper_state, cfg.wallpaper_pywal }) do
        local p = first_line(source)
        if p and gears.filesystem.file_readable(p) then return p end
    end
end

function M.apply(s)
    local path = M.current()
    if path then
        -- aspect kept, scaled to cover (cropped), like sway's `fill`
        gears.wallpaper.maximized(path, s, false)
    else
        gears.wallpaper.set(beautiful.wallpaper_fill)
    end
end

function M.set(path)
    gears.filesystem.make_parent_directories(cfg.wallpaper_state)
    local f = io.open(cfg.wallpaper_state, "w")
    if f then f:write(path, "\n") f:close() end
    for s in screen do M.apply(s) end
end

function M.pick()
    local dir = cfg.wallpaper_dir
    local cmd = string.format(
        "find %q -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -printf '%%f\\n'"
        .. " | sort | rofi -dmenu -i -p wallpaper", dir)
    awful.spawn.easy_async_with_shell(cmd, function(out)
        local name = out:match("^([^\n]+)")
        if name then M.set(dir .. "/" .. name) end
    end)
end

return M
