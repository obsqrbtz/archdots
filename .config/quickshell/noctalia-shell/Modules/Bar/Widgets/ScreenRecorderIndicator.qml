import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets

// Screen Recording Indicator
NIconButton {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  icon: "camera-video"
  tooltipText: ScreenRecorderService.isRecording ? "Click to stop recording" : "Click to start recording"
  compact: (Settings.data.bar.density === "compact")
  baseSize: Style.capsuleHeight
  colorBg: ScreenRecorderService.isRecording ? Color.mPrimary : (Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent)
  colorFg: ScreenRecorderService.isRecording ? Color.mOnPrimary : Color.mOnSurface
  colorBorder: Color.transparent
  colorBorderHover: Color.transparent
  onClicked: ScreenRecorderService.toggleRecording()
}
