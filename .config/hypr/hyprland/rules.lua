-- Window & Layer rules
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- ######## Window rules ########

-- Global transparency for every window
hl.window_rule({ match = { class = ".*" }, opacity = "1.00 override 1.00 override" })

-- Disable blur for xwayland context menus
hl.window_rule({ match = { class = "^()$", title = "^()$" }, no_blur = true })
-- hl.window_rule({ match = { xwayland = true }, no_blur = true })

-- Floating
hl.window_rule({ match = { class = [[^(blueberry\.py)$]] }, float = true })
hl.window_rule({ match = { class = "^(guifetch)$" }, float = true }) -- FlafyDev/guifetch
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, size = { "45%", "45%" } })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, center = true })
hl.window_rule({ match = { class = [[^(org\.pulseaudio\.pavucontrol)$]] }, float = true })
hl.window_rule({ match = { class = [[^(org\.pulseaudio\.pavucontrol)$]] }, size = { "45%", "45%" } })
hl.window_rule({ match = { class = [[^(org\.pulseaudio\.pavucontrol)$]] }, center = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, size = { "45%", "45%" } })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, center = true })
hl.window_rule({ match = { class = ".*plasmawindowed.*" }, float = true })
hl.window_rule({ match = { class = "kcm_.*" }, float = true })
hl.window_rule({ match = { class = ".*bluedevilwizard" }, float = true })
hl.window_rule({ match = { title = ".*Welcome" }, float = true })
hl.window_rule({ match = { title = "^(illogical-impulse Settings)$" }, float = true })
hl.window_rule({ match = { class = "org.freedesktop.impl.portal.desktop.kde" }, float = true })
hl.window_rule({ match = { class = "^(Zotero)$" }, float = true })
hl.window_rule({ match = { class = "^(Zotero)$" }, size = { "45%", "45%" } })

-- Move
-- kde-material-you-colors spawns a window when changing dark/light theme.
-- This is to make sure it doesn't interfere at all.
hl.window_rule({ match = { class = "^(plasma-changeicons)$" }, float = true })
hl.window_rule({ match = { class = "^(plasma-changeicons)$" }, no_initial_focus = true })
hl.window_rule({ match = { class = "^(plasma-changeicons)$" }, move = { "999999", "999999" } })
-- Stupid dolphin copy
hl.window_rule({ match = { title = [[^(Copying — Dolphin)$]] }, move = { "40", "80" } })

-- Tiling
hl.window_rule({ match = { class = [[^dev\.warp\.Warp$]] }, tile = true })

-- Picture-in-Picture
hl.window_rule({ match = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] }, float = true })
hl.window_rule({ match = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] }, keep_aspect_ratio = true })
hl.window_rule({ match = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] }, move = { "73%", "72%" } })
hl.window_rule({ match = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] }, size = { "25%", "25%" } })
hl.window_rule({ match = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] }, pin = true })

-- Dialog windows - float+center
local dialogTitles = {
	"^(Open File)(.*)$",
	"^(Select a File)(.*)$",
	"^(Choose wallpaper)(.*)$",
	"^(Open Folder)(.*)$",
	"^(Save As)(.*)$",
	"^(Library)(.*)$",
	"^(File Upload)(.*)$",
	"^(.*)(wants to save)$",
	"^(.*)(wants to open)$",
}
for _, t in ipairs(dialogTitles) do
	hl.window_rule({ match = { title = t }, center = true })
	hl.window_rule({ match = { title = t }, float = true })
end

-- --- Tearing ---
hl.window_rule({ match = { title = [[.*\.exe]] }, immediate = true })
hl.window_rule({ match = { title = ".*minecraft.*" }, immediate = true })
hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })

-- No shadow for tiled windows
hl.window_rule({ match = { float = false }, no_shadow = true })

-- Pinned window border
hl.window_rule({ match = { pin = true }, border_color = "rgba(58d6f7AA) rgba(58d6f777)" })

-- ######## Workspace rules ########
hl.workspace_rule({ workspace = "special:special", gaps_out = 30 })

-- ######## Layer rules ########
hl.layer_rule({ match = { namespace = ".*" }, xray = true })
-- hl.layer_rule({ match = { namespace = ".*" }, no_anim = true })
hl.layer_rule({ match = { namespace = "walker" }, no_anim = true })
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "overview" }, no_anim = true })
hl.layer_rule({ match = { namespace = "anyrun" }, no_anim = true })
hl.layer_rule({ match = { namespace = "indicator.*" }, no_anim = true })
hl.layer_rule({ match = { namespace = "osk" }, no_anim = true })
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })

hl.layer_rule({ match = { namespace = "noanim" }, no_anim = true })
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true })
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true })
hl.layer_rule({ match = { namespace = "launcher" }, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true })
hl.layer_rule({ match = { namespace = "notifications" }, ignore_alpha = 0.69 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true }) -- wlogout

-- ags
hl.layer_rule({ match = { namespace = "sideleft.*" }, animation = "slide left" })
hl.layer_rule({ match = { namespace = "sideright.*" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "session[0-9]*" }, blur = true })
hl.layer_rule({ match = { namespace = "bar[0-9]*" }, blur = true })
hl.layer_rule({ match = { namespace = "bar[0-9]*" }, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "barcorner.*" }, blur = true })
hl.layer_rule({ match = { namespace = "barcorner.*" }, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "dock[0-9]*" }, blur = true })
hl.layer_rule({ match = { namespace = "dock[0-9]*" }, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "indicator.*" }, blur = true })
hl.layer_rule({ match = { namespace = "indicator.*" }, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "overview[0-9]*" }, blur = true })
hl.layer_rule({ match = { namespace = "overview[0-9]*" }, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "cheatsheet[0-9]*" }, blur = true })
hl.layer_rule({ match = { namespace = "cheatsheet[0-9]*" }, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "sideright[0-9]*" }, blur = true })
hl.layer_rule({ match = { namespace = "sideright[0-9]*" }, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "sideleft[0-9]*" }, blur = true })
hl.layer_rule({ match = { namespace = "sideleft[0-9]*" }, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "indicator.*" }, blur = true })
hl.layer_rule({ match = { namespace = "indicator.*" }, ignore_alpha = 0.6 })
hl.layer_rule({ match = { namespace = "osk[0-9]*" }, blur = true })
hl.layer_rule({ match = { namespace = "osk[0-9]*" }, ignore_alpha = 0.6 })

-- Quickshell
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur_popups = true })
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell:.*" }, ignore_alpha = 0.79 })
hl.layer_rule({ match = { namespace = "quickshell:bar" }, animation = "slide top" })
hl.layer_rule({ match = { namespace = "quickshell:screenCorners" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:sidebarRight" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "quickshell:sidebarLeft" }, animation = "slide left" })
hl.layer_rule({ match = { namespace = "quickshell:osk" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:dock" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:session" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell:session" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:session" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell:notificationPopup" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:backgroundWidgets" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell:backgroundWidgets" }, ignore_alpha = 0.05 })
hl.layer_rule({ match = { namespace = "quickshell:screenshot" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:screenCorners" }, animation = "popin 120%" })
hl.layer_rule({ match = { namespace = "quickshell:lockWindowPusher" }, no_anim = true })

-- Launchers need to be FAST
hl.layer_rule({ match = { namespace = "quickshell:overview" }, no_anim = true })
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true })

-- outfoxxed's stuff
hl.layer_rule({ match = { namespace = "shell:bar" }, blur = true })
hl.layer_rule({ match = { namespace = "shell:bar" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "shell:notifications" }, blur = true })
hl.layer_rule({ match = { namespace = "shell:notifications" }, ignore_alpha = 0.1 })
