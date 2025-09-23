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
    settings.width = parseInt(widthInput.text) || widgetMetadata.width
    return settings
  }

  NTextInput {
    id: widthInput
    Layout.fillWidth: true
    label: "Width"
    description: "Spacing width in pixels"
    text: widgetData.width || widgetMetadata.width
    placeholderText: "Enter width in pixels"
  }
}
