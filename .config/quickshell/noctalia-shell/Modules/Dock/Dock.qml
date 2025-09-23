import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Commons
import qs.Services
import qs.Widgets

Variants {
  model: Quickshell.screens

  delegate: Item {
    required property ShellScreen modelData
    property real scaling: ScalingService.getScreenScale(modelData)

    Connections {
      target: ScalingService
      function onScaleChanged(screenName, scale) {
        if (screenName === modelData.name) {
          scaling = scale
        }
      }
    }

    // Shared properties between peek and dock windows
    readonly property bool autoHide: Settings.data.dock.autoHide
    readonly property int hideDelay: 500
    readonly property int showDelay: 100
    readonly property int hideAnimationDuration: Style.animationFast
    readonly property int showAnimationDuration: Style.animationFast
    readonly property int peekHeight: 1 // no scaling for peek
    readonly property int iconSize: 36 * scaling
    readonly property int floatingMargin: Settings.data.dock.floatingRatio * Style.marginL * scaling

    // Bar detection and positioning properties
    readonly property bool hasBar: modelData.name ? (Settings.data.bar.monitors.includes(modelData.name) || (Settings.data.bar.monitors.length === 0)) : false
    readonly property bool barAtBottom: hasBar && Settings.data.bar.position === "bottom"
    readonly property int barHeight: Style.barHeight * scaling

    // Shared state between windows
    property bool dockHovered: false
    property bool anyAppHovered: false
    property bool hidden: autoHide
    property bool peekHovered: false

    // Separate property to control Loader - stays true during animations
    property bool dockLoaded: !autoHide // Start loaded if autoHide is off

    // Timer to unload dock after hide animation completes
    Timer {
      id: unloadTimer
      interval: hideAnimationDuration + 50 // Add small buffer
      onTriggered: {
        if (hidden && autoHide) {
          dockLoaded = false
        }
      }
    }

    // Timer for auto-hide delay
    Timer {
      id: hideTimer
      interval: hideDelay
      onTriggered: {
        if (autoHide && !dockHovered && !anyAppHovered && !peekHovered) {
          hidden = true
          unloadTimer.restart() // Start unload timer when hiding
        }
      }
    }

    // Timer for show delay
    Timer {
      id: showTimer
      interval: showDelay
      onTriggered: {
        if (autoHide) {
          dockLoaded = true // Load dock immediately
          hidden = false // Then trigger show animation
          unloadTimer.stop() // Cancel any pending unload
        }
      }
    }

    // Watch for autoHide setting changes
    onAutoHideChanged: {
      if (!autoHide) {
        hidden = false
        dockLoaded = true
        hideTimer.stop()
        showTimer.stop()
        unloadTimer.stop()
      } else {
        hidden = true
        unloadTimer.restart() // Schedule unload after animation
      }
    }

    // PEEK WINDOW - Always visible when auto-hide is enabled
    Loader {
      active: Settings.isLoaded && modelData && Settings.data.dock.monitors.includes(modelData.name) && autoHide

      sourceComponent: PanelWindow {
        id: peekWindow

        screen: modelData
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        focusable: false
        color: Color.transparent

        WlrLayershell.namespace: "noctalia-dock-peek"
        WlrLayershell.exclusionMode: ExclusionMode.Auto // Always exclusive

        implicitHeight: peekHeight

        Rectangle {
          anchors.fill: parent
          color: barAtBottom ? Qt.alpha(Color.mSurface, Settings.data.bar.backgroundOpacity) : Color.transparent
        }

        MouseArea {
          id: peekArea
          anchors.fill: parent
          hoverEnabled: true

          onEntered: {
            peekHovered = true
            if (hidden) {
              showTimer.start()
            }
          }

          onExited: {
            peekHovered = false
            if (!hidden && !dockHovered && !anyAppHovered) {
              hideTimer.restart()
            }
          }
        }
      }
    }

    // DOCK WINDOW
    Loader {
      active: Settings.isLoaded && modelData && Settings.data.dock.monitors.includes(modelData.name) && dockLoaded && ToplevelManager && (ToplevelManager.toplevels.values.length > 0)

      sourceComponent: PanelWindow {
        id: dockWindow

        screen: modelData

        focusable: false
        color: Color.transparent

        WlrLayershell.namespace: "noctalia-dock-main"
        WlrLayershell.exclusionMode: Settings.data.dock.exclusive ? ExclusionMode.Auto : ExclusionMode.Ignore

        // Size to fit the dock container exactly
        implicitWidth: dockContainerWrapper.width
        implicitHeight: dockContainerWrapper.height

        // Position above the bar if it's at bottom
        anchors.bottom: true

        margins.bottom: {
          switch (Settings.data.bar.position) {
          case "bottom":
            return (Style.barHeight + Style.marginM) * scaling + (Settings.data.bar.floating ? Settings.data.bar.marginVertical * Style.marginXL * scaling + floatingMargin : floatingMargin)
          default:
            return floatingMargin
          }
        }

        // Rectangle {
        //   anchors.fill: parent
        //   color: "#000FF0"
        //   z: -1
        // }

        // Wrapper item for scale/opacity animations
        Item {
          id: dockContainerWrapper
          width: dockContainer.width
          height: dockContainer.height
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom

          // Apply animations to this wrapper
          opacity: hidden ? 0 : 1
          scale: hidden ? 0.85 : 1

          Behavior on opacity {
            NumberAnimation {
              duration: hidden ? hideAnimationDuration : showAnimationDuration
              easing.type: Easing.InOutQuad
            }
          }

          Behavior on scale {
            NumberAnimation {
              duration: hidden ? hideAnimationDuration : showAnimationDuration
              easing.type: hidden ? Easing.InQuad : Easing.OutBack
              easing.overshoot: hidden ? 0 : 1.05
            }
          }

          Rectangle {
            id: dockContainer
            width: dockLayout.implicitWidth + Style.marginM * scaling * 2
            height: Math.round(iconSize * 1.5)
            color: Qt.alpha(Color.mSurface, Settings.data.dock.backgroundOpacity)
            anchors.centerIn: parent
            radius: Style.radiusL * scaling
            border.width: Math.max(1, Style.borderS * scaling)
            border.color: Qt.alpha(Color.mOutline, Settings.data.dock.backgroundOpacity)

            MouseArea {
              id: dockMouseArea
              anchors.fill: parent
              hoverEnabled: true

              onEntered: {
                dockHovered = true
                if (autoHide) {
                  showTimer.stop()
                  hideTimer.stop()
                  unloadTimer.stop() // Cancel unload if hovering
                }
              }

              onExited: {
                dockHovered = false
                if (autoHide && !anyAppHovered && !peekHovered) {
                  hideTimer.restart()
                }
              }
            }

            Item {
              id: dock
              width: dockLayout.implicitWidth
              height: parent.height - (Style.marginM * 2 * scaling)
              anchors.centerIn: parent

              function getAppIcon(toplevel: Toplevel): string {
                if (!toplevel)
                  return ""
                return AppIcons.iconForAppId(toplevel.appId?.toLowerCase())
              }

              RowLayout {
                id: dockLayout
                spacing: Style.marginM * scaling
                Layout.preferredHeight: parent.height
                anchors.centerIn: parent

                Repeater {
                  model: ToplevelManager ? ToplevelManager.toplevels : null

                  delegate: Item {
                    id: appButton
                    Layout.preferredWidth: iconSize
                    Layout.preferredHeight: iconSize
                    Layout.alignment: Qt.AlignCenter

                    property bool isActive: ToplevelManager.activeToplevel && ToplevelManager.activeToplevel === modelData
                    property bool hovered: appMouseArea.containsMouse
                    property string appId: modelData ? modelData.appId : ""
                    property string appTitle: modelData ? modelData.title : ""

                    // Individual tooltip for this app
                    NTooltip {
                      id: appTooltip
                      target: appButton
                      positionAbove: true
                      visible: false
                    }

                    Image {
                      id: appIcon
                      width: iconSize
                      height: iconSize
                      anchors.centerIn: parent
                      source: dock.getAppIcon(modelData)
                      visible: source.toString() !== ""
                      sourceSize.width: iconSize * 2
                      sourceSize.height: iconSize * 2
                      smooth: true
                      mipmap: true
                      antialiasing: true
                      fillMode: Image.PreserveAspectFit
                      cache: true

                      scale: appButton.hovered ? 1.15 : 1.0

                      Behavior on scale {
                        NumberAnimation {
                          duration: Style.animationNormal
                          easing.type: Easing.OutBack
                          easing.overshoot: 1.2
                        }
                      }
                    }

                    // Fall back if no icon
                    NIcon {
                      anchors.centerIn: parent
                      visible: !appIcon.visible
                      icon: "question-mark"
                      font.pointSize: iconSize * 0.7
                      color: appButton.isActive ? Color.mPrimary : Color.mOnSurfaceVariant
                      scale: appButton.hovered ? 1.15 : 1.0

                      Behavior on scale {
                        NumberAnimation {
                          duration: Style.animationFast
                          easing.type: Easing.OutBack
                          easing.overshoot: 1.2
                        }
                      }
                    }

                    MouseArea {
                      id: appMouseArea
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      acceptedButtons: Qt.LeftButton | Qt.MiddleButton

                      onEntered: {
                        anyAppHovered = true
                        const appName = appButton.appTitle || appButton.appId || "Unknown"
                        appTooltip.text = appName.length > 40 ? appName.substring(0, 37) + "..." : appName
                        appTooltip.isVisible = true
                        if (autoHide) {
                          showTimer.stop()
                          hideTimer.stop()
                          unloadTimer.stop() // Cancel unload if hovering app
                        }
                      }

                      onExited: {
                        anyAppHovered = false
                        appTooltip.hide()
                        if (autoHide && !dockHovered && !peekHovered) {
                          hideTimer.restart()
                        }
                      }

                      onClicked: function (mouse) {
                        if (mouse.button === Qt.MiddleButton && modelData?.close) {
                          modelData.close()
                        }
                        if (mouse.button === Qt.LeftButton && modelData?.activate) {
                          modelData.activate()
                        }
                      }
                    }

                    // Active indicator
                    Rectangle {
                      visible: isActive
                      width: iconSize * 0.2
                      height: iconSize * 0.1
                      color: Color.mPrimary
                      radius: Style.radiusXS * scaling
                      anchors.top: parent.bottom
                      anchors.horizontalCenter: parent.horizontalCenter

                      // Pulse animation for active indicator
                      SequentialAnimation on opacity {
                        running: isActive
                        loops: Animation.Infinite
                        NumberAnimation {
                          to: 0.6
                          duration: Style.animationSlowest
                          easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                          to: 1.0
                          duration: Style.animationSlowest
                          easing.type: Easing.InOutQuad
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
