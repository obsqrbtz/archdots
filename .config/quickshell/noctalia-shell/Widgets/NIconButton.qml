import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Commons
import qs.Services

Rectangle {
  id: root

  property real baseSize: Style.baseWidgetSize

  property string icon
  property string tooltipText
  property bool enabled: true
  property bool allowClickWhenDisabled: false
  property bool hovering: false
  property bool compact: false

  property color colorBg: Color.mSurfaceVariant
  property color colorFg: Color.mPrimary
  property color colorBgHover: Color.mTertiary
  property color colorFgHover: Color.mOnTertiary
  property color colorBorder: Color.mOutline
  property color colorBorderHover: Color.mOutline

  signal entered
  signal exited
  signal clicked
  signal rightClicked
  signal middleClicked

  implicitWidth: Math.round(baseSize * scaling)
  implicitHeight: Math.round(baseSize * scaling)

  opacity: root.enabled ? Style.opacityFull : Style.opacityMedium
  color: root.enabled && root.hovering ? colorBgHover : colorBg
  radius: width * 0.5
  border.color: root.enabled && root.hovering ? colorBorderHover : colorBorder
  border.width: Math.max(1, Style.borderS * scaling)

  Behavior on color {
    ColorAnimation {
      duration: Style.animationNormal
      easing.type: Easing.InOutQuad
    }
  }

  NIcon {
    icon: root.icon
    font.pointSize: Math.max(1, root.compact ? root.width * 0.65 : root.width * 0.48)
    color: root.enabled && root.hovering ? colorFgHover : colorFg
    // Center horizontally
    x: (root.width - width) / 2
    // Center vertically accounting for font metrics
    y: (root.height - height) / 2 + (height - contentHeight) / 2

    Behavior on color {
      ColorAnimation {
        duration: Style.animationFast
        easing.type: Easing.InOutQuad
      }
    }
  }

  NTooltip {
    id: tooltip
    target: root
    positionAbove: Settings.data.bar.position === "bottom"
    text: root.tooltipText
  }

  MouseArea {
    // Always enabled to allow hover/tooltip even when the button is disabled
    enabled: true
    anchors.fill: parent
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    hoverEnabled: true
    onEntered: {
      hovering = root.enabled ? true : false
      if (tooltipText) {
        tooltip.show()
      }
      root.entered()
    }
    onExited: {
      hovering = false
      if (tooltipText) {
        tooltip.hide()
      }
      root.exited()
    }
    onClicked: function (mouse) {
      if (tooltipText) {
        tooltip.hide()
      }
      if (!root.enabled && !allowClickWhenDisabled) {
        return
      }
      if (mouse.button === Qt.LeftButton) {
        root.clicked()
      } else if (mouse.button === Qt.RightButton) {
        root.rightClicked()
      } else if (mouse.button === Qt.MiddleButton) {
        root.middleClicked()
      }
    }
  }
}
