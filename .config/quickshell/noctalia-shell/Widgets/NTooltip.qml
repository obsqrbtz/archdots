import QtQuick
import qs.Commons
import qs.Services

Window {
  id: root

  property bool isVisible: false
  property string text: "Placeholder"
  property Item target: null
  property int delay: Style.tooltipDelay
  property bool positionAbove: false
  property bool positionLeft: false
  property bool positionRight: false

  readonly property string barPosition: Settings.data.bar.position

  flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
  color: Color.transparent
  visible: false

  onIsVisibleChanged: {
    if (isVisible) {
      if (delay > 0) {
        timerShow.running = true
      } else {
        _showNow()
      }
    } else {
      _hideNow()
    }
  }

  function show() {
    isVisible = true
  }
  function hide() {
    isVisible = false
    timerShow.running = false
  }

  function _showNow() {
    // Compute new size everytime we show the tooltip
    width = Math.max(50 * scaling, tooltipText.implicitWidth + Style.marginL * 2 * scaling)
    height = Math.max(40 * scaling, tooltipText.implicitHeight + Style.marginM * 2 * scaling)

    if (!target) {
      return
    }

    // Auto-detect positioning based on bar position if not explicitly set
    var shouldPositionLeft = positionLeft
    var shouldPositionRight = positionRight
    var shouldPositionAbove = positionAbove

    // If no explicit positioning is set, auto-detect based on bar position
    if (!positionLeft && !positionRight && !positionAbove) {
      if (barPosition === "left") {
        shouldPositionRight = true
      } else if (barPosition === "right") {
        shouldPositionLeft = true
      } else if (barPosition === "bottom") {
        shouldPositionAbove = true
      }
      // For "top" bar, default to below (no change needed)
    }

    if (shouldPositionLeft) {
      // Position tooltip to the left of the target
      var pos = target.mapToGlobal(0, 0)
      x = pos.x - width - 12 // 12 px margin to the left
      y = pos.y - height / 2 + target.height / 2
    } else if (shouldPositionRight) {
      // Position tooltip to the right of the target
      var pos = target.mapToGlobal(target.width, 0)
      x = pos.x + 12 // 12 px margin to the right
      y = pos.y - height / 2 + target.height / 2
    } else if (shouldPositionAbove) {
      // Position tooltip above the target
      var pos = target.mapToGlobal(0, 0)
      x = pos.x - width / 2 + target.width / 2
      y = pos.y - height - 12 // 12 px margin above
    } else {
      // Position tooltip below the target
      var pos = target.mapToGlobal(0, target.height)
      x = pos.x - width / 2 + target.width / 2
      y = pos.y + 12 // 12 px margin below
    }

    // Start with animation values
    tooltipRect.scaleValue = 0.8
    tooltipRect.opacityValue = 0.0
    visible = true

    // Use a timer to trigger the animation after the component is visible
    showTimer.start()
  }

  function _hideNow() {
    // Start hide animation
    tooltipRect.scaleValue = 0.8
    tooltipRect.opacityValue = 0.0

    // Hide after animation completes
    hideTimer.start()
  }

  Connections {
    target: root.target
    function onXChanged() {
      if (root.visible) {
        root._showNow()
      }
    }
    function onYChanged() {
      if (root.visible) {
        root._showNow()
      }
    }
    function onWidthChanged() {
      if (root.visible) {
        root._showNow()
      }
    }
    function onHeightChanged() {
      if (root.visible) {
        root._showNow()
      }
    }
  }
  Connections {
    target: root
    function onTextChanged() {
      if (root.visible) {
        root._showNow()
      }
    }
  }

  Timer {
    id: timerShow
    interval: delay
    running: false
    repeat: false
    onTriggered: {
      _showNow()
      running = false
    }
  }

  // Timer to hide tooltip after animation
  Timer {
    id: hideTimer
    interval: Style.animationNormal
    repeat: false
    onTriggered: {
      visible = false
    }
  }

  // Timer to trigger show animation
  Timer {
    id: showTimer
    interval: Style.animationFast / 15 // Very short delay to ensure component is visible
    repeat: false
    onTriggered: {
      // Animate to final values
      tooltipRect.scaleValue = 1.0
      tooltipRect.opacityValue = 1.0
    }
  }

  Rectangle {
    id: tooltipRect
    anchors.fill: parent
    radius: Style.radiusM * scaling
    color: Color.mSurface
    border.color: Color.mOutline
    border.width: Math.max(1, Style.borderS * scaling)
    z: 1

    // Animation properties
    property real scaleValue: 1.0
    property real opacityValue: 1.0

    scale: scaleValue
    opacity: opacityValue

    // Animation behaviors
    Behavior on scale {
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutExpo
      }
    }

    Behavior on opacity {
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutQuad
      }
    }

    NText {
      id: tooltipText
      anchors.centerIn: parent
      text: root.text
      font.pointSize: Style.fontSizeM * scaling
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      wrapMode: Text.Wrap
    }
  }
}
