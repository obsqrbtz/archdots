import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Modules.SettingsPanel
import qs.Services
import qs.Widgets
import qs.Modules.Bar.Extras

Item {
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

  readonly property bool isBarVertical: Settings.data.bar.position === "left" || Settings.data.bar.position === "right"
  readonly property string displayMode: (widgetSettings.displayMode !== undefined) ? widgetSettings.displayMode : widgetMetadata.displayMode

  // Used to avoid opening the pill on Quickshell startup
  property bool firstInputVolumeReceived: false
  property int wheelAccumulator: 0

  implicitWidth: pill.width
  implicitHeight: pill.height

  function getIcon() {
    if (AudioService.inputMuted) {
      return "microphone-mute"
    }
    return (AudioService.inputVolume <= Number.EPSILON) ? "microphone-mute" : "microphone"
  }

  // Connection used to open the pill when input volume changes
  Connections {
    target: AudioService.source?.audio ? AudioService.source?.audio : null
    function onVolumeChanged() {
      // Logger.log("Bar:Microphone", "onInputVolumeChanged")
      if (!firstInputVolumeReceived) {
        // Ignore the first volume change
        firstInputVolumeReceived = true
      } else {
        pill.show()
        externalHideTimer.restart()
      }
    }
  }

  // Connection used to open the pill when input mute state changes
  Connections {
    target: AudioService.source?.audio ? AudioService.source?.audio : null
    function onMutedChanged() {
      // Logger.log("Bar:Microphone", "onInputMutedChanged")
      if (!firstInputVolumeReceived) {
        // Ignore the first mute change
        firstInputVolumeReceived = true
      } else {
        pill.show()
        externalHideTimer.restart()
      }
    }
  }

  Timer {
    id: externalHideTimer
    running: false
    interval: 1500
    onTriggered: {
      pill.hide()
    }
  }

  BarPill {
    id: pill
    rightOpen: BarService.getPillDirection(root)
    icon: getIcon()
    compact: (Settings.data.bar.density === "compact")
    autoHide: false // Important to be false so we can hover as long as we want
    text: Math.floor(AudioService.inputVolume * 100)
    suffix: "%"
    forceOpen: displayMode === "alwaysShow"
    forceClose: displayMode === "alwaysHide"
    tooltipText: "Microphone volume at " + Math.round(AudioService.inputVolume * 100) + "%\nLeft click to toggle mute. Right click for settings.\nScroll to modify volume."

    onWheel: function (delta) {
      wheelAccumulator += delta
      if (wheelAccumulator >= 120) {
        wheelAccumulator = 0
        AudioService.setInputVolume(AudioService.inputVolume + AudioService.stepVolume)
      } else if (wheelAccumulator <= -120) {
        wheelAccumulator = 0
        AudioService.setInputVolume(AudioService.inputVolume - AudioService.stepVolume)
      }
    }
    onClicked: {
      AudioService.setInputMuted(!AudioService.inputMuted)
    }
    onRightClicked: {
      var settingsPanel = PanelService.getPanel("settingsPanel")
      settingsPanel.requestedTab = SettingsPanel.Tab.Audio
      settingsPanel.open()
    }
    onMiddleClicked: {
      Quickshell.execDetached(["pwvucontrol"])
    }
  }
}
