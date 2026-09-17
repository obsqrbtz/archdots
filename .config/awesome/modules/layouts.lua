-- Layouts available to Super+Shift+T / clicking the layout block.
-- tile and floating are the two that matter; the rest are there to cycle.

local awful = require("awful")

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.fair,
    awful.layout.suit.floating,
}

-- Short names shown in the bar
local names = {
    tile       = "tile",
    tilebottom = "tile",
    tileleft   = "tile",
    tiletop    = "tile",
    max        = "mono",
    fullscreen = "full",
    fairv      = "fair",
    fairh      = "fair",
    floating   = "float",
}

return {
    name = function(l)
        local n = awful.layout.getname(l)
        return names[n] or n
    end,
}
