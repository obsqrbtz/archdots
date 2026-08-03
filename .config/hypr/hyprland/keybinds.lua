-- Keybinds
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER"

local terminal    = terminal    or "kitty"
local fileManager = fileManager or "dolphin"
local menu        = menu        or "qs -c basedgoose.shell ipc call launcher toggle"

hl.bind(mainMod .. " + return",       hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",            hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q",    hl.dsp.exec_cmd("qs -c basedgoose.shell ipc call power toggle"))
hl.bind(mainMod .. " + M",            hl.dsp.exit())
hl.bind(mainMod .. " + E",            hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + W",            hl.dsp.exec_cmd("qs -c basedgoose.shell ipc call wallpaper toggle"))
hl.bind(mainMod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D",            hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + C",            hl.dsp.exec_cmd("qs -c basedgoose.shell ipc call cheatsheet toggle"))
-- hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("qs -c noctalia-shell ipc call launcher clipboard"))
hl.bind(mainMod .. " + P",            hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + J",            hl.dsp.layout("togglesplit")) -- dwindle

-- Focus movement
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10 -- 10 -> 0
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + O",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness (bindel == locked + repeating)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))

-- Requires playerctl (bindl == locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
