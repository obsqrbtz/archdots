import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import qs.Commons
import qs.Widgets
import qs.Services

ColumnLayout {
  id: root
  spacing: Style.marginM * scaling

  property var widgetData: null
  property var widgetMetadata: null

  property string valueIcon: widgetData.icon !== undefined ? widgetData.icon : widgetMetadata.icon

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {})
    settings.icon = valueIcon
    settings.leftClickExec = leftClickExecInput.text
    settings.rightClickExec = rightClickExecInput.text
    settings.middleClickExec = middleClickExecInput.text
    settings.textCommand = textCommandInput.text
    settings.textIntervalMs = parseInt(textIntervalInput.text || textIntervalInput.placeholderText, 10)
    return settings
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

  NTextInput {
    id: leftClickExecInput
    Layout.fillWidth: true
    label: "Left click"
    placeholderText: "Enter command to execute (app or custom script)"
    text: widgetData?.leftClickExec || widgetMetadata.leftClickExec
  }

  NTextInput {
    id: rightClickExecInput
    Layout.fillWidth: true
    label: "Right click"
    placeholderText: "Enter command to execute (app or custom script)"
    text: widgetData?.rightClickExec || widgetMetadata.rightClickExec
  }

  NTextInput {
    id: middleClickExecInput
    Layout.fillWidth: true
    label: "Middle click"
    placeholderText: "Enter command to execute (app or custom script)"
    text: widgetData.middleClickExec || widgetMetadata.middleClickExec
  }

  NDivider {
    Layout.fillWidth: true
  }

  NHeader {
    label: "Dynamic text"
  }

  NTextInput {
    id: textCommandInput
    Layout.fillWidth: true
    label: "Display Command Output"
    description: "Enter a command to run at a regular interval. The first line of its output will be displayed as text."
    placeholderText: "echo \"Hello World\""
    text: widgetData?.textCommand || widgetMetadata.textCommand
  }

  NTextInput {
    id: textIntervalInput
    Layout.fillWidth: true
    label: "Refresh interval"
    description: "Interval in milliseconds."
    placeholderText: String(widgetMetadata.textIntervalMs || 3000)
    text: widgetData && widgetData.textIntervalMs !== undefined ? String(widgetData.textIntervalMs) : ""
  }
}
