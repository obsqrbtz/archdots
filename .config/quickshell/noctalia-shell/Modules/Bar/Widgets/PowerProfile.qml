import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  baseSize: Style.capsuleHeight
  visible: PowerProfileService.available

  icon: PowerProfileService.getIcon()
  tooltipText: `'${PowerProfileService.getName()}' power profile`
  compact: (Settings.data.bar.density === "compact")
  colorBg: (PowerProfileService.profile === PowerProfile.Balanced) ? (Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent) : Color.mPrimary
  colorFg: (PowerProfileService.profile === PowerProfile.Balanced) ? Color.mOnSurface : Color.mOnPrimary
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent
  onClicked: PowerProfileService.cycleProfile()
}
