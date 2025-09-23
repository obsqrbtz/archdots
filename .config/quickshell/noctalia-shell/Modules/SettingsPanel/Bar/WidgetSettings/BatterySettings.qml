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
  property string valueDisplayMode: widgetData.displayMode !== undefined ? widgetData.displayMode : widgetMetadata.displayMode
  property int valueWarningThreshold: widgetData.warningThreshold !== undefined ? widgetData.warningThreshold : widgetMetadata.warningThreshold

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {})
    settings.displayMode = valueDisplayMode
    settings.warningThreshold = valueWarningThreshold
    return settings
  }

  NComboBox {
    label: "Display mode"
    description: "Choose how you'd like this value to appear."
    minimumWidth: 134 * scaling
    model: ListModel {
      ListElement {
        key: "onhover"
        name: "On hover"
      }
      ListElement {
        key: "alwaysShow"
        name: "Always show"
      }
      ListElement {
        key: "alwaysHide"
        name: "Always hide"
      }
    }
    currentKey: root.valueDisplayMode
    onSelected: key => root.valueDisplayMode = key
  }

  NSpinBox {
    label: "Low battery warning threshold"
    description: "Show a warning when battery falls below this percentage."
    value: valueWarningThreshold
    suffix: "%"
    minimum: 5
    maximum: 50
    onValueChanged: valueWarningThreshold = value
  }
}
