import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets

Rectangle {
  id: root
  property ShellScreen screen
  property real scaling: 1.0

  readonly property bool isVerticalBar: Settings.data.bar.position === "left" || Settings.data.bar.position === "right"
  readonly property bool compact: (Settings.data.bar.density === "compact")
  readonly property real itemSize: compact ? Style.capsuleHeight * 0.9 * scaling : Style.capsuleHeight * 0.8 * scaling

  // Always visible when there are toplevels
  implicitWidth: isVerticalBar ? Math.round(Style.capsuleHeight * scaling) : taskbarLayout.implicitWidth + Style.marginM * scaling * 2
  implicitHeight: isVerticalBar ? taskbarLayout.implicitHeight + Style.marginM * scaling * 2 : Math.round(Style.capsuleHeight * scaling)
  radius: Math.round(Style.radiusM * scaling)
  color: Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent

  GridLayout {
    id: taskbarLayout
    anchors.fill: parent
    anchors {
      leftMargin: isVerticalBar ? undefined : Style.marginM * scaling
      rightMargin: isVerticalBar ? undefined : Style.marginM * scaling
      topMargin: compact ? 0 : isVerticalBar ? Style.marginM * scaling : undefined
      bottomMargin: compact ? 0 : isVerticalBar ? Style.marginM * scaling : undefined
    }

    // Configure GridLayout to behave like RowLayout or ColumnLayout
    rows: isVerticalBar ? -1 : 1 // -1 means unlimited
    columns: isVerticalBar ? 1 : -1 // -1 means unlimited

    rowSpacing: isVerticalBar ? Style.marginXXS * root.scaling : 0
    columnSpacing: isVerticalBar ? 0 : Style.marginXXS * root.scaling

    Repeater {
      model: ToplevelManager && ToplevelManager.toplevels ? ToplevelManager.toplevels : []
      delegate: Item {
        id: taskbarItem
        required property Toplevel modelData
        property Toplevel toplevel: modelData
        property bool isActive: ToplevelManager.activeToplevel === modelData

        Layout.preferredWidth: root.itemSize
        Layout.preferredHeight: root.itemSize
        Layout.alignment: Qt.AlignCenter

        Rectangle {
          id: iconBackground
          anchors.centerIn: parent
          width: parent.width
          height: parent.height
          color: taskbarItem.isActive ? Color.mPrimary : root.color
          border.width: 0
          radius: Math.round(Style.radiusXS * root.scaling)
          border.color: "transparent"
          z: -1

          IconImage {
            id: appIcon
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            source: AppIcons.iconForAppId(taskbarItem.modelData.appId)
            smooth: true
            asynchronous: true
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          acceptedButtons: Qt.LeftButton | Qt.RightButton

          onPressed: function (mouse) {
            if (!taskbarItem.modelData)
              return

            if (mouse.button === Qt.LeftButton) {
              try {
                taskbarItem.modelData.activate()
              } catch (error) {
                Logger.error("Taskbar", "Failed to activate toplevel: " + error)
              }
            } else if (mouse.button === Qt.RightButton) {
              try {
                taskbarItem.modelData.close()
              } catch (error) {
                Logger.error("Taskbar", "Failed to close toplevel: " + error)
              }
            }
          }
          onEntered: taskbarTooltip.show()
          onExited: taskbarTooltip.hide()
        }

        NTooltip {
          id: taskbarTooltip
          text: taskbarItem.modelData.title || taskbarItem.modelData.appId || "Unknown app."
          target: taskbarItem
          positionAbove: Settings.data.bar.position === "bottom"
        }
      }
    }
  }
}
