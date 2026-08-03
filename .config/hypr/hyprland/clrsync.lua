-- Color palette sync
-- Overrides border colors set in general.lua, so require this AFTER general.lua

local background = "rgb(0C0C0C)"
local surface = "rgb(111111)"
local surface_2 = "rgb(181818)"

local primary = "rgb(5FAD5F)"
local secondary = "rgb(B89A3C)"
local info = "rgb(7AA2F7)"

local foreground = "rgb(C8C8C8)"
local muted = "rgb(525252)"

local error_color = "rgb(B85450)"

local border = "rgb(2A2A2A)"
local border_focused = primary

hl.config({
	general = {
		col = {
			active_border = border_focused,
			inactive_border = border,
		},
	},

	group = {
		col = {
			border_active = border_focused,
			border_inactive = border,
			border_locked_active = error_color,
			border_locked_inactive = surface,
		},

		groupbar = {
			col = {
				active = primary,
				inactive = surface,
				locked_active = error_color,
				locked_inactive = surface,
			},
		},
	},
})
