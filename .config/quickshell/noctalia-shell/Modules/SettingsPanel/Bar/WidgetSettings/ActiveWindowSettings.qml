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
  property bool valueShowIcon: widgetData.showIcon !== undefined ? widgetData.showIcon : widgetMetadata.showIcon

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {})
    settings.showIcon = valueShowIcon
    return settings
  }

  NToggle {
    id: showIcon
    Layout.fillWidth: true
    label: "Show app icon"
    checked: root.valueShowIcon
    onToggled: checked => root.valueShowIcon = checked
  }
}
