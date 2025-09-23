pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Assets.Matugen
import qs.Services

Singleton {
  id: root

  property string dynamicConfigPath: Settings.isLoaded ? Settings.cacheDir + "matugen.dynamic.toml" : ""

  // External state management
  Connections {
    target: WallpaperService
    function onWallpaperChanged(screenName, path) {
      // Only detect changes on main screen
      if (screenName === Screen.name && Settings.data.colorSchemes.useWallpaperColors) {
        generateFromWallpaper()
      }
    }
  }

  Connections {
    target: Settings.data.colorSchemes
    function onDarkModeChanged() {
      Logger.log("Matugen", "Detected dark mode change")
      if (Settings.data.colorSchemes.useWallpaperColors) {
        MatugenService.generateFromWallpaper()
      }
    }
  }

  // --------------------------------
  function init() {
    // does nothing but ensure the singleton is created
    // do not remove
    Logger.log("Matugen", "Service started")
  }

  // Build TOML content based on settings
  function buildConfigToml() {
    return Matugen.buildConfigToml()
  }

  // Generate colors using current wallpaper and settings
  function generateFromWallpaper() {
    if (!Settings.isLoaded) {
      Logger.log("Matugen", "Settings not loaded yet, skipping wallpaper color generation")
      return
    }

    Logger.log("Matugen", "Generating from wallpaper on screen:", Screen.name)
    var wp = WallpaperService.getWallpaper(Screen.name).replace(/'/g, "'\\''")
    if (wp === "") {
      Logger.error("Matugen", "No wallpaper was found")
      return
    }

    var content = buildConfigToml()
    var mode = Settings.data.colorSchemes.darkMode ? "dark" : "light"
    var pathEsc = dynamicConfigPath.replace(/'/g, "'\\''")
    var extraRepo = (Quickshell.shellDir + "/Assets/Matugen/extra").replace(/'/g, "'\\''")
    var extraUser = (Settings.configDir + "matugen.d").replace(/'/g, "'\\''")

    // Build the main script
    var script = "cat > '" + pathEsc + "' << 'EOF'\n" + content + "EOF\n" + "for d in '" + extraRepo + "' '" + extraUser + "'; do\n" + "  if [ -d \"$d\" ]; then\n" + "    for f in \"$d\"/*.toml; do\n" + "      [ -f \"$f\" ] && { echo; echo \"# extra: $f\"; cat \"$f\"; } >> '" + pathEsc + "'\n" + "    done\n" + "  fi\n" + "done\n" + "matugen image '"
        + wp + "' --config '" + pathEsc + "' --mode " + mode

    // Add user config execution if enabled
    if (Settings.data.matugen.enableUserTemplates) {
      var userConfigDir = (Quickshell.env("HOME") + "/.config/matugen/").replace(/'/g, "'\\''")
      script += "\n# Execute user config if it exists\nif [ -f '" + userConfigDir + "config.toml' ]; then\n"
      script += "  matugen image '" + wp + "' --config '" + userConfigDir + "config.toml' --mode " + mode + "\n"
      script += "fi"
    }

    script += "\n"
    generateProcess.command = ["bash", "-lc", script]
    generateProcess.running = true
  }

  Process {
    id: generateProcess
    workingDirectory: Quickshell.shellDir
    running: false

    stderr: StdioCollector {
      onStreamFinished: {
        if (this.text !== "") {
          Logger.warn("MatugenService", "Matugen stderr:", this.text)
        }
      }
    }
  }

  // No separate writer; the write happens inline via bash heredoc
}
