import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL * scaling

  NHeader {
    label: "Volumes"
    description: "Adjust volume controls and audio levels."
  }

  property real localVolume: AudioService.volume

  Connections {
    target: AudioService.sink?.audio ? AudioService.sink?.audio : null
    function onVolumeChanged() {
      localVolume = AudioService.volume
    }
  }

  // Master Volume
  ColumnLayout {
    spacing: Style.marginXXS * scaling
    Layout.fillWidth: true

    NLabel {
      label: "Output volume"
      description: "System-wide volume level."
    }

    // Pipewire seems a bit finicky, if we spam too many volume changes it breaks easily
    // Probably because they have some quick fades in and out to avoid clipping
    // We use a timer to space out the updates, to avoid lock up
    Timer {
      interval: Style.animationFast
      running: true
      repeat: true
      onTriggered: {
        if (Math.abs(localVolume - AudioService.volume) >= 0.01) {
          AudioService.setVolume(localVolume)
        }
      }
    }

    NValueSlider {
      Layout.fillWidth: true
      from: 0
      to: Settings.data.audio.volumeOverdrive ? 2.0 : 1.0
      value: localVolume
      stepSize: 0.01
      text: Math.floor(AudioService.volume * 100) + "%"
      onMoved: {
        localVolume = value
      }
    }
  }

  // Mute Toggle
  ColumnLayout {
    spacing: Style.marginS * scaling
    Layout.fillWidth: true

    NToggle {
      label: "Mute audio output"
      description: "Mute the system's main audio output."
      checked: AudioService.muted
      onToggled: checked => {
                   if (AudioService.sink && AudioService.sink.audio) {
                     AudioService.sink.audio.muted = checked
                   }
                 }
    }
  }

  // Input Volume
  ColumnLayout {
    spacing: Style.marginXS * scaling
    Layout.fillWidth: true

    NLabel {
      label: "Input volume"
      description: "Microphone input volume level."
    }

    NValueSlider {
      Layout.fillWidth: true
      from: 0
      to: 1.0
      value: AudioService.inputVolume
      stepSize: 0.01
      text: Math.floor(AudioService.inputVolume * 100) + "%"
      onMoved: value => AudioService.setInputVolume(value)
    }
  }

  // Input Mute Toggle
  ColumnLayout {
    spacing: Style.marginS * scaling
    Layout.fillWidth: true

    NToggle {
      label: "Mute audio input"
      description: "Mute the default audio input (microphone)."
      checked: AudioService.inputMuted
      onToggled: checked => AudioService.setInputMuted(checked)
    }
  }

  // Volume Step Size
  ColumnLayout {
    spacing: Style.marginS * scaling
    Layout.fillWidth: true

    NSpinBox {
      Layout.fillWidth: true
      label: "Volume step size"
      description: "Adjust the step size for volume changes (scroll wheel, keyboard shortcuts)."
      minimum: 1
      maximum: 25
      value: Settings.data.audio.volumeStep
      stepSize: 1
      suffix: "%"
      onValueChanged: Settings.data.audio.volumeStep = value
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // AudioService Devices
  ColumnLayout {
    spacing: Style.marginS * scaling

    NHeader {
      label: "Audio devices"
      description: "Choose your audio input and output devices."
    }

    // -------------------------------
    // Output Devices
    ButtonGroup {
      id: sinks
    }

    ColumnLayout {
      spacing: Style.marginXS * scaling
      Layout.fillWidth: true
      Layout.bottomMargin: Style.marginL * scaling

      NLabel {
        label: "Output device"
        description: "Select the desired audio output device."
      }

      Repeater {
        model: AudioService.sinks
        NRadioButton {
          required property PwNode modelData
          ButtonGroup.group: sinks
          checked: AudioService.sink?.id === modelData.id
          onClicked: AudioService.setAudioSink(modelData)
          text: modelData.description
        }
      }
    }

    // -------------------------------
    // Input Devices
    ButtonGroup {
      id: sources
    }

    ColumnLayout {
      spacing: Style.marginXS * scaling
      Layout.fillWidth: true

      NLabel {
        label: "Input device"
        description: "Select the desired audio input device."
      }

      Repeater {
        model: AudioService.sources
        NRadioButton {
          required property PwNode modelData
          ButtonGroup.group: sources
          checked: AudioService.source?.id === modelData.id
          onClicked: AudioService.setAudioSource(modelData)
          text: modelData.description
        }
      }
    }
  }

  // Divider
  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // Media Player Preferences
  ColumnLayout {
    spacing: Style.marginL * scaling

    NHeader {
      label: "Media players"
      description: "Set your preferred and ignored media applications."
    }

    // Preferred player
    NTextInput {
      label: "Primary player"
      description: "Enter a keyword to identify your main player."
      placeholderText: "e.g. spotify, vlc, mpv"
      text: Settings.data.audio.preferredPlayer
      onTextChanged: {
        Settings.data.audio.preferredPlayer = text
        MediaService.updateCurrentPlayer()
      }
    }

    // Blacklist editor
    ColumnLayout {
      spacing: Style.marginS * scaling
      Layout.fillWidth: true

      RowLayout {
        spacing: Style.marginS * scaling
        Layout.fillWidth: true

        NTextInput {
          id: blacklistInput
          label: "Excluded player"
          description: "Add keywords for players you want the system to ignore. Each keyword should be on a new line."
          placeholderText: "type substring and press +"
        }

        // Button aligned to the center of the actual input field
        NIconButton {
          icon: "add"
          Layout.alignment: Qt.AlignBottom
          Layout.bottomMargin: blacklistInput.description ? Style.marginS * scaling : 0
          onClicked: {
            const val = (blacklistInput.text || "").trim()
            if (val !== "") {
              const arr = (Settings.data.audio.mprisBlacklist || [])
              if (!arr.find(x => String(x).toLowerCase() === val.toLowerCase())) {
                Settings.data.audio.mprisBlacklist = [...arr, val]
                blacklistInput.text = ""
                MediaService.updateCurrentPlayer()
              }
            }
          }
        }
      }

      // Current blacklist entries
      Flow {
        Layout.fillWidth: true
        Layout.leftMargin: Style.marginS * scaling
        spacing: Style.marginS * scaling

        Repeater {
          model: Settings.data.audio.mprisBlacklist
          delegate: Rectangle {
            required property string modelData
            // Padding around the inner row
            property real pad: Style.marginS * scaling
            // Visuals
            color: Qt.alpha(Color.mOnSurface, 0.125)
            border.color: Qt.alpha(Color.mOnSurface, Style.opacityLight)
            border.width: Math.max(1, Style.borderS * scaling)

            // Content
            RowLayout {
              id: chipRow
              spacing: Style.marginXS * scaling
              anchors.fill: parent
              anchors.margins: pad

              NText {
                text: modelData
                color: Color.mOnSurface
                font.pointSize: Style.fontSizeS * scaling
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: Style.marginS * scaling
              }

              NIconButton {
                icon: "close"
                baseSize: Style.baseWidgetSize * 0.8
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: Style.marginXS * scaling
                onClicked: {
                  const arr = (Settings.data.audio.mprisBlacklist || [])
                  const idx = arr.findIndex(x => String(x) === modelData)
                  if (idx >= 0) {
                    arr.splice(idx, 1)
                    Settings.data.audio.mprisBlacklist = arr
                    MediaService.updateCurrentPlayer()
                  }
                }
              }
            }

            // Intrinsic size derived from inner row + padding
            implicitWidth: chipRow.implicitWidth + pad * 2
            implicitHeight: Math.max(chipRow.implicitHeight + pad * 2, Style.baseWidgetSize * 0.8 * scaling)
            radius: Style.radiusM * scaling
          }
        }
      }
    }
  }

  // Divider
  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // AudioService Visualizer Category
  ColumnLayout {
    spacing: Style.marginS * scaling
    Layout.fillWidth: true

    NHeader {
      label: "Audio visualizer"
      description: "Customize visual effects that respond to audio playback."
    }

    // AudioService Visualizer section
    NComboBox {
      id: audioVisualizerCombo
      label: "Visualization type"
      description: "Choose a visualization type for media playback"
      model: ListModel {
        ListElement {
          key: "none"
          name: "None"
        }
        ListElement {
          key: "linear"
          name: "Linear"
        }
        ListElement {
          key: "mirrored"
          name: "Mirrored"
        }
        ListElement {
          key: "wave"
          name: "Wave"
        }
      }
      currentKey: Settings.data.audio.visualizerType
      onSelected: key => Settings.data.audio.visualizerType = key
    }

    NComboBox {
      label: "Frame rate"
      description: "Higher rates are smoother but use more resources."
      model: ListModel {
        ListElement {
          key: "30"
          name: "30 FPS"
        }
        ListElement {
          key: "60"
          name: "60 FPS"
        }
        ListElement {
          key: "100"
          name: "100 FPS"
        }
        ListElement {
          key: "120"
          name: "120 FPS"
        }
        ListElement {
          key: "144"
          name: "144 FPS"
        }
        ListElement {
          key: "165"
          name: "165 FPS"
        }
        ListElement {
          key: "240"
          name: "240 FPS"
        }
      }
      currentKey: Settings.data.audio.cavaFrameRate
      onSelected: key => Settings.data.audio.cavaFrameRate = key
    }
  }
  // Divider
  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }
}
