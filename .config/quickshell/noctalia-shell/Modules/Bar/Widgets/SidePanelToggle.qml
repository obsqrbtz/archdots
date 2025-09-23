import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Effects
import qs.Commons
import qs.Widgets
import qs.Services

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property var widgetMetadata: BarWidgetRegistry.widgetMetadata[widgetId]
  property var widgetSettings: {
    if (section && sectionWidgetIndex >= 0) {
      var widgets = Settings.data.bar.widgets[section]
      if (widgets && sectionWidgetIndex < widgets.length) {
        return widgets[sectionWidgetIndex]
      }
    }
    return {}
  }

  readonly property string customIcon: widgetSettings.icon || widgetMetadata.icon
  readonly property bool useDistroLogo: (widgetSettings.useDistroLogo !== undefined) ? widgetSettings.useDistroLogo : widgetMetadata.useDistroLogo

  icon: useDistroLogo ? "" : customIcon
  tooltipText: "Open side panel"
  baseSize: Style.capsuleHeight
  compact: (Settings.data.bar.density === "compact")
  colorBg: (Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent)
  colorFg: Color.mOnSurface
  colorBgHover: useDistroLogo ? Color.mSurfaceVariant : Color.mTertiary
  colorBorder: Color.transparent
  colorBorderHover: useDistroLogo ? Color.mTertiary : Color.transparent
  onClicked: PanelService.getPanel("sidePanel")?.toggle(this)
  onRightClicked: PanelService.getPanel("settingsPanel")?.toggle()

  IconImage {
    id: logo
    anchors.centerIn: parent
    width: root.width * 0.8
    height: width
    source: useDistroLogo ? DistroLogoService.osLogo : ""
    visible: useDistroLogo && source !== ""
    smooth: true
    asynchronous: true
  }
}
