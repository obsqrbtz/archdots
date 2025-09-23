pragma Singleton

import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Commons.IconsSets

Singleton {
  id: root

  // Expose the font family name for easy access
  readonly property string fontFamily: fontLoader.name
  readonly property string defaultIcon: TablerIcons.defaultIcon
  readonly property var icons: TablerIcons.icons
  readonly property var aliases: TablerIcons.aliases
  readonly property string fontPath: "/Assets/Fonts/tabler/tabler-icons.ttf"

  Component.onCompleted: {
    Logger.log("Icons", "Service started")
  }

  function get(iconName) {
    // Check in aliases first
    if (aliases[iconName] !== undefined) {
      iconName = aliases[iconName]
    }

    // Find the appropriate codepoint
    return icons[iconName]
  }

  FontLoader {
    id: fontLoader
    source: Quickshell.shellDir + fontPath
  }

  // Monitor font loading status
  Connections {
    target: fontLoader
    function onStatusChanged() {
      if (fontLoader.status === FontLoader.Ready) {
        Logger.log("Icons", "Font loaded successfully:", fontFamily)
      } else if (fontLoader.status === FontLoader.Error) {
        Logger.error("Icons", "Font failed to load")
      }
    }
  }
}
