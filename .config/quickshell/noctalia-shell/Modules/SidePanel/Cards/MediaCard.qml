import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Modules.Audio
import qs.Commons
import qs.Services
import qs.Widgets

NBox {
  id: root

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.marginL * scaling

    // No media player detected
    ColumnLayout {
      id: fallback

      visible: !main.visible
      spacing: Style.marginS * scaling

      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
      }

      NIcon {
        icon: "disc"
        font.pointSize: Style.fontSizeXXXL * 3 * scaling
        color: Color.mPrimary
        Layout.alignment: Qt.AlignHCenter
      }
      NText {
        text: "No media player detected"
        color: Color.mOnSurfaceVariant
        Layout.alignment: Qt.AlignHCenter
      }

      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
      }
    }

    // MediaPlayer Main Content
    ColumnLayout {
      id: main

      visible: MediaService.currentPlayer && MediaService.canPlay
      spacing: Style.marginM * scaling

      // Player selector
      ComboBox {
        id: playerSelector
        Layout.fillWidth: true
        Layout.preferredHeight: Style.barHeight * 0.83 * scaling
        visible: MediaService.getAvailablePlayers().length > 1
        model: MediaService.getAvailablePlayers()
        textRole: "identity"
        currentIndex: MediaService.selectedPlayerIndex

        background: Rectangle {
          visible: false
          // implicitWidth: 120 * scaling
          // implicitHeight: 30 * scaling
          color: Color.transparent
          border.color: playerSelector.activeFocus ? Color.mSecondary : Color.mOutline
          border.width: Math.max(1, Style.borderS * scaling)
          radius: Style.radiusM * scaling
        }

        contentItem: NText {
          visible: false
          leftPadding: Style.marginM * scaling
          rightPadding: playerSelector.indicator.width + playerSelector.spacing
          text: playerSelector.displayText
          font.pointSize: Style.fontSizeXS * scaling
          color: Color.mOnSurface
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
        }

        indicator: NIcon {
          x: playerSelector.width - width
          y: playerSelector.topPadding + (playerSelector.availableHeight - height) / 2
          icon: "caret-down"
          font.pointSize: Style.fontSizeXXL * scaling
          color: Color.mOnSurface
          horizontalAlignment: Text.AlignRight
        }

        popup: Popup {
          id: popup
          x: playerSelector.width * 0.5
          y: playerSelector.height * 0.75
          width: playerSelector.width * 0.5
          implicitHeight: Math.min(160 * scaling, contentItem.implicitHeight + Style.marginM * scaling)
          padding: Style.marginS * scaling

          contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: playerSelector.popup.visible ? playerSelector.delegateModel : null
            currentIndex: playerSelector.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
          }

          background: Rectangle {
            color: Color.mSurface
            border.color: Color.mOutline
            border.width: Math.max(1, Style.borderS * scaling)
            radius: Style.radiusXS * scaling
          }
        }

        delegate: ItemDelegate {
          width: playerSelector.width
          contentItem: NText {
            text: modelData.identity
            font.pointSize: Style.fontSizeS * scaling
            color: highlighted ? Color.mSurface : Color.mOnSurface
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
          }
          highlighted: playerSelector.highlightedIndex === index

          background: Rectangle {
            width: popup.width - Style.marginS * scaling * 2
            color: highlighted ? Color.mSecondary : Color.transparent
            radius: Style.radiusXS * scaling
          }
        }

        onActivated: {
          MediaService.selectedPlayerIndex = currentIndex
          MediaService.updateCurrentPlayer()
        }
      }

      RowLayout {
        spacing: Style.marginM * scaling

        // -------------------------
        // Rounded thumbnail image
        Rectangle {

          width: 90 * scaling
          height: 90 * scaling
          radius: width * 0.5
          color: trackArt.visible ? Color.mPrimary : Color.transparent
          clip: true

          // Can't use fallback icon here, as we have a big disc behind
          NImageCircled {
            id: trackArt
            visible: MediaService.trackArtUrl !== ""
            anchors.fill: parent
            anchors.margins: Style.marginXS * scaling
            imagePath: MediaService.trackArtUrl
            borderColor: Color.mOutline
            borderWidth: Math.max(1, Style.borderS * scaling)
          }

          // Fallback icon when no album art available
          NIcon {
            icon: "disc"
            color: Color.mPrimary
            font.pointSize: Style.fontSizeXXXL * 3 * scaling
            visible: !trackArt.visible
            anchors.centerIn: parent
          }
        }

        // -------------------------
        // Track metadata
        ColumnLayout {
          Layout.fillWidth: true
          spacing: Style.marginXS * scaling

          NText {
            visible: MediaService.trackTitle !== ""
            text: MediaService.trackTitle
            font.pointSize: Style.fontSizeM * scaling
            font.weight: Style.fontWeightBold
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 2
            Layout.fillWidth: true
          }

          NText {
            visible: MediaService.trackArtist !== ""
            text: MediaService.trackArtist
            color: Color.mOnSurface
            font.pointSize: Style.fontSizeXS * scaling
            elide: Text.ElideRight
            Layout.fillWidth: true
          }

          NText {
            visible: MediaService.trackAlbum !== ""
            text: MediaService.trackAlbum
            color: Color.mOnSurface
            font.pointSize: Style.fontSizeXS * scaling
            elide: Text.ElideRight
            Layout.fillWidth: true
          }
        }
      }

      // -------------------------
      // Progress slider (uses shared NSlider behavior like BarTab)
      Item {
        id: progressWrapper
        visible: (MediaService.currentPlayer && MediaService.trackLength > 0)
        Layout.fillWidth: true
        height: Style.baseWidgetSize * 0.5 * scaling

        // Local preview while dragging
        property real localSeekRatio: -1
        // Track the last ratio we actually sent to the backend to avoid redundant seeks
        property real lastSentSeekRatio: -1
        // Minimum change required to issue a new seek during drag
        property real seekEpsilon: 0.01
        property real progressRatio: {
          if (!MediaService.currentPlayer || MediaService.trackLength <= 0)
            return 0
          const r = MediaService.currentPosition / MediaService.trackLength
          if (isNaN(r) || !isFinite(r))
            return 0
          return Math.max(0, Math.min(1, r))
        }
        property real effectiveRatio: (MediaService.isSeeking && localSeekRatio >= 0) ? Math.max(0, Math.min(1, localSeekRatio)) : progressRatio

        // Debounced backend seek during drag
        Timer {
          id: seekDebounce
          interval: 75
          repeat: false
          onTriggered: {
            if (MediaService.isSeeking && progressWrapper.localSeekRatio >= 0) {
              const next = Math.max(0, Math.min(1, progressWrapper.localSeekRatio))
              if (progressWrapper.lastSentSeekRatio < 0 || Math.abs(next - progressWrapper.lastSentSeekRatio) >= progressWrapper.seekEpsilon) {
                MediaService.seekByRatio(next)
                progressWrapper.lastSentSeekRatio = next
              }
            }
          }
        }

        NSlider {
          id: progressSlider
          anchors.fill: parent
          from: 0
          to: 1
          stepSize: 0
          snapAlways: false
          enabled: MediaService.trackLength > 0 && MediaService.canSeek
          heightRatio: 0.65

          onMoved: {
            progressWrapper.localSeekRatio = value
            seekDebounce.restart()
          }
          onPressedChanged: {
            if (pressed) {
              MediaService.isSeeking = true
              progressWrapper.localSeekRatio = value
              MediaService.seekByRatio(value)
              progressWrapper.lastSentSeekRatio = value
            } else {
              seekDebounce.stop()
              MediaService.seekByRatio(value)
              MediaService.isSeeking = false
              progressWrapper.localSeekRatio = -1
              progressWrapper.lastSentSeekRatio = -1
            }
          }
        }

        // While not dragging, bind slider to live progress
        // during drag, let the slider manage its own value
        Binding {
          target: progressSlider
          property: "value"
          value: progressWrapper.progressRatio
          when: !MediaService.isSeeking
        }
      }

      // -------------------------
      // Media controls
      RowLayout {
        spacing: Style.marginM * scaling
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        // Previous button
        NIconButton {
          icon: "media-prev"
          tooltipText: "Previous media"
          visible: MediaService.canGoPrevious
          onClicked: MediaService.canGoPrevious ? MediaService.previous() : {}
        }

        // Play/Pause button
        NIconButton {
          icon: MediaService.isPlaying ? "media-pause" : "media-play"
          tooltipText: MediaService.isPlaying ? "Pause" : "Play"
          visible: (MediaService.canPlay || MediaService.canPause)
          onClicked: (MediaService.canPlay || MediaService.canPause) ? MediaService.playPause() : {}
        }

        // Next button
        NIconButton {
          icon: "media-next"
          tooltipText: "Next media"
          visible: MediaService.canGoNext
          onClicked: MediaService.canGoNext ? MediaService.next() : {}
        }
      }
    }

    Loader {
      active: Settings.data.audio.visualizerType == "linear" && MediaService.isPlaying
      Layout.alignment: Qt.AlignHCenter

      sourceComponent: LinearSpectrum {
        width: 300 * scaling
        height: 80 * scaling
        values: CavaService.values
        fillColor: Color.mPrimary
        Layout.alignment: Qt.AlignHCenter
      }
    }

    Loader {
      active: Settings.data.audio.visualizerType == "mirrored" && MediaService.isPlaying
      Layout.alignment: Qt.AlignHCenter

      sourceComponent: MirroredSpectrum {
        width: 300 * scaling
        height: 80 * scaling
        values: CavaService.values
        fillColor: Color.mPrimary
        Layout.alignment: Qt.AlignHCenter
      }
    }

    Loader {
      active: Settings.data.audio.visualizerType == "wave" && MediaService.isPlaying
      Layout.alignment: Qt.AlignHCenter

      sourceComponent: WaveSpectrum {
        width: 300 * scaling
        height: 80 * scaling
        values: CavaService.values
        fillColor: Color.mPrimary
        Layout.alignment: Qt.AlignHCenter
      }
    }
  }
}
