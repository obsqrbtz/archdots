import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import qs.Commons

T.ScrollView {
  id: root

  property color handleColor: Qt.alpha(Color.mTertiary, 0.8)
  property color handleHoverColor: handleColor
  property color handlePressedColor: handleColor
  property color trackColor: Color.transparent
  property real handleWidth: 6 * scaling
  property real handleRadius: Style.radiusM * scaling
  property int verticalPolicy: ScrollBar.AsNeeded
  property int horizontalPolicy: ScrollBar.AsNeeded

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)

  ScrollBar.vertical: ScrollBar {
    parent: root
    x: root.mirrored ? 0 : root.width - width
    y: root.topPadding
    height: root.availableHeight
    active: root.ScrollBar.horizontal.active
    policy: root.verticalPolicy

    contentItem: Rectangle {
      implicitWidth: root.handleWidth
      implicitHeight: 100
      radius: root.handleRadius
      color: parent.pressed ? root.handlePressedColor : parent.hovered ? root.handleHoverColor : root.handleColor
      opacity: parent.policy === ScrollBar.AlwaysOn || parent.active ? 1.0 : 0.0

      Behavior on opacity {
        NumberAnimation {
          duration: Style.animationFast
        }
      }

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }
    }

    background: Rectangle {
      implicitWidth: root.handleWidth
      implicitHeight: 100
      color: root.trackColor
      opacity: parent.policy === ScrollBar.AlwaysOn || parent.active ? 0.3 : 0.0
      radius: root.handleRadius / 2

      Behavior on opacity {
        NumberAnimation {
          duration: Style.animationFast
        }
      }
    }
  }

  ScrollBar.horizontal: ScrollBar {
    parent: root
    x: root.leftPadding
    y: root.height - height
    width: root.availableWidth
    active: root.ScrollBar.vertical.active
    policy: root.horizontalPolicy

    contentItem: Rectangle {
      implicitWidth: 100
      implicitHeight: root.handleWidth
      radius: root.handleRadius
      color: parent.pressed ? root.handlePressedColor : parent.hovered ? root.handleHoverColor : root.handleColor
      opacity: parent.policy === ScrollBar.AlwaysOn || parent.active ? 1.0 : 0.0

      Behavior on opacity {
        NumberAnimation {
          duration: Style.animationFast
        }
      }

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }
    }

    background: Rectangle {
      implicitWidth: 100
      implicitHeight: root.handleWidth
      color: root.trackColor
      opacity: parent.policy === ScrollBar.AlwaysOn || parent.active ? 0.3 : 0.0
      radius: root.handleRadius / 2

      Behavior on opacity {
        NumberAnimation {
          duration: Style.animationFast
        }
      }
    }
  }
}
