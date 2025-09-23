import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services
import qs.Widgets

Rectangle {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  readonly property string barPosition: Settings.data.bar.position
  readonly property bool isVertical: barPosition === "left" || barPosition === "right"
  readonly property bool compact: (Settings.data.bar.density === "compact")
  readonly property real itemSize: isVertical ? width * 0.75 : height * 0.85

  function onLoaded() {
    // When the widget is fully initialized with its props set the screen for the trayMenu
    if (trayMenu.item) {
      trayMenu.item.screen = screen
    }
  }

  visible: SystemTray.items.values.length > 0
  implicitWidth: isVertical ? Math.round(Style.capsuleHeight * scaling) : (trayFlow.implicitWidth + Style.marginS * scaling * 2)
  implicitHeight: isVertical ? (trayFlow.implicitHeight + Style.marginS * scaling * 2) : Math.round(Style.capsuleHeight * scaling)
  radius: Math.round(Style.radiusM * scaling)
  color: Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent

  Layout.alignment: Qt.AlignVCenter

  Flow {
    id: trayFlow
    anchors.centerIn: parent
    spacing: Style.marginS * scaling
    flow: isVertical ? Flow.TopToBottom : Flow.LeftToRight

    Repeater {
      id: repeater
      model: SystemTray.items

      delegate: Item {
        width: itemSize
        height: itemSize
        visible: modelData

        IconImage {
          id: trayIcon
          anchors.centerIn: parent
          width: Style.marginL * scaling
          height: Style.marginL * scaling
          smooth: false
          asynchronous: true
          backer.fillMode: Image.PreserveAspectFit
          source: {
            let icon = modelData?.icon || ""
            if (!icon) {
              return ""
            }

            // Process icon path
            if (icon.includes("?path=")) {
              // Seems qmlfmt does not support the following ES6 syntax: const[name, path] = icon.split
              const chunks = icon.split("?path=")
              const name = chunks[0]
              const path = chunks[1]
              const fileName = name.substring(name.lastIndexOf("/") + 1)
              return `file://${path}/${fileName}`
            }
            return icon
          }
          opacity: status === Image.Ready ? 1 : 0
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
          onClicked: mouse => {
                       if (!modelData) {
                         return
                       }

                       if (mouse.button === Qt.LeftButton) {
                         // Close any open menu first
                         trayPanel.close()

                         if (!modelData.onlyMenu) {
                           modelData.activate()
                         }
                       } else if (mouse.button === Qt.MiddleButton) {
                         // Close any open menu first
                         trayPanel.close()

                         modelData.secondaryActivate && modelData.secondaryActivate()
                       } else if (mouse.button === Qt.RightButton) {
                         trayTooltip.hide()

                         // Close the menu if it was visible
                         if (trayPanel && trayPanel.visible) {
                           trayPanel.close()
                           return
                         }

                         if (modelData.hasMenu && modelData.menu && trayMenu.item) {
                           trayPanel.open()

                           // Position menu based on bar position
                           let menuX, menuY
                           if (barPosition === "left") {
                             // For left bar: position menu to the right of the bar
                             menuX = width + Style.marginM * scaling
                             menuY = 0
                           } else if (barPosition === "right") {
                             // For right bar: position menu to the left of the bar
                             menuX = -trayMenu.item.width - Style.marginM * scaling
                             menuY = 0
                           } else {
                             // For horizontal bars: center horizontally and position below
                             menuX = (width / 2) - (trayMenu.item.width / 2)
                             menuY = Math.round(Style.barHeight * scaling)
                           }
                           trayMenu.item.menu = modelData.menu
                           trayMenu.item.showAt(parent, menuX, menuY)
                         } else {
                           Logger.log("Tray", "No menu available for", modelData.id, "or trayMenu not set")
                         }
                       }
                     }
          onEntered: trayTooltip.show()
          onExited: trayTooltip.hide()
        }

        NTooltip {
          id: trayTooltip
          target: trayIcon
          text: modelData.tooltipTitle || modelData.name || modelData.id || "Tray Item"
          positionAbove: Settings.data.bar.position === "bottom"
        }
      }
    }
  }

  PanelWindow {
    id: trayPanel
    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    visible: false
    color: Color.transparent
    screen: screen

    function open() {
      visible = true
      PanelService.willOpenPanel(trayPanel)
    }

    function close() {
      visible = false
      if (trayMenu.item) {
        trayMenu.item.hideMenu()
      }
    }

    // Clicking outside of the rectangle to close
    MouseArea {
      anchors.fill: parent
      onClicked: trayPanel.close()
    }

    Loader {
      id: trayMenu
      source: "../Extras/TrayMenu.qml"
    }
  }
}
