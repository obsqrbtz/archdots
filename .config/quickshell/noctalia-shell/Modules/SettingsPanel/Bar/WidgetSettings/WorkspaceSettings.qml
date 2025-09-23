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

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {})
    settings.labelMode = labelModeCombo.currentKey
    settings.hideUnoccupied = hideUnoccupiedToggle.checked
    return settings
  }

  NComboBox {
    id: labelModeCombo

    label: "Label Mode"
    model: ListModel {
      ListElement {
        key: "none"
        name: "None"
      }
      ListElement {
        key: "index"
        name: "Index"
      }
      ListElement {
        key: "name"
        name: "Name"
      }
    }
    currentKey: widgetData.labelMode || widgetMetadata.labelMode
    onSelected: key => labelModeCombo.currentKey = key
    minimumWidth: 200 * scaling
  }

  NToggle {
    id: hideUnoccupiedToggle
    label: "Hide unoccupied"
    description: "Don't display workspaces without windows."
    checked: widgetData.hideUnoccupied
    onToggled: checked => hideUnoccupiedToggle.checked = checked
  }
}
