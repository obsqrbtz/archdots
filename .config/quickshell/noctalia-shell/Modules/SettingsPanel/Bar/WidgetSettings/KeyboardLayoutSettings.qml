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

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {})
    settings.displayMode = valueDisplayMode
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
        key: "forceOpen"
        name: "Force Open"
      }
      ListElement {
        key: "alwaysHide"
        name: "Always hide"
      }
    }
    currentKey: valueDisplayMode
    onSelected: key => valueDisplayMode = key
  }
}
