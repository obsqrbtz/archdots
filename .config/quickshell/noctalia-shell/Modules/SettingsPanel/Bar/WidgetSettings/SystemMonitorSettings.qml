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

  // Local, editable state for checkboxes
  property bool valueShowCpuUsage: widgetData.showCpuUsage !== undefined ? widgetData.showCpuUsage : widgetMetadata.showCpuUsage
  property bool valueShowCpuTemp: widgetData.showCpuTemp !== undefined ? widgetData.showCpuTemp : widgetMetadata.showCpuTemp
  property bool valueShowMemoryUsage: widgetData.showMemoryUsage !== undefined ? widgetData.showMemoryUsage : widgetMetadata.showMemoryUsage
  property bool valueShowMemoryAsPercent: widgetData.showMemoryAsPercent !== undefined ? widgetData.showMemoryAsPercent : widgetMetadata.showMemoryAsPercent
  property bool valueShowNetworkStats: widgetData.showNetworkStats !== undefined ? widgetData.showNetworkStats : widgetMetadata.showNetworkStats
  property bool valueShowDiskUsage: widgetData.showDiskUsage !== undefined ? widgetData.showDiskUsage : widgetMetadata.showDiskUsage

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {})
    settings.showCpuUsage = valueShowCpuUsage
    settings.showCpuTemp = valueShowCpuTemp
    settings.showMemoryUsage = valueShowMemoryUsage
    settings.showMemoryAsPercent = valueShowMemoryAsPercent
    settings.showNetworkStats = valueShowNetworkStats
    settings.showDiskUsage = valueShowDiskUsage
    return settings
  }

  NToggle {
    id: showCpuUsage
    Layout.fillWidth: true
    label: "CPU usage"
    checked: valueShowCpuUsage
    onToggled: checked => valueShowCpuUsage = checked
  }

  NToggle {
    id: showCpuTemp
    Layout.fillWidth: true
    label: "CPU temperature"
    checked: valueShowCpuTemp
    onToggled: checked => valueShowCpuTemp = checked
  }

  NToggle {
    id: showMemoryUsage
    Layout.fillWidth: true
    label: "Memory usage"
    checked: valueShowMemoryUsage
    onToggled: checked => valueShowMemoryUsage = checked
  }

  NToggle {
    id: showMemoryAsPercent
    Layout.fillWidth: true
    label: "Memory as percentage"
    checked: valueShowMemoryAsPercent
    onToggled: checked => valueShowMemoryAsPercent = checked
  }

  NToggle {
    id: showNetworkStats
    Layout.fillWidth: true
    label: "Network traffic"
    checked: valueShowNetworkStats
    onToggled: checked => valueShowNetworkStats = checked
  }

  NToggle {
    id: showDiskUsage
    Layout.fillWidth: true
    label: "Storage usage"
    checked: valueShowDiskUsage
    onToggled: checked => valueShowDiskUsage = checked
  }
}
