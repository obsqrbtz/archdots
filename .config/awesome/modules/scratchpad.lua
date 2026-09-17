-- sway's scratchpad: Super+Shift+S stashes the focused window, Super+O
-- shows it floating on the current workspace. Press again to hide; keep
-- pressing to cycle when several are stashed. Tiling a window takes it
-- out of the scratchpad, as in sway.

local awful = require("awful")

local M = {}
local stash = {}

local function remove(c)
    for i, v in ipairs(stash) do
        if v == c then table.remove(stash, i) return end
    end
end

client.connect_signal("unmanage", remove)
client.connect_signal("property::floating", function(c)
    if not c.floating then remove(c) end
end)

local function show(c)
    local s  = awful.screen.focused()
    local wa = s.workarea
    c:move_to_tag(s.selected_tag)
    c.hidden   = false
    c.floating = true
    c:geometry({ width = math.floor(wa.width * 0.5), height = math.floor(wa.height * 0.55) })
    awful.placement.centered(c, { honor_workarea = true })
    c:emit_signal("request::activate", "scratchpad", { raise = true })
end

function M.send(c)
    if not c then return end
    remove(c)
    c.floating = true
    c.hidden   = true
    table.insert(stash, c)
end

function M.toggle()
    for _, c in ipairs(stash) do
        if not c.hidden then
            if c:isvisible() then
                c.hidden = true
                remove(c)
                table.insert(stash, c)
            else
                show(c)
            end
            return
        end
    end
    if stash[1] then show(stash[1]) end
end

return M
