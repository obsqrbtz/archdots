import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Modules.Audio
import qs.Commons
import qs.Services
import qs.Widgets

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

  readonly property string barPosition: Settings.data.bar.position
  readonly property bool compact: (Settings.data.bar.density === "compact")

  readonly property bool showAlbumArt: (widgetSettings.showAlbumArt !== undefined) ? widgetSettings.showAlbumArt : widgetMetadata.showAlbumArt
  readonly property bool showVisualizer: (widgetSettings.showVisualizer !== undefined) ? widgetSettings.showVisualizer : widgetMetadata.showVisualizer
  readonly property string visualizerType: (widgetSettings.visualizerType !== undefined && widgetSettings.visualizerType !== "") ? widgetSettings.visualizerType : widgetMetadata.visualizerType

  // 6% of total width
  readonly property real minWidth: Math.max(1, screen.width * 0.06)
  readonly property real maxWidth: minWidth * 2

  function getTitle() {
    return MediaService.trackTitle + (MediaService.trackArtist !== "" ? ` - ${MediaService.trackArtist}` : "")
  }

  function calculatedVerticalHeight() {
    return Math.round(Style.baseWidgetSize * 0.8 * scaling)
  }

  function calculatedHorizontalWidth() {
    let total = Style.marginM * 2 * scaling // internal padding
    if (showAlbumArt) {
      total += 18 * scaling + 2 * scaling // album art + spacing
    } else {
      total += Style.fontSizeL * scaling + 2 * scaling // icon + spacing
    }
    total += Math.min(fullTitleMetrics.contentWidth, maxWidth * scaling) // title text
    // Row layout handles spacing between widgets
    return total
  }

  implicitHeight: visible ? ((barPosition === "left" || barPosition === "right") ? calculatedVerticalHeight() : Math.round(Style.barHeight * scaling)) : 0
  implicitWidth: visible ? ((barPosition === "left" || barPosition === "right") ? Math.round(Style.baseWidgetSize * 0.8 * scaling) : (rowLayout.implicitWidth + Style.marginM * 2 * scaling)) : 0

  visible: MediaService.currentPlayer !== null && MediaService.canPlay

  //  A hidden text element to safely measure the full title width
  NText {
    id: fullTitleMetrics
    visible: false
    text: titleText.text
    font: titleText.font
  }

  Rectangle {
    id: mediaMini
    visible: root.visible
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: (barPosition === "left" || barPosition === "right") ? Math.round(Style.baseWidgetSize * 0.8 * scaling) : (rowLayout.implicitWidth + Style.marginM * 2 * scaling)
    height: (barPosition === "left" || barPosition === "right") ? Math.round(Style.baseWidgetSize * 0.8 * scaling) : Math.round(Style.capsuleHeight * scaling)
    radius: (barPosition === "left" || barPosition === "right") ? width / 2 : Math.round(Style.radiusM * scaling)
    color: Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent

    // Used to anchor the tooltip, so the tooltip does not move when the content expands
    Item {
      id: anchor
      height: parent.height
      width: 200 * scaling
    }

    Item {
      id: mainContainer
      anchors.fill: parent
      anchors.leftMargin: (barPosition === "left" || barPosition === "right") ? 0 : Style.marginS * scaling
      anchors.rightMargin: (barPosition === "left" || barPosition === "right") ? 0 : Style.marginS * scaling

      Loader {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        active: showVisualizer && visualizerType == "linear" && MediaService.isPlaying
        z: 0

        sourceComponent: LinearSpectrum {
          width: mainContainer.width - Style.marginS * scaling
          height: 20 * scaling
          values: CavaService.values
          fillColor: Color.mOnSurfaceVariant
          opacity: 0.4
        }
      }

      Loader {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        active: showVisualizer && visualizerType == "mirrored" && MediaService.isPlaying
        z: 0

        sourceComponent: MirroredSpectrum {
          width: mainContainer.width - Style.marginS * scaling
          height: mainContainer.height - Style.marginS * scaling
          values: CavaService.values
          fillColor: Color.mOnSurfaceVariant
          opacity: 0.4
        }
      }

      Loader {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        active: showVisualizer && visualizerType == "wave" && MediaService.isPlaying
        z: 0

        sourceComponent: WaveSpectrum {
          width: mainContainer.width - Style.marginS * scaling
          height: mainContainer.height - Style.marginS * scaling
          values: CavaService.values
          fillColor: Color.mOnSurfaceVariant
          opacity: 0.4
        }
      }

      // Horizontal layout for top/bottom bars
      RowLayout {
        id: rowLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.marginS * scaling
        visible: barPosition === "top" || barPosition === "bottom"
        z: 1 // Above the visualizer

        NIcon {
          id: windowIcon
          icon: MediaService.isPlaying ? "media-pause" : "media-play"
          font.pointSize: Style.fontSizeL * scaling
          verticalAlignment: Text.AlignVCenter
          Layout.alignment: Qt.AlignVCenter
          visible: !showAlbumArt && getTitle() !== "" && !trackArt.visible
        }

        ColumnLayout {
          Layout.alignment: Qt.AlignVCenter
          visible: showAlbumArt
          spacing: 0

          Item {
            Layout.preferredWidth: Math.round(18 * scaling)
            Layout.preferredHeight: Math.round(18 * scaling)

            NImageCircled {
              id: trackArt
              anchors.fill: parent
              imagePath: MediaService.trackArtUrl
              fallbackIcon: MediaService.isPlaying ? "media-pause" : "media-play"
              fallbackIconSize: 10 * scaling
              borderWidth: 0
              border.color: Color.transparent
            }
          }
        }

        NText {
          id: titleText

          Layout.preferredWidth: {
            if (mouseArea.containsMouse) {
              return Math.round(Math.min(fullTitleMetrics.contentWidth, root.maxWidth * scaling))
            } else {
              return Math.round(Math.min(fullTitleMetrics.contentWidth, root.minWidth * scaling))
            }
          }
          Layout.alignment: Qt.AlignVCenter

          text: getTitle()
          font.pointSize: Style.fontSizeS * scaling
          font.weight: Style.fontWeightMedium
          elide: Text.ElideRight
          verticalAlignment: Text.AlignVCenter
          color: Color.mSecondary

          Behavior on Layout.preferredWidth {
            NumberAnimation {
              duration: Style.animationSlow
              easing.type: Easing.InOutCubic
            }
          }
        }
      }

      // Vertical layout for left/right bars - icon only
      Item {
        id: verticalLayout
        anchors.centerIn: parent
        width: parent.width - Style.marginM * scaling * 2
        height: parent.height - Style.marginM * scaling * 2
        visible: barPosition === "left" || barPosition === "right"
        z: 1 // Above the visualizer

        // Media icon
        Item {
          width: Style.baseWidgetSize * 0.5 * scaling
          height: Style.baseWidgetSize * 0.5 * scaling
          anchors.centerIn: parent
          visible: getTitle() !== ""

          NIcon {
            id: mediaIconVertical
            anchors.fill: parent
            icon: MediaService.isPlaying ? "media-pause" : "media-play"
            font.pointSize: Style.fontSizeL * scaling
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
          }
        }
      }

      // Mouse area for hover detection
      MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
                     if (mouse.button === Qt.LeftButton) {
                       MediaService.playPause()
                     } else if (mouse.button == Qt.RightButton) {
                       MediaService.next()
                       // Need to hide the tooltip instantly
                       tooltip.visible = false
                     } else if (mouse.button == Qt.MiddleButton) {
                       MediaService.previous()
                       // Need to hide the tooltip instantly
                       tooltip.visible = false
                     }
                   }

        onEntered: {
          if (barPosition === "left" || barPosition === "right") {
            tooltip.show()
          } else if (tooltip.text !== "") {
            tooltip.show()
          }
        }
        onExited: {
          if (barPosition === "left" || barPosition === "right") {
            tooltip.hide()
          } else {
            tooltip.hide()
          }
        }
      }
    }
  }

  NTooltip {
    id: tooltip
    text: {
      if (barPosition === "left" || barPosition === "right") {
        return getTitle()
      } else {
        var str = ""
        if (MediaService.canGoNext) {
          str += "Right click for next.\n"
        }
        if (MediaService.canGoPrevious) {
          str += "Middle click for previous."
        }
        return str
      }
    }
    target: (barPosition === "left" || barPosition === "right") ? verticalLayout : anchor
    positionLeft: barPosition === "right"
    positionRight: barPosition === "left"
    positionAbove: Settings.data.bar.position === "bottom"
    delay: 500
  }
}
