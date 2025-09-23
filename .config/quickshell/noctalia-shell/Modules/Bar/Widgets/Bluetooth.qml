import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  baseSize: Style.capsuleHeight
  compact: (Settings.data.bar.density === "compact")
  colorBg: Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent
  colorFg: Color.mOnSurface
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent

  icon: Settings.data.network.bluetoothEnabled ? "bluetooth" : "bluetooth-off"
  tooltipText: "Bluetooth devices"
  onClicked: PanelService.getPanel("bluetoothPanel")?.toggle(this)
  onRightClicked: PanelService.getPanel("bluetoothPanel")?.toggle(this)
}
