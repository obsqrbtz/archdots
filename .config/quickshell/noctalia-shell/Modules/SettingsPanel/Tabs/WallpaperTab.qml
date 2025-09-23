import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL * scaling

  NHeader {
    label: "Wallpaper settings"
    description: "Control how wallpapers are managed and displayed."
  }

  NToggle {
    label: "Enable wallpaper management"
    description: "Manage wallpapers with Noctalia. (Uncheck if you prefer using another application)."
    checked: Settings.data.wallpaper.enabled
    onToggled: checked => Settings.data.wallpaper.enabled = checked
    Layout.bottomMargin: Style.marginL * scaling
  }

  ColumnLayout {
    visible: Settings.data.wallpaper.enabled
    spacing: Style.marginL * scaling
    Layout.fillWidth: true

    NInputButton {
      id: wallpaperPathInput
      label: "Wallpaper folder"
      description: "Path to your main wallpaper folder."
      text: Settings.data.wallpaper.directory
      buttonIcon: "folder-open"
      buttonTooltip: "Browse for wallpaper folder"
      Layout.fillWidth: true

      onInputEditingFinished: {
        Settings.data.wallpaper.directory = text
      }
      onButtonClicked: {
        openFileManager()
      }
    }

    // Monitor-specific directories
    NToggle {
      label: "Monitor-specific directories"
      description: "Set a different wallpaper folder for each monitor."
      checked: Settings.data.wallpaper.enableMultiMonitorDirectories
      onToggled: checked => Settings.data.wallpaper.enableMultiMonitorDirectories = checked
    }

    NBox {
      visible: Settings.data.wallpaper.enableMultiMonitorDirectories

      Layout.fillWidth: true
      Layout.minimumWidth: 550 * scaling
      radius: Style.radiusM * scaling
      color: Color.mSurfaceVariant
      border.color: Color.mOutline
      border.width: Math.max(1, Style.borderS * scaling)
      implicitHeight: contentCol.implicitHeight + Style.marginXL * 2 * scaling

      ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: Style.marginXL * scaling
        spacing: Style.marginM * scaling
        Repeater {
          model: Quickshell.screens || []
          delegate: ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS * scaling

            NText {
              text: (modelData.name || "Unknown")
              color: Color.mPrimary
              font.weight: Style.fontWeightBold
              font.pointSize: Style.fontSizeM * scaling
            }

            NInputButton {
              text: WallpaperService.getMonitorDirectory(modelData.name)
              buttonIcon: "folder-open"
              buttonTooltip: "Browse for wallpaper folder"
              Layout.fillWidth: true

              onInputEditingFinished: {
                WallpaperService.setMonitorDirectory(modelData.name, text)
              }
              onButtonClicked: {
                openMonitorFileManager(modelData.name)
              }
            }
          }
        }
      }
    }
  }

  NDivider {
    visible: Settings.data.wallpaper.enabled
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  ColumnLayout {
    visible: Settings.data.wallpaper.enabled
    spacing: Style.marginL * scaling
    Layout.fillWidth: true

    NHeader {
      label: "Look & feel"
    }

    // Fill Mode
    NComboBox {
      label: "Fill mode"
      description: "Select how the image should scale to match your monitor's resolution."
      model: WallpaperService.fillModeModel
      currentKey: Settings.data.wallpaper.fillMode
      onSelected: key => Settings.data.wallpaper.fillMode = key
    }

    RowLayout {
      NLabel {
        label: "Fill color"
        description: "Choose a fill color that may appear behind the wallpaper."
        Layout.alignment: Qt.AlignTop
      }

      NColorPicker {
        selectedColor: Settings.data.wallpaper.fillColor
        onColorSelected: color => Settings.data.wallpaper.fillColor = color
      }
    }

    // Transition Type
    NComboBox {
      label: "Transition type"
      description: "Animation type when switching between wallpapers."
      model: WallpaperService.transitionsModel
      currentKey: Settings.data.wallpaper.transitionType
      onSelected: key => Settings.data.wallpaper.transitionType = key
    }

    // Transition Duration
    ColumnLayout {
      NLabel {
        label: "Transition duration"
        description: "Duration of transition animations in seconds."
      }

      NValueSlider {
        Layout.fillWidth: true
        from: 500
        to: 10000
        stepSize: 100
        value: Settings.data.wallpaper.transitionDuration
        onMoved: value => Settings.data.wallpaper.transitionDuration = value
        text: (Settings.data.wallpaper.transitionDuration / 1000).toFixed(1) + "s"
      }
    }

    // Edge Smoothness
    ColumnLayout {
      NLabel {
        label: "Soften transition edge"
        description: "Applies a soft, feathered effect to the edge of transitions."
      }

      NValueSlider {
        Layout.fillWidth: true
        from: 0.0
        to: 1.0
        value: Settings.data.wallpaper.transitionEdgeSmoothness
        onMoved: value => Settings.data.wallpaper.transitionEdgeSmoothness = value
        text: Math.round(Settings.data.wallpaper.transitionEdgeSmoothness * 100) + "%"
      }
    }
  }

  NDivider {
    visible: Settings.data.wallpaper.enabled
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  ColumnLayout {
    visible: Settings.data.wallpaper.enabled
    spacing: Style.marginL * scaling
    Layout.fillWidth: true

    NHeader {
      label: "Automation"
    }

    // Random Wallpaper
    NToggle {
      label: "Random wallpaper"
      description: "Schedule random wallpaper changes at regular intervals."
      checked: Settings.data.wallpaper.randomEnabled
      onToggled: checked => Settings.data.wallpaper.randomEnabled = checked
    }

    // Interval
    ColumnLayout {
      visible: Settings.data.wallpaper.randomEnabled
      RowLayout {
        NLabel {
          label: "Wallpaper interval"
          description: "How often to change wallpapers automatically."
          Layout.fillWidth: true
        }

        NText {
          // Show friendly H:MM format from current settings
          text: Time.formatVagueHumanReadableDuration(Settings.data.wallpaper.randomIntervalSec)
          Layout.alignment: Qt.AlignBottom | Qt.AlignRight
        }
      }

      // Preset chips using Repeater
      RowLayout {
        id: presetRow
        spacing: Style.marginS * scaling

        // Factorized presets data
        property var intervalPresets: [5 * 60, 10 * 60, 15 * 60, 30 * 60, 45 * 60, 60 * 60, 90 * 60, 120 * 60]

        // Whether current interval equals one of the presets
        property bool isCurrentPreset: {
          return intervalPresets.some(seconds => seconds === Settings.data.wallpaper.randomIntervalSec)
        }
        // Allow user to force open the custom input; otherwise it's auto-open when not a preset
        property bool customForcedVisible: false

        function setIntervalSeconds(sec) {
          Settings.data.wallpaper.randomIntervalSec = sec
          WallpaperService.restartRandomWallpaperTimer()
          // Hide custom when selecting a preset
          customForcedVisible = false
        }

        // Helper to color selected chip
        function isSelected(sec) {
          return Settings.data.wallpaper.randomIntervalSec === sec
        }

        // Repeater for preset chips
        Repeater {
          model: presetRow.intervalPresets
          delegate: IntervalPresetChip {
            seconds: modelData
            label: Time.formatVagueHumanReadableDuration(modelData)
            selected: presetRow.isSelected(modelData)
            onClicked: presetRow.setIntervalSeconds(modelData)
          }
        }

        // Custom… opens inline input
        IntervalPresetChip {
          label: customRow.visible ? "Custom" : "Custom…"
          selected: customRow.visible
          onClicked: presetRow.customForcedVisible = !presetRow.customForcedVisible
        }
      }

      // Custom HH:MM inline input
      RowLayout {
        id: customRow
        visible: presetRow.customForcedVisible || !presetRow.isCurrentPreset
        spacing: Style.marginS * scaling
        Layout.topMargin: Style.marginS * scaling

        NTextInput {
          label: "Custom interval"
          description: "Enter time as HH:MM (e.g., 01:30)."
          text: {
            const s = Settings.data.wallpaper.randomIntervalSec
            const h = Math.floor(s / 3600)
            const m = Math.floor((s % 3600) / 60)
            return h + ":" + (m < 10 ? ("0" + m) : m)
          }
          onEditingFinished: {
            const m = text.trim().match(/^(\d{1,2}):(\d{2})$/)
            if (m) {
              let h = parseInt(m[1])
              let min = parseInt(m[2])
              if (isNaN(h) || isNaN(min))
                return
              h = Math.max(0, Math.min(24, h))
              min = Math.max(0, Math.min(59, min))
              Settings.data.wallpaper.randomIntervalSec = (h * 3600) + (min * 60)
              WallpaperService.restartRandomWallpaperTimer()
              // Keep custom visible after manual entry
              presetRow.customForcedVisible = true
            }
          }
        }
      }
    }
  }

  // Reusable component for interval preset chips
  component IntervalPresetChip: Rectangle {
    property int seconds: 0
    property string label: ""
    property bool selected: false
    signal clicked

    radius: height * 0.5
    color: selected ? Color.mPrimary : Color.mSurfaceVariant
    implicitHeight: Math.max(Style.baseWidgetSize * 0.55 * scaling, 24 * scaling)
    implicitWidth: chipLabel.implicitWidth + Style.marginM * 1.5 * scaling
    border.width: 1
    border.color: selected ? Color.transparent : Color.mOutline

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: parent.clicked()
    }

    NText {
      id: chipLabel
      anchors.centerIn: parent
      text: parent.label
      font.pointSize: Style.fontSizeS * scaling
      color: parent.selected ? Color.mOnPrimary : Color.mOnSurface
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // File manager functions
  function openFileManager() {
    FilePickerService.open({
                             "title": "Select Wallpaper Folder",
                             "initialPath": Settings.data.wallpaper.directory || Quickshell.env("HOME"),
                             "selectFiles": false,
                             "scaling": scaling,
                             "parent": root,
                             "onSelected": path => Settings.data.wallpaper.directory = path
                           })
  }

  function openMonitorFileManager(monitorName) {
    FilePickerService.open({
                             "title": "Select Monitor Wallpaper Folder",
                             "initialPath": WallpaperService.getMonitorDirectory(monitorName),
                             "selectFiles": false,
                             "scaling": scaling,
                             "parent": root,
                             "onSelected": path => WallpaperService.setMonitorDirectory(monitorName, path)
                           })
  }
}
