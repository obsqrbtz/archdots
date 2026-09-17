local awful         = require("awful")
local gears         = require("gears")
local naughty       = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")

local cfg        = require("config")
local scratchpad = require("modules.scratchpad")
local resize     = require("modules.resize")
local powermenu  = require("modules.powermenu")
local wallpaper  = require("modules.wallpaper")
local keyboard   = require("modules.keyboard")

local modkey = cfg.modkey
local colors = require("beautiful").colors
local floating = awful.layout.suit.floating

local function run(cmd) return function() awful.spawn(cmd) end end
local function shell(cmd) return function() awful.spawn.with_shell(cmd) end end

local function is_floating(c)
    return c.floating or awful.layout.get(c.screen) == floating
end

-- Tiled windows swap places; floating ones nudge
local function move(dir)
    local c = client.focus
    if not c then return end
    if is_floating(c) then
        local d = 40
        local dx = dir == "left" and -d or dir == "right" and d or 0
        local dy = dir == "up"   and -d or dir == "down"  and d or 0
        c:relative_move(dx, dy, 0, 0)
    else
        awful.client.swap.global_bydirection(dir)
    end
end

local function focus(dir)
    return function()
        awful.client.focus.global_bydirection(dir)
        if client.focus then client.focus:raise() end
    end
end

-- Remember each tag's tiling layout so float -> tile restores it
local tiled_layout = setmetatable({}, { __mode = "k" })
local function toggle_tag_floating()
    local t = awful.screen.focused().selected_tag
    if not t then return end
    if t.layout == floating then
        t.layout = tiled_layout[t] or awful.layout.layouts[1]
    else
        tiled_layout[t] = t.layout
        t.layout = floating
    end
end
awesome.connect_signal("tag::toggle_floating", toggle_tag_floating)

-- sway's `focus mode_toggle`
local function focus_mode_toggle()
    local s = awful.screen.focused()
    local want = not (client.focus and client.focus.floating)
    local c = awful.client.focus.history.get(s, 0, function(x) return x.floating == want end)
    if c then c:emit_signal("request::activate", "key.focus_mode", { raise = true }) end
end

local function volume(...)
    local args = { "wpctl", ... }
    return function()
        awful.spawn.easy_async(args, function() awesome.emit_signal("widget::volume") end)
    end
end

local function player(cmd)
    return function()
        awful.spawn.easy_async({ "playerctl", cmd }, function() awesome.emit_signal("widget::media") end)
    end
end

local keys = gears.table.join(
    -- Applications
    awful.key({ modkey }, "Return", run(cfg.terminal),
        { description = "terminal", group = "applications" }),
    awful.key({ modkey }, "e", run(cfg.filemanager),
        { description = "file manager", group = "applications" }),
    awful.key({ modkey }, "d", run(cfg.launcher),
        { description = "application launcher", group = "applications" }),
    awful.key({ modkey, "Shift" }, "d", run(cfg.runner),
        { description = "run command", group = "applications" }),
    awful.key({ modkey }, "Tab", run(cfg.switcher),
        { description = "window switcher", group = "applications" }),
    awful.key({ modkey }, "equal", run(cfg.calculator),
        { description = "calculator", group = "applications" }),
    awful.key({}, "XF86Calculator", run(cfg.calculator)),
    awful.key({ modkey }, "w", wallpaper.pick,
        { description = "wallpaper picker", group = "applications" }),
    awful.key({ modkey, "Shift" }, "v", run(cfg.vpn_menu),
        { description = "vpn menu", group = "applications" }),
    awful.key({ modkey, "Control" }, "v", shell(cfg.vpn_toggle),
        { description = "vpn toggle on/off", group = "applications" }),
    awful.key({ modkey }, "g", run(cfg.monitor),
        { description = "system monitor", group = "applications" }),
    awful.key({ modkey }, "i", run(cfg.network),
        { description = "network connections", group = "applications" }),
    awful.key({ modkey }, "b", run(cfg.bluetooth),
        { description = "bluetooth", group = "applications" }),
    awful.key({ modkey }, "c", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end,
        { description = "this cheatsheet", group = "applications" }),

    -- Session
    awful.key({ modkey, "Shift" }, "q", function() powermenu.open() end,
        { description = "power menu", group = "session" }),
    awful.key({ modkey, "Shift" }, "c", awesome.restart,
        { description = "reload awesome", group = "session" }),
    awful.key({ modkey }, "m", function() powermenu.open("logout") end,
        { description = "exit awesome", group = "session" }),
    awful.key({ modkey }, "n", function() naughty.destroy_all_notifications() end,
        { description = "dismiss notifications", group = "session" }),
    awful.key({ modkey, "Shift" }, "n", function() awesome.emit_signal("notifications::toggle") end,
        { description = "pause notifications", group = "session" }),
    awful.key({ modkey }, "y", function() awesome.emit_signal("calendar::toggle") end,
        { description = "calendar", group = "session" }),
    keyboard.keys,

    -- Layout
    awful.key({ modkey }, "space", focus_mode_toggle,
        { description = "focus tiling/floating", group = "layout" }),
    awful.key({ modkey, "Shift" }, "f", toggle_tag_floating,
        { description = "workspace: tiling / floating", group = "layout" }),
    awful.key({ modkey }, "t", function() awful.layout.set(awful.layout.suit.tile) end,
        { description = "tiling layout", group = "layout" }),
    awful.key({ modkey }, "s", function() awful.layout.set(awful.layout.suit.max) end,
        { description = "monocle layout (stacking)", group = "layout" }),
    awful.key({ modkey, "Shift" }, "t", function()
        local l = awful.layout.get(awful.screen.focused())
        awful.layout.set(l == awful.layout.suit.tile and awful.layout.suit.tile.bottom or awful.layout.suit.tile)
    end, { description = "toggle split direction", group = "layout" }),
    awful.key({ modkey, "Control" }, "space", function() awful.layout.inc(1) end,
        { description = "cycle layouts", group = "layout" }),
    awful.key({ modkey }, "bracketright", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "more master windows", group = "layout" }),
    awful.key({ modkey }, "bracketleft", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "fewer master windows", group = "layout" }),
    awful.key({ modkey, "Shift" }, "bracketright", function() awful.tag.incncol(1, nil, true) end,
        { description = "more columns", group = "layout" }),
    awful.key({ modkey, "Shift" }, "bracketleft", function() awful.tag.incncol(-1, nil, true) end,
        { description = "fewer columns", group = "layout" }),
    awful.key({ modkey }, "r", resize.start,
        { description = "resize mode", group = "layout" }),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent window", group = "focus" }),

    -- Scratchpad
    awful.key({ modkey }, "o", scratchpad.toggle,
        { description = "toggle scratchpad", group = "scratchpad" }),

    -- Screenshots
    awful.key({}, "Print", run({ cfg.screenshot, "screen" }),
        { description = "screenshot: whole screen", group = "screenshots" }),
    awful.key({ "Shift" }, "Print", run({ cfg.screenshot, "region" }),
        { description = "screenshot: region", group = "screenshots" }),

    -- Media keys
    awful.key({}, "XF86AudioRaiseVolume", volume("set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", "5%+")),
    awful.key({}, "XF86AudioLowerVolume", volume("set-volume", "@DEFAULT_AUDIO_SINK@", "5%-")),
    awful.key({}, "XF86AudioMute",        volume("set-mute", "@DEFAULT_AUDIO_SINK@", "toggle")),
    awful.key({}, "XF86AudioMicMute",     volume("set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle")),
    awful.key({}, "XF86MonBrightnessUp",   run("brightnessctl -e4 -n2 set 5%+")),
    awful.key({}, "XF86MonBrightnessDown", run("brightnessctl -e4 -n2 set 5%-")),
    awful.key({}, "XF86AudioNext",  player("next")),
    awful.key({}, "XF86AudioPrev",  player("previous")),
    awful.key({}, "XF86AudioPlay",  player("play-pause")),
    awful.key({}, "XF86AudioPause", player("play-pause"))
)

-- Focus / move: hjkl and arrows
for _, d in ipairs({ { "h", "Left", "left" }, { "j", "Down", "down" }, { "k", "Up", "up" }, { "l", "Right", "right" } }) do
    local vim, arrow, dir = d[1], d[2], d[3]
    keys = gears.table.join(keys,
        awful.key({ modkey }, vim, focus(dir),
            { description = "focus " .. dir, group = "focus" }),
        awful.key({ modkey }, arrow, focus(dir)),
        awful.key({ modkey, "Shift" }, vim, function() move(dir) end,
            { description = "move window " .. dir, group = "focus" }),
        awful.key({ modkey, "Shift" }, arrow, function() move(dir) end)
    )
end

-- Workspaces 1..10 (0 is 10)
for i = 1, 10 do
    local key = "#" .. (i + 9)
    local first = i == 1
    keys = gears.table.join(keys,
        awful.key({ modkey }, key, function()
            local t = awful.screen.focused().tags[i]
            if t then t:view_only() end
        end, first and { description = "view workspace 1..0", group = "workspaces" } or nil),

        awful.key({ modkey, "Shift" }, key, function()
            local t = client.focus and client.focus.screen.tags[i]
            if t then client.focus:move_to_tag(t) end
        end, first and { description = "move window to workspace 1..0", group = "workspaces" } or nil),

        awful.key({ modkey, "Control" }, key, function()
            local t = awful.screen.focused().tags[i]
            if t then awful.tag.viewtoggle(t) end
        end, first and { description = "also show workspace 1..0", group = "workspaces" } or nil)
    )
end

root.keys(keys)

-- One label color for every group in the cheatsheet instead of xrdb's rainbow.
-- Descriptions are Pango markup there: no bare <, > or &.
for _, group in ipairs({ "applications", "session", "layout", "focus", "scratchpad", "screenshots", "workspaces" }) do
    hotkeys_popup.widget.add_group_rules(group, { color = colors.accent2 })
end

root.buttons(gears.table.join(
    awful.button({}, 1, powermenu.close),
    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext)
))
