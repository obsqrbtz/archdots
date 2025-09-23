pragma Singleton

import QtQuick
import Quickshell
import qs.Commons

// Central place to define which templates we generate and where they write.
// Users can extend it by dropping additional templates into:
//  - Assets/Matugen/templates/
//  - ~/.config/matugen/ (when enableUserTemplates is true)
Singleton {
  id: root

  // Build the base TOML using current settings
  function buildConfigToml() {
    var lines = []
    lines.push("[config]")

    // Always include noctalia colors output for the shell
    lines.push("[templates.noctalia]")
    lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/noctalia.json"')
    lines.push('output_path = "' + Settings.configDir + 'colors.json"')

    if (Settings.data.matugen.gtk4) {
      lines.push("\n[templates.gtk4]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/gtk4.css"')
      lines.push('output_path = "~/.config/gtk-4.0/gtk.css"')
    }
    if (Settings.data.matugen.gtk3) {
      lines.push("\n[templates.gtk3]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/gtk3.css"')
      lines.push('output_path = "~/.config/gtk-3.0/gtk.css"')
    }
    if (Settings.data.matugen.qt6) {
      lines.push("\n[templates.qt6]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/qtct.conf"')
      lines.push('output_path = "~/.config/qt6ct/colors/noctalia.conf"')
    }
    if (Settings.data.matugen.qt5) {
      lines.push("\n[templates.qt5]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/qtct.conf"')
      lines.push('output_path = "~/.config/qt5ct/colors/noctalia.conf"')
    }
    if (Settings.data.matugen.kitty) {
      lines.push("\n[templates.kitty]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/kitty.conf"')
      lines.push('output_path = "~/.config/kitty/themes/noctalia.conf"')
      lines.push("post_hook   = 'kitty +kitten themes --reload-in=all noctalia'")
    }
    if (Settings.data.matugen.ghostty) {
      lines.push("\n[templates.ghostty]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/ghostty.conf"')
      lines.push('output_path = "~/.config/ghostty/themes/noctalia"')
      lines.push("post_hook = \"grep -q '^theme *= *' ~/.config/ghostty/config; and sed -i 's/^theme *= *.*/theme = noctalia/' ~/.config/ghostty/config; or echo 'theme = noctalia' >> ~/.config/ghostty/config\"")
    }
    if (Settings.data.matugen.foot) {
      lines.push("\n[templates.foot]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/foot.conf"')
      lines.push('output_path = "~/.config/foot/themes/noctalia"')
      lines.push('post_hook = "sed -i /themes/d ~/.config/foot/foot.ini && echo include=~/.config/foot/themes/noctalia >> ~/.config/foot/foot.ini"')
    }
    if (Settings.data.matugen.fuzzel) {
      lines.push("\n[templates.fuzzel]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/fuzzel.conf"')
      lines.push('output_path = "~/.config/fuzzel/themes/noctalia"')
      lines.push('post_hook = "sed -i /themes/d ~/.config/fuzzel/fuzzel.ini && echo include=~/.config/fuzzel/themes/noctalia >> ~/.config/fuzzel/fuzzel.ini"')
    }
    if (Settings.data.matugen.vesktop) {
      lines.push("\n[templates.vesktop]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/vesktop.css"')
      lines.push('output_path = "~/.config/vesktop/themes/noctalia.theme.css"')
    }
    if (Settings.data.matugen.pywalfox) {
      lines.push("\n[templates.pywalfox]")
      lines.push('input_path = "' + Quickshell.shellDir + '/Assets/Matugen/templates/pywalfox.json"')
      lines.push('output_path = "~/.cache/wal/colors.json"')
      lines.push('post_hook = "pywalfox update"')
    }

    return lines.join("\n") + "\n"
  }
}
