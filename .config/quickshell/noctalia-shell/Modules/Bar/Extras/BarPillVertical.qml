import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Services
import qs.Widgets

Item {
  id: root

  property string icon: ""
  property string text: ""
  property string suffix: ""
  property string tooltipText: ""
  property bool autoHide: false
  property bool forceOpen: false
  property bool forceClose: false
  property bool disableOpen: false
  property bool rightOpen: false
  property bool hovered: false
  property bool compact: false

  // Bar position detection for pill direction
  readonly property string barPosition: Settings.data.bar.position
  readonly property bool isVerticalBar: barPosition === "left" || barPosition === "right"

  // Determine pill direction based on section position
  readonly property bool openDownward: rightOpen
  readonly property bool openUpward: !rightOpen

  // Effective shown state (true if animated open or forced, but not if force closed)
  readonly property bool revealed: !forceClose && (forceOpen || showPill)

  signal shown
  signal hidden
  signal entered
  signal exited
  signal clicked
  signal rightClicked
  signal middleClicked
  signal wheel(int delta)

  // Internal state
  property bool showPill: false
  property bool shouldAnimateHide: false

  // Sizing logic for vertical bars
  readonly property int buttonSize: Math.round(Style.capsuleHeight * scaling)
  readonly property int pillHeight: buttonSize
  readonly property int pillPaddingVertical: 3 * 2 * scaling // Very precise adjustment don't replace by Style.margin
  readonly property int pillOverlap: buttonSize * 0.5
  readonly property int maxPillWidth: buttonSize
  readonly property int maxPillHeight: Math.max(1, textItem.implicitHeight + pillPaddingVertical * 4)

  readonly property real iconSize: Math.max(1, compact ? pillHeight * 0.65 : pillHeight * 0.48)
  readonly property real textSize: Math.max(1, compact ? pillHeight * 0.38 : pillHeight * 0.33)

  // For vertical bars: width is just icon size, height includes pill space
  width: buttonSize
  height: revealed ? (buttonSize + maxPillHeight - pillOverlap) : buttonSize

  Rectangle {
    id: pill
    width: revealed ? maxPillWidth : 1
    height: revealed ? maxPillHeight : 1

    // Position based on direction - center the pill relative to the icon
    x: 0
    y: openUpward ? (iconCircle.y + iconCircle.height / 2 - height) : (iconCircle.y + iconCircle.height / 2)

    opacity: revealed ? Style.opacityFull : Style.opacityNone
    color: Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent

    // Radius logic for vertical expansion - rounded on the side that connects to icon
    topLeftRadius: openUpward ? buttonSize * 0.5 : 0
    bottomLeftRadius: openDownward ? buttonSize * 0.5 : 0
    topRightRadius: openUpward ? buttonSize * 0.5 : 0
    bottomRightRadius: openDownward ? buttonSize * 0.5 : 0

    anchors.horizontalCenter: parent.horizontalCenter

    NText {
      id: textItem
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: {
        var offset = openDownward ? pillPaddingVertical * 0.75 : -pillPaddingVertical * 0.75
        if (forceOpen) {
          // If its force open, the icon disc background is the same color as the bg pill move text slightly
          offset += rightOpen ? -Style.marginXXS * scaling : Style.marginXXS * scaling
        }
        return offset
      }
      text: root.text + root.suffix
      font.family: Settings.data.ui.fontFixed
      font.pointSize: textSize
      font.weight: Style.fontWeightMedium
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      color: forceOpen ? Color.mOnSurface : Color.mPrimary
      visible: revealed
    }

    Behavior on width {
      enabled: showAnim.running || hideAnim.running
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }
    Behavior on height {
      enabled: showAnim.running || hideAnim.running
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }
    Behavior on opacity {
      enabled: showAnim.running || hideAnim.running
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }
  }

  Rectangle {
    id: iconCircle
    width: buttonSize
    height: buttonSize
    radius: width * 0.5
    color: hovered ? Color.mTertiary : Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent

    // Icon positioning based on direction
    x: 0
    y: openUpward ? (parent.height - height) : 0
    anchors.horizontalCenter: parent.horizontalCenter

    Behavior on color {
      ColorAnimation {
        duration: Style.animationNormal
        easing.type: Easing.InOutQuad
      }
    }

    NIcon {
      icon: root.icon
      font.pointSize: iconSize
      color: hovered ? Color.mOnTertiary : Color.mOnSurface
      // Center horizontally
      x: (iconCircle.width - width) / 2
      // Center vertically accounting for font metrics
      y: (iconCircle.height - height) / 2 + (height - contentHeight) / 2
    }
  }

  ParallelAnimation {
    id: showAnim
    running: false
    NumberAnimation {
      target: pill
      property: "width"
      from: 1
      to: maxPillWidth
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
    NumberAnimation {
      target: pill
      property: "height"
      from: 1
      to: maxPillHeight
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
    NumberAnimation {
      target: pill
      property: "opacity"
      from: 0
      to: 1
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
    onStarted: {
      showPill = true
    }
    onStopped: {
      delayedHideAnim.start()
      root.shown()
    }
  }

  SequentialAnimation {
    id: delayedHideAnim
    running: false
    PauseAnimation {
      duration: 2500
    }
    ScriptAction {
      script: if (shouldAnimateHide) {
                hideAnim.start()
              }
    }
  }

  ParallelAnimation {
    id: hideAnim
    running: false
    NumberAnimation {
      target: pill
      property: "width"
      from: maxPillWidth
      to: 1
      duration: Style.animationNormal
      easing.type: Easing.InCubic
    }
    NumberAnimation {
      target: pill
      property: "height"
      from: maxPillHeight
      to: 1
      duration: Style.animationNormal
      easing.type: Easing.InCubic
    }
    NumberAnimation {
      target: pill
      property: "opacity"
      from: 1
      to: 0
      duration: Style.animationNormal
      easing.type: Easing.InCubic
    }
    onStopped: {
      showPill = false
      shouldAnimateHide = false
      root.hidden()
    }
  }

  NTooltip {
    id: tooltip
    target: pill
    text: root.tooltipText
    positionLeft: barPosition === "right"
    positionRight: barPosition === "left"
    positionAbove: Settings.data.bar.position === "bottom"
    delay: Style.tooltipDelayLong
  }

  Timer {
    id: showTimer
    interval: Style.pillDelay
    onTriggered: {
      if (!showPill) {
        showAnim.start()
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    onEntered: {
      hovered = true
      root.entered()
      tooltip.show()
      if (disableOpen || forceClose) {
        return
      }
      if (!forceOpen) {
        showDelayed()
      }
    }
    onExited: {
      hovered = false
      root.exited()
      if (!forceOpen && !forceClose) {
        hide()
      }
      tooltip.hide()
    }
    onClicked: function (mouse) {
      if (mouse.button === Qt.LeftButton) {
        root.clicked()
      } else if (mouse.button === Qt.RightButton) {
        root.rightClicked()
      } else if (mouse.button === Qt.MiddleButton) {
        root.middleClicked()
      }
    }
    onWheel: wheel => root.wheel(wheel.angleDelta.y)
  }

  function show() {
    if (!showPill) {
      shouldAnimateHide = autoHide
      showAnim.start()
    } else {
      hideAnim.stop()
      delayedHideAnim.restart()
    }
  }

  function hide() {
    if (forceOpen) {
      return
    }
    if (showPill) {
      hideAnim.start()
    }
    showTimer.stop()
  }

  function showDelayed() {
    if (!showPill) {
      shouldAnimateHide = autoHide
      showTimer.start()
    } else {
      hideAnim.stop()
      delayedHideAnim.restart()
    }
  }

  onForceOpenChanged: {
    if (forceOpen) {
      // Immediately lock open without animations
      showAnim.stop()
      hideAnim.stop()
      delayedHideAnim.stop()
      showPill = true
    } else {
      hide()
    }
  }
}
