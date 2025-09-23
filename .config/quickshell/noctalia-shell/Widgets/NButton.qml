import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons

Rectangle {
  id: root

  // Public properties
  property string text: ""
  property string icon: ""
  property string tooltipText
  property color backgroundColor: Color.mPrimary
  property color textColor: Color.mOnPrimary
  property color hoverColor: Color.mTertiary
  property color pressColor: Color.mSecondary
  property bool enabled: true
  property real fontSize: Style.fontSizeM * scaling
  property int fontWeight: Style.fontWeightBold
  property real iconSize: Style.fontSizeL * scaling
  property bool outlined: false

  // Signals
  signal clicked
  signal rightClicked
  signal middleClicked

  // Internal properties
  property bool hovered: false
  property bool pressed: false

  // Dimensions
  implicitWidth: contentRow.implicitWidth + (Style.marginL * 2 * scaling)
  implicitHeight: Math.max(Style.baseWidgetSize * scaling, contentRow.implicitHeight + (Style.marginM * scaling))

  // Appearance
  radius: Style.radiusS * scaling
  color: {
    if (!enabled)
      return outlined ? Color.transparent : Qt.lighter(Color.mSurfaceVariant, 1.2)
    if (pressed)
      return pressColor
    if (hovered)
      return hoverColor
    return outlined ? Color.transparent : backgroundColor
  }

  border.width: outlined ? Math.max(1, Style.borderS * scaling) : 0
  border.color: {
    if (!enabled)
      return Color.mOutline
    if (pressed || hovered)
      return backgroundColor
    return outlined ? backgroundColor : Color.transparent
  }

  opacity: enabled ? 1.0 : 0.6

  Behavior on color {
    ColorAnimation {
      duration: Style.animationFast
      easing.type: Easing.OutCubic
    }
  }

  Behavior on border.color {
    ColorAnimation {
      duration: Style.animationFast
      easing.type: Easing.OutCubic
    }
  }

  // Content
  RowLayout {
    id: contentRow
    anchors.centerIn: parent
    spacing: Style.marginXS * scaling

    // Icon (optional)
    NIcon {
      Layout.alignment: Qt.AlignVCenter
      visible: root.icon !== ""

      icon: root.icon
      font.pointSize: root.iconSize
      color: {
        if (!root.enabled)
          return Color.mOnSurfaceVariant
        if (root.outlined) {
          if (root.pressed || root.hovered)
            return root.backgroundColor
          return root.backgroundColor
        }
        return root.textColor
      }

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
          easing.type: Easing.OutCubic
        }
      }
    }

    // Text
    NText {
      Layout.alignment: Qt.AlignVCenter
      visible: root.text !== ""
      text: root.text
      font.pointSize: root.fontSize
      font.weight: root.fontWeight
      color: {
        if (!root.enabled)
          return Color.mOnSurfaceVariant
        if (root.outlined) {
          if (root.pressed || root.hovered)
            return root.textColor
          return root.backgroundColor
        }
        return root.textColor
      }

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
          easing.type: Easing.OutCubic
        }
      }
    }
  }

  NTooltip {
    id: tooltip
    target: root
    positionAbove: Settings.data.bar.position === "bottom"
    text: root.tooltipText
  }

  // Mouse interaction
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

    onEntered: {
      root.hovered = true
      if (tooltipText) {
        tooltip.show()
      }
    }
    onExited: {
      root.hovered = false
      root.pressed = false
      if (tooltipText) {
        tooltip.hide()
      }
    }
    onPressed: mouse => {
                 root.pressed = true
               }
    onReleased: mouse => {
                  root.pressed = false
                  if (tooltipText) {
                    tooltip.hide()
                  }
                  if (!root.hovered) {
                    return
                  }

                  if (mouse.button === Qt.LeftButton) {
                    root.clicked()
                  } else if (mouse.button == Qt.RightButton) {
                    root.rightClicked()
                  } else if (mouse.button == Qt.MiddleButton) {
                    root.middleClicked
                  }
                }
    onCanceled: {
      root.pressed = false
      root.hovered = false
      if (tooltipText) {
        tooltip.hide()
      }
    }
  }
}
