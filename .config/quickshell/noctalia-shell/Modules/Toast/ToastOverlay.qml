import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets

Variants {
  model: Quickshell.screens

  delegate: ToastScreen {
    required property ShellScreen modelData

    screen: modelData
    scaling: ScalingService.getScreenScale(modelData)

    // Only activate on enabled screens
    active: Settings.isLoaded && modelData && (Settings.data.notifications.monitors.includes(modelData.name) || Settings.data.notifications.monitors.length === 0)
  }
}
