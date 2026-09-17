-- Flat, square, dark. Colors come from colors.lua (clrsync), so switching
-- palettes restyles awesome alongside sway, rofi, ghostty and the rest.

local gears = require("gears")
local dpi   = require("beautiful.xresources").apply_dpi

local c = require("theme.colors")

local theme = {}

theme.colors = c

theme.font_name = "MonaspiceNe Nerd Font"
theme.font      = theme.font_name .. " 10"
theme.font_bold = theme.font_name .. " Medium 10"
theme.font_icon = theme.font_name .. " Propo 12"

-- Base
theme.bg_normal   = c.bg
theme.bg_focus    = c.surface2
theme.bg_urgent   = c.error
theme.bg_minimize = c.surface
theme.fg_normal   = c.fg
theme.fg_focus    = c.fg
theme.fg_urgent   = c.on_error
theme.fg_minimize = c.muted

-- Windows
theme.useless_gap         = dpi(5)
theme.gap_single_client   = true
theme.border_width        = dpi(1)
theme.border_normal       = c.surface3
theme.border_focus        = c.accent2
theme.border_marked       = c.warning

-- Bar
theme.bar_height    = dpi(40)
theme.bar_padding   = dpi(7)
theme.block_spacing = dpi(6)
theme.block_bg      = c.surface
theme.block_pad     = dpi(10)

theme.taglist_font        = theme.font
theme.taglist_bg_focus    = c.accent2
theme.taglist_fg_focus    = c.on_accent
theme.taglist_bg_occupied = c.surface
theme.taglist_fg_occupied = c.fg
theme.taglist_bg_empty    = c.surface
theme.taglist_fg_empty    = c.muted
theme.taglist_bg_urgent   = c.error
theme.taglist_fg_urgent   = c.on_error

theme.bg_systray          = c.surface
theme.systray_icon_spacing = dpi(6)

-- Titlebars (only drawn on floating windows)
theme.titlebar_height       = dpi(26)
theme.titlebar_bg_normal    = c.bg
theme.titlebar_bg_focus     = c.surface
theme.titlebar_fg_normal    = c.muted
theme.titlebar_fg_focus     = c.fg

-- Notifications
theme.notification_font         = theme.font
theme.notification_bg           = c.surface
theme.notification_fg           = c.fg
theme.notification_border_width = dpi(1)
theme.notification_border_color = c.surface3
theme.notification_margin       = dpi(14)
theme.notification_width        = dpi(340)
theme.notification_max_width    = dpi(420)
theme.notification_icon_size    = dpi(48)
theme.notification_shape        = gears.shape.rectangle
theme.notification_spacing      = dpi(6)

-- Hotkeys cheatsheet (Super+C)
theme.hotkeys_bg                = c.bg
theme.hotkeys_fg                = c.fg
theme.hotkeys_border_width      = dpi(1)
theme.hotkeys_border_color      = c.surface3
theme.hotkeys_shape             = gears.shape.rectangle
theme.hotkeys_modifiers_fg      = c.muted
theme.hotkeys_label_bg          = c.accent2
theme.hotkeys_label_fg          = c.on_accent
theme.hotkeys_font              = theme.font_bold
theme.hotkeys_description_font  = theme.font
theme.hotkeys_group_margin      = dpi(24)

-- Calendar (click the clock, or Super+Y)
theme.calendar_style = {
    font         = theme.font,
    fg_color     = c.fg,
    bg_color     = c.bg,
    border_width = 0,
    padding      = dpi(5),
}
theme.calendar_month_padding      = dpi(12)
theme.calendar_header_fg_color    = c.fg
theme.calendar_header_font        = theme.font_bold
theme.calendar_weekday_fg_color   = c.muted
theme.calendar_focus_fg_color     = c.on_accent
theme.calendar_focus_bg_color     = c.accent2
theme.calendar_focus_markup       = '<span foreground="' .. c.on_accent .. '" background="' .. c.accent2 .. '"> %s </span>'


-- Menus
theme.menu_font         = theme.font
theme.menu_height       = dpi(28)
theme.menu_width        = dpi(200)
theme.menu_border_width = dpi(1)
theme.menu_border_color = c.surface3
theme.menu_bg_normal    = c.bg
theme.menu_bg_focus     = c.surface2
theme.menu_fg_normal    = c.fg
theme.menu_fg_focus     = c.fg

theme.tooltip_bg           = c.surface
theme.tooltip_fg           = c.fg
theme.tooltip_border_width = dpi(1)
theme.tooltip_border_color = c.surface3
theme.tooltip_font         = theme.font

theme.icon_theme = "Tela-dark"
theme.wallpaper_fill = c.bg

return theme
