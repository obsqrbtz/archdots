import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services

ColumnLayout {
  id: root
  spacing: Style.marginM * scaling

  // Properties to receive data from parent
  property var widgetData: null
  property var widgetMetadata: null

  // Local state
  property string valueIcon: widgetData.icon !== undefined ? widgetData.icon : widgetMetadata.icon
  property bool valueUseDistroLogo: widgetData.useDistroLogo !== undefined ? widgetData.useDistroLogo : widgetMetadata.useDistroLogo

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {})
    settings.icon = valueIcon
    settings.useDistroLogo = valueUseDistroLogo
    return settings
  }

  NToggle {
    label: "Use distro logo instead of icon"
    checked: valueUseDistroLogo
    onToggled: checked => valueUseDistroLogo = checked
  }

  RowLayout {
    spacing: Style.marginM * scaling

    NLabel {
      label: "Icon"
      description: "Select an icon from the library."
    }

    NIcon {
      Layout.alignment: Qt.AlignVCenter
      icon: valueIcon
      font.pointSize: Style.fontSizeXL * scaling
      visible: valueIcon !== ""
    }

    NButton {
      enabled: !valueUseDistroLogo
      text: "Browse"
      onClicked: iconPicker.open()
    }
  }

  NIconPicker {
    id: iconPicker
    initialIcon: valueIcon
    onIconSelected: function (iconName) {
      valueIcon = iconName
    }
  }
}
