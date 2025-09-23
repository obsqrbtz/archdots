import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  baseSize: Style.capsuleHeight
  compact: (Settings.data.bar.density === "compact")
  icon: IdleInhibitorService.isInhibited ? "keep-awake-on" : "keep-awake-off"
  tooltipText: IdleInhibitorService.isInhibited ? "Disable keep awake" : "Enable keep awake"
  colorBg: IdleInhibitorService.isInhibited ? Color.mPrimary : (Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent)
  colorFg: IdleInhibitorService.isInhibited ? Color.mOnPrimary : Color.mOnSurface
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent
  onClicked: IdleInhibitorService.manualToggle()
}
