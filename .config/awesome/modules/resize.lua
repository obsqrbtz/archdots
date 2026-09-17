-- sway's resize mode. Super+R, then h/j/k/l or arrows; Return/Escape leaves.
-- Floating windows change size; tiled ones move the master split (h/l)
-- or their share of the column (j/k).

local awful = require("awful")
local dpi   = require("beautiful.xresources").apply_dpi

local M = {}

local step = dpi(30)

local function floating(c)
    return c.floating or awful.layout.get(c.screen) == awful.layout.suit.floating
end

local actions = {
    h = function(c) if floating(c) then c:relative_move(0, 0, -step, 0) else awful.tag.incmwfact(-0.03) end end,
    l = function(c) if floating(c) then c:relative_move(0, 0,  step, 0) else awful.tag.incmwfact( 0.03) end end,
    j = function(c) if floating(c) then c:relative_move(0, 0, 0,  step) else awful.client.incwfact( 0.08, c) end end,
    k = function(c) if floating(c) then c:relative_move(0, 0, 0, -step) else awful.client.incwfact(-0.08, c) end end,
}
actions.Left, actions.Right, actions.Down, actions.Up = actions.h, actions.l, actions.j, actions.k

function M.start()
    awesome.emit_signal("mode::changed", "resize")
    local grabber
    grabber = awful.keygrabber.run(function(_, key, event)
        if event ~= "press" then return end
        if key == "Return" or key == "Escape" then
            awful.keygrabber.stop(grabber)
            awesome.emit_signal("mode::changed", nil)
            return
        end
        local c = client.focus
        if c and actions[key] then actions[key](c) end
    end)
end

return M
