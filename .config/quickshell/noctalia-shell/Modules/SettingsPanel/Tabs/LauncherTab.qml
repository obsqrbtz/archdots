import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL * scaling

  NHeader {
    label: "Appearance"
    description: "Customize the launcher's behavior and appearance."
  }

  NComboBox {
    id: launcherPosition
    label: "Position"
    description: "Choose where the launcher panel appears."
    Layout.fillWidth: true
    model: ListModel {
      ListElement {
        key: "center"
        name: "Center (default)"
      }
      ListElement {
        key: "top_left"
        name: "Top left"
      }
      ListElement {
        key: "top_right"
        name: "Top right"
      }
      ListElement {
        key: "bottom_left"
        name: "Bottom left"
      }
      ListElement {
        key: "bottom_right"
        name: "Bottom right"
      }
      ListElement {
        key: "bottom_center"
        name: "Bottom center"
      }
      ListElement {
        key: "top_center"
        name: "Top center"
      }
    }
    currentKey: Settings.data.appLauncher.position
    onSelected: function (key) {
      Settings.data.appLauncher.position = key
    }
  }

  ColumnLayout {
    spacing: Style.marginXXS * scaling
    Layout.fillWidth: true

    NText {
      text: "Background opacity"
      font.pointSize: Style.fontSizeL * scaling
      font.weight: Style.fontWeightBold
      color: Color.mOnSurface
    }

    NText {
      text: "Adjust the background opacity of the launcher."
      font.pointSize: Style.fontSizeXS * scaling
      color: Color.mOnSurfaceVariant
      wrapMode: Text.WordWrap
      Layout.fillWidth: true
    }

    NValueSlider {
      id: launcherBgOpacity
      Layout.fillWidth: true
      from: 0.0
      to: 1.0
      stepSize: 0.01
      value: Settings.data.appLauncher.backgroundOpacity
      onMoved: value => Settings.data.appLauncher.backgroundOpacity = value
      text: Math.floor(Settings.data.appLauncher.backgroundOpacity * 100) + "%"
    }
  }

  NToggle {
    label: "Enable clipboard history"
    description: "Access previously copied items from the launcher."
    checked: Settings.data.appLauncher.enableClipboardHistory
    onToggled: checked => Settings.data.appLauncher.enableClipboardHistory = checked
  }

  NToggle {
    label: "Sort by most used"
    description: "When enabled, frequently launched apps appear first in the list."
    checked: Settings.data.appLauncher.sortByMostUsed
    onToggled: checked => Settings.data.appLauncher.sortByMostUsed = checked
  }

  NToggle {
    label: "Use App2Unit to launch applications"
    description: "Uses an alternative launch method to better manage app processes and prevent issues."
    checked: Settings.data.appLauncher.useApp2Unit
    onToggled: checked => Settings.data.appLauncher.useApp2Unit = checked
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }
}
