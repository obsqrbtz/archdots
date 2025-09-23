import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL * scaling

  // Cache for scheme JSON (can be flat or {dark, light})
  property var schemeColorsCache: ({})

  // Scale properties for card animations
  property real cardScaleLow: 0.95
  property real cardScaleHigh: 1.0

  // Helper function to get color from scheme file (supports dark/light variants)
  function getSchemeColor(schemePath, colorKey) {
    // Extract scheme name from path
    var schemeName = schemePath.split("/").pop().replace(".json", "")

    // Try to get from cached data first
    if (schemeColorsCache[schemeName]) {
      var entry = schemeColorsCache[schemeName]
      var variant = entry
      if (entry.dark || entry.light) {
        variant = Settings.data.colorSchemes.darkMode ? (entry.dark || entry.light) : (entry.light || entry.dark)
      }
      if (variant && variant[colorKey])
        return variant[colorKey]
    }

    // Return a default color if not cached yet
    return "#000000"
  }

  // This function is called by the FileView Repeater when a scheme file is loaded
  function schemeLoaded(schemeName, jsonData) {
    var value = jsonData || {}
    var newCache = schemeColorsCache
    newCache[schemeName] = value
    schemeColorsCache = newCache
  }

  // When the list of available schemes changes, clear the cache.
  // The Repeater below will automatically re-create the FileViews.
  Connections {
    target: ColorSchemeService
    function onSchemesChanged() {
      schemeColorsCache = {}
    }
  }

  // Simple process to check if matugen exists
  Process {
    id: matugenCheck
    command: ["which", "matugen"]
    running: false

    onExited: function (exitCode) {
      if (exitCode === 0) {
        // Matugen exists, enable it
        Settings.data.colorSchemes.useWallpaperColors = true
        MatugenService.generateFromWallpaper()
        ToastService.showNotice("Matugen", "Enabled")
      } else {
        // Matugen not found
        ToastService.showWarning("Matugen", "Not installed")
      }
    }

    stdout: StdioCollector {}
    stderr: StdioCollector {}
  }

  // A non-visual Item to host the Repeater that loads the color scheme files.
  Item {
    visible: false
    id: fileLoaders

    Repeater {
      model: ColorSchemeService.schemes

      // The delegate is a Component, which correctly wraps the non-visual FileView
      delegate: Item {
        FileView {
          path: modelData
          blockLoading: true
          onLoaded: {
            var schemeName = path.split("/").pop().replace(".json", "")
            try {
              var jsonData = JSON.parse(text())
              root.schemeLoaded(schemeName, jsonData)
            } catch (e) {
              Logger.warn("ColorSchemeTab", "Failed to parse JSON for scheme:", schemeName, e)
              root.schemeLoaded(schemeName, null) // Load defaults on parse error
            }
          }
        }
      }
    }
  }

  // Main Toggles - Dark Mode / Matugen
  NHeader {
    label: "Color source"
    description: "Main settings for Noctalia's colors."
  }

  // Dark Mode Toggle (affects both Matugen and predefined schemes that provide variants)
  NToggle {
    label: "Dark mode"
    description: "Switches to a darker theme for easier viewing at night."
    checked: Settings.data.colorSchemes.darkMode
    enabled: true
    onToggled: checked => Settings.data.colorSchemes.darkMode = checked
  }

  // Use Matugen
  NToggle {
    label: "Enable Matugen"
    description: "Automatically generate colors based on your active wallpaper."
    checked: Settings.data.colorSchemes.useWallpaperColors
    onToggled: checked => {
                 if (checked) {
                   // Check if matugen is installed
                   matugenCheck.running = true
                 } else {
                   Settings.data.colorSchemes.useWallpaperColors = false
                   ToastService.showNotice("Matugen", "Disabled")

                   if (Settings.data.colorSchemes.predefinedScheme) {

                     ColorSchemeService.applyScheme(Settings.data.colorSchemes.predefinedScheme)
                   }
                 }
               }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // Predefined Color Schemes
  ColumnLayout {
    spacing: Style.marginM * scaling
    Layout.fillWidth: true

    NHeader {
      label: "Predefined color schemes"
      description: "To use these color schemes, you must turn off Matugen. With Matugen enabled, colors are automatically generated from your wallpaper."
    }

    // Color Schemes Grid
    GridLayout {
      columns: 3
      rowSpacing: Style.marginM * scaling
      columnSpacing: Style.marginM * scaling
      Layout.fillWidth: true

      Repeater {
        model: ColorSchemeService.schemes

        Rectangle {
          id: schemeCard

          property string schemePath: modelData

          Layout.fillWidth: true
          Layout.preferredHeight: 120 * scaling
          radius: Style.radiusM * scaling
          color: getSchemeColor(modelData, "mSurface")
          border.width: Math.max(1, Style.borderL * scaling)
          border.color: (!Settings.data.colorSchemes.useWallpaperColors && (Settings.data.colorSchemes.predefinedScheme === modelData.split("/").pop().replace(".json", ""))) ? Color.mSecondary : Color.mOutline
          scale: root.cardScaleLow

          // Mouse area for selection
          MouseArea {
            anchors.fill: parent
            onClicked: {
              // Disable useWallpaperColors when picking a predefined color scheme
              Settings.data.colorSchemes.useWallpaperColors = false
              Logger.log("ColorSchemeTab", "Disabled matugen setting")

              Settings.data.colorSchemes.predefinedScheme = schemePath.split("/").pop().replace(".json", "")
              ColorSchemeService.applyScheme(Settings.data.colorSchemes.predefinedScheme)
            }
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: {
              schemeCard.scale = root.cardScaleHigh
            }

            onExited: {
              schemeCard.scale = root.cardScaleLow
            }
          }

          // Card content
          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginXL * scaling
            spacing: Style.marginS * scaling

            // Scheme name
            NText {
              text: {
                // Remove json and the full path
                var chunks = schemePath.replace(".json", "").split("/")
                return chunks[chunks.length - 1]
              }
              font.pointSize: Style.fontSizeM * scaling
              font.weight: Style.fontWeightBold
              color: getSchemeColor(modelData, "mOnSurface")
              Layout.fillWidth: true
              elide: Text.ElideRight
              horizontalAlignment: Text.AlignHCenter
            }

            // Color swatches
            RowLayout {
              id: swatches

              spacing: Style.marginS * scaling
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignHCenter

              readonly property int swatchSize: 20 * scaling

              // Primary color swatch
              Rectangle {
                width: swatches.swatchSize
                height: swatches.swatchSize
                radius: width * 0.5
                color: getSchemeColor(modelData, "mPrimary")
              }

              // Secondary color swatch
              Rectangle {
                width: swatches.swatchSize
                height: swatches.swatchSize
                radius: width * 0.5
                color: getSchemeColor(modelData, "mSecondary")
              }

              // Tertiary color swatch
              Rectangle {
                width: swatches.swatchSize
                height: swatches.swatchSize
                radius: width * 0.5
                color: getSchemeColor(modelData, "mTertiary")
              }

              // Error color swatch
              Rectangle {
                width: swatches.swatchSize
                height: swatches.swatchSize
                radius: width * 0.5
                color: getSchemeColor(modelData, "mError")
              }
            }
          }

          // Selection indicator (Checkmark)
          Rectangle {
            visible: !Settings.data.colorSchemes.useWallpaperColors && (Settings.data.colorSchemes.predefinedScheme === schemePath.split("/").pop().replace(".json", ""))
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Style.marginS * scaling
            width: 28 * scaling
            height: 28 * scaling
            radius: width * 0.5
            color: Color.mSecondary

            NIcon {
              icon: "check"
              font.pointSize: Style.fontSizeM * scaling
              font.weight: Style.fontWeightBold
              color: Color.mOnSecondary
              anchors.centerIn: parent
            }
          }

          // Smooth animations
          Behavior on scale {
            NumberAnimation {
              duration: Style.animationNormal
              easing.type: Easing.OutCubic
            }
          }

          Behavior on border.color {
            ColorAnimation {
              duration: Style.animationNormal
            }
          }

          Behavior on border.width {
            NumberAnimation {
              duration: Style.animationFast
            }
          }
        }
      }
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
    visible: Settings.data.colorSchemes.useWallpaperColors
  }

  // Matugen template toggles organized by category
  ColumnLayout {
    Layout.fillWidth: true
    visible: Settings.data.colorSchemes.useWallpaperColors
    spacing: Style.marginL * scaling

    // UI Components
    NCollapsible {
      Layout.fillWidth: true
      label: "UI"
      description: "Desktop environment and UI toolkit theming."
      defaultExpanded: false

      NCheckbox {
        label: "GTK 4 (libadwaita)"
        description: "Write ~/.config/gtk-4.0/gtk.css"
        checked: Settings.data.matugen.gtk4
        onToggled: checked => {
                     Settings.data.matugen.gtk4 = checked
                     if (Settings.data.colorSchemes.useWallpaperColors)
                     MatugenService.generateFromWallpaper()
                   }
      }

      NCheckbox {
        label: "GTK 3"
        description: "Write ~/.config/gtk-3.0/gtk.css"
        checked: Settings.data.matugen.gtk3
        onToggled: checked => {
                     Settings.data.matugen.gtk3 = checked
                     if (Settings.data.colorSchemes.useWallpaperColors)
                     MatugenService.generateFromWallpaper()
                   }
      }

      NCheckbox {
        label: "Qt6ct"
        description: "Write ~/.config/qt6ct/colors/noctalia.conf"
        checked: Settings.data.matugen.qt6
        onToggled: checked => {
                     Settings.data.matugen.qt6 = checked
                     if (Settings.data.colorSchemes.useWallpaperColors)
                     MatugenService.generateFromWallpaper()
                   }
      }

      NCheckbox {
        label: "Qt5ct"
        description: "Write ~/.config/qt5ct/colors/noctalia.conf"
        checked: Settings.data.matugen.qt5
        onToggled: checked => {
                     Settings.data.matugen.qt5 = checked
                     if (Settings.data.colorSchemes.useWallpaperColors)
                     MatugenService.generateFromWallpaper()
                   }
      }
    }

    // Terminal Emulators
    NCollapsible {
      Layout.fillWidth: true
      label: "Terminal"
      description: "Terminal emulator theming."
      defaultExpanded: false

      NCheckbox {
        label: "Kitty"
        description: ProgramCheckerService.kittyAvailable ? "Write ~/.config/kitty/themes/noctalia.conf and reload" : "Requires kitty terminal to be installed"
        checked: Settings.data.matugen.kitty
        enabled: ProgramCheckerService.kittyAvailable
        opacity: ProgramCheckerService.kittyAvailable ? 1.0 : 0.6
        onToggled: checked => {
                     if (ProgramCheckerService.kittyAvailable) {
                       Settings.data.matugen.kitty = checked
                       if (Settings.data.colorSchemes.useWallpaperColors)
                       MatugenService.generateFromWallpaper()
                     }
                   }
      }

      NCheckbox {
        label: "Ghostty"
        description: ProgramCheckerService.ghosttyAvailable ? "Write ~/.config/ghostty/themes/noctalia and reload" : "Requires ghostty terminal to be installed"
        checked: Settings.data.matugen.ghostty
        enabled: ProgramCheckerService.ghosttyAvailable
        opacity: ProgramCheckerService.ghosttyAvailable ? 1.0 : 0.6
        onToggled: checked => {
                     if (ProgramCheckerService.ghosttyAvailable) {
                       Settings.data.matugen.ghostty = checked
                       if (Settings.data.colorSchemes.useWallpaperColors)
                       MatugenService.generateFromWallpaper()
                     }
                   }
      }

      NCheckbox {
        label: "Foot"
        description: ProgramCheckerService.footAvailable ? "Write ~/.config/foot/themes/noctalia and reload" : "Requires foot terminal to be installed"
        checked: Settings.data.matugen.foot
        enabled: ProgramCheckerService.footAvailable
        opacity: ProgramCheckerService.footAvailable ? 1.0 : 0.6
        onToggled: checked => {
                     if (ProgramCheckerService.footAvailable) {
                       Settings.data.matugen.foot = checked
                       if (Settings.data.colorSchemes.useWallpaperColors)
                       MatugenService.generateFromWallpaper()
                     }
                   }
      }
    }

    // Applications
    NCollapsible {
      Layout.fillWidth: true
      label: "Programs"
      description: "Application-specific theming."
      defaultExpanded: false

      NCheckbox {
        label: "Fuzzel"
        description: ProgramCheckerService.fuzzelAvailable ? "Write ~/.config/fuzzel/themes/noctalia and reload" : "Requires fuzzel launcher to be installed"
        checked: Settings.data.matugen.fuzzel
        enabled: ProgramCheckerService.fuzzelAvailable
        opacity: ProgramCheckerService.fuzzelAvailable ? 1.0 : 0.6
        onToggled: checked => {
                     if (ProgramCheckerService.fuzzelAvailable) {
                       Settings.data.matugen.fuzzel = checked
                       if (Settings.data.colorSchemes.useWallpaperColors)
                       MatugenService.generateFromWallpaper()
                     }
                   }
      }

      NCheckbox {
        label: "Vesktop"
        description: ProgramCheckerService.vesktopAvailable ? "Write ~/.config/vesktop/themes/noctalia.theme.css" : "Requires vesktop Discord client to be installed"
        checked: Settings.data.matugen.vesktop
        enabled: ProgramCheckerService.vesktopAvailable
        opacity: ProgramCheckerService.vesktopAvailable ? 1.0 : 0.6
        onToggled: checked => {
                     if (ProgramCheckerService.vesktopAvailable) {
                       Settings.data.matugen.vesktop = checked
                       if (Settings.data.colorSchemes.useWallpaperColors)
                       MatugenService.generateFromWallpaper()
                     }
                   }
      }

      NCheckbox {
        label: "Pywalfox (Firefox)"
        description: ProgramCheckerService.pywalfoxAvailable ? "Write ~/.cache/wal/colors.json and run pywalfox update" : "Requires pywalfox package to be installed"
        checked: Settings.data.matugen.pywalfox
        enabled: ProgramCheckerService.pywalfoxAvailable
        opacity: ProgramCheckerService.pywalfoxAvailable ? 1.0 : 0.6
        onToggled: checked => {
                     if (ProgramCheckerService.pywalfoxAvailable) {
                       Settings.data.matugen.pywalfox = checked
                       if (Settings.data.colorSchemes.useWallpaperColors)
                       MatugenService.generateFromWallpaper()
                     }
                   }
      }
    }

    // Miscellaneous
    NCollapsible {
      Layout.fillWidth: true
      label: "Misc"
      description: "Additional configuration options."
      defaultExpanded: false

      NCheckbox {
        label: "User templates"
        description: "Enable user-defined Matugen config from ~/.config/matugen/config.toml"
        checked: Settings.data.matugen.enableUserTemplates
        onToggled: checked => {
                     Settings.data.matugen.enableUserTemplates = checked
                     if (Settings.data.colorSchemes.useWallpaperColors)
                     MatugenService.generateFromWallpaper()
                   }
      }
    }
  }
}
