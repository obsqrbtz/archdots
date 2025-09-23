import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services

NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  icon: "dark-mode"
  tooltipText: `Switch to ${Settings.data.colorSchemes.darkMode ? "light" : "dark"} mode`
  compact: (Settings.data.bar.density === "compact")
  baseSize: Style.capsuleHeight
  colorBg: Settings.data.colorSchemes.darkMode ? (Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent) : Color.mPrimary
  colorFg: Settings.data.colorSchemes.darkMode ? Color.mOnSurface : Color.mOnPrimary
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent
  onClicked: Settings.data.colorSchemes.darkMode = !Settings.data.colorSchemes.darkMode
}
