pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Services

Singleton {
  id: root
  property string currentLayout: "Unknown"
  property int updateInterval: 1000 // Update every second

  // Timer to periodically update the layout
  Timer {
    id: updateTimer
    interval: updateInterval
    running: true
    repeat: true
    onTriggered: {
      updateLayout()
    }
  }

  // Process to get current keyboard layout using niri msg (Wayland native)
  Process {
    id: niriLayoutProcess
    running: false
    command: ["niri", "msg", "-j", "keyboard-layouts"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const data = JSON.parse(text)
          const layoutName = data.names[data.current_idx]
          root.currentLayout = extractLayoutCode(layoutName)
        } catch (e) {
          root.currentLayout = "Unknown"
        }
      }
    }
  }

  // Process to get current keyboard layout using hyprctl (Hyprland)
  Process {
    id: hyprlandLayoutProcess
    running: false
    command: ["hyprctl", "-j", "devices"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const data = JSON.parse(text)
          // Find the main keyboard and get its active keymap
          const mainKeyboard = data.keyboards.find(kb => kb.main === true)
          if (mainKeyboard && mainKeyboard.active_keymap) {
            root.currentLayout = extractLayoutCode(mainKeyboard.active_keymap)
          } else {
            root.currentLayout = "Unknown"
          }
        } catch (e) {
          root.currentLayout = "Unknown"
        }
      }
    }
  }

  // Process for X11 systems using setxkbmap
  Process {
    id: x11LayoutProcess
    running: false
    command: ["setxkbmap", "-query"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const lines = text.split('\n')
          for (const line of lines) {
            if (line.startsWith('layout:')) {
              const layout = line.split(':')[1].trim()
              root.currentLayout = layout
              return
            }
          }
          root.currentLayout = "Unknown"
        } catch (e) {
          root.currentLayout = "Unknown"
        }
      }
    }
  }

  // Process for general Wayland using localectl (systemd)
  Process {
    id: localectlProcess
    running: false
    command: ["localectl", "status"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const lines = text.split('\n')
          for (const line of lines) {
            if (line.includes("X11 Layout:")) {
              const layout = line.split(':')[1].trim()
              if (layout && layout !== "n/a") {
                root.currentLayout = layout
                return
              }
            }
            if (line.includes("VC Keymap:")) {
              const keymap = line.split(':')[1].trim()
              if (keymap && keymap !== "n/a") {
                root.currentLayout = extractLayoutCode(keymap)
                return
              }
            }
          }
          root.currentLayout = "Unknown"
        } catch (e) {
          root.currentLayout = "Unknown"
        }
      }
    }
  }

  // Process for generic keyboard layout detection using gsettings (GNOME-based)
  Process {
    id: gsettingsProcess
    running: false
    command: ["gsettings", "get", "org.gnome.desktop.input-sources", "current"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const currentIndex = parseInt(text.trim())
          gsettingsSourcesProcess.running = true
        } catch (e) {
          fallbackToLocalectl()
        }
      }
    }
  }

  Process {
    id: gsettingsSourcesProcess
    running: false
    command: ["gsettings", "get", "org.gnome.desktop.input-sources", "sources"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          // Parse the sources array and extract layout codes
          const sourcesText = text.trim()
          const matches = sourcesText.match(/\('xkb', '([^']+)'\)/g)
          if (matches && matches.length > 0) {
            // Get the first layout as default
            const layoutMatch = matches[0].match(/\('xkb', '([^']+)'\)/)
            if (layoutMatch) {
              root.currentLayout = layoutMatch[1].split('+')[0] // Take first part before any variants
            }
          } else {
            fallbackToLocalectl()
          }
        } catch (e) {
          fallbackToLocalectl()
        }
      }
    }
  }

  function fallbackToLocalectl() {
    localectlProcess.running = true
  }

  // Extract layout code from various format strings using Commons data
  function extractLayoutCode(layoutString) {
    if (!layoutString)
      return "Unknown"

    const str = layoutString.toLowerCase()

    // If it's already a short code (2-3 chars), return as-is
    if (/^[a-z]{2,3}(\+.*)?$/.test(str)) {
      return str.split('+')[0]
    }

    // Extract from parentheses like "English (US)"
    const parenMatch = str.match(/\(([a-z]{2,3})\)/)
    if (parenMatch) {
      return parenMatch[1]
    }

    // Check for exact matches or partial matches in language map from Commons
    const entries = Object.entries(KeyboardLayout.languageMap)
    for (var i = 0; i < entries.length; i++) {
      const lang = entries[i][0]
      const code = entries[i][1]
      if (str.includes(lang)) {
        return code
      }
    }

    // If nothing matches, try first 2-3 characters if they look like a code
    const codeMatch = str.match(/^([a-z]{2,3})/)
    return codeMatch ? codeMatch[1] : "unknown"
  }

  Component.onCompleted: {
    Logger.log("KeyboardLayout", "Service started")
    updateLayout()
  }

  function updateLayout() {
    // Try compositor-specific methods first
    if (CompositorService.isHyprland) {
      hyprlandLayoutProcess.running = true
    } else if (CompositorService.isNiri) {
      niriLayoutProcess.running = true
    } else {
      // Try detection methods in order of preference
      if (Qt.platform.os === "linux") {
        // Check if we're in X11 or Wayland
        const sessionType = Qt.application.arguments.find(arg => arg.includes("QT_QPA_PLATFORM")) || process.env.XDG_SESSION_TYPE

        if (sessionType && sessionType.includes("xcb") || process.env.DISPLAY) {
          // X11 system
          x11LayoutProcess.running = true
        } else {
          // Wayland or unknown - try gsettings first, then localectl
          gsettingsProcess.running = true
        }
      } else {
        currentLayout = "Unknown"
      }
    }
  }
}
