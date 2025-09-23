import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.Commons
import qs.Services

Slider {
  id: root

  property var cutoutColor: Color.mSurface
  property bool snapAlways: true
  property real heightRatio: 0.7

  readonly property real knobDiameter: Math.round(Style.baseWidgetSize * heightRatio * scaling)
  readonly property real trackHeight: knobDiameter * 0.4
  readonly property real cutoutExtra: Math.round(Style.baseWidgetSize * 0.1 * scaling)

  snapMode: snapAlways ? Slider.SnapAlways : Slider.SnapOnRelease
  implicitHeight: Math.max(trackHeight, knobDiameter)

  background: Rectangle {
    x: root.leftPadding
    y: root.topPadding + root.availableHeight / 2 - height / 2
    implicitWidth: Style.sliderWidth
    implicitHeight: trackHeight
    width: root.availableWidth
    height: implicitHeight
    radius: 0
    color: Qt.alpha(Color.mSurface, 0.5)
    border.color: Qt.alpha(Color.mOutline, 0.5)
    border.width: Math.max(1, Style.borderS * scaling)

    // Animated gradient active track
    Rectangle {
      id: activeTrack
      width: root.visualPosition * parent.width
      height: parent.height
      radius: parent.radius

      // Animated gradient fill
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop {
          position: 0.0
          color: Qt.darker(Color.mPrimary, 1.2)
          Behavior on color {
            ColorAnimation {
              duration: 300
            }
          }
        }
        GradientStop {
          position: 0.5
          color: Color.mPrimary
          SequentialAnimation on position {
            loops: Animation.Infinite
            NumberAnimation {
              from: 0.3
              to: 0.7
              duration: 2000
              easing.type: Easing.InOutSine
            }
            NumberAnimation {
              from: 0.7
              to: 0.3
              duration: 2000
              easing.type: Easing.InOutSine
            }
          }
        }
        GradientStop {
          position: 1.0
          color: Qt.lighter(Color.mPrimary, 1.2)
        }
      }
    }

    // Circular cutout
    Rectangle {
      id: knobCutout
      width: knobDiameter + cutoutExtra
      height: knobDiameter + cutoutExtra
      radius: width / 2
      color: root.cutoutColor !== undefined ? root.cutoutColor : Color.mSurface
      x: root.leftPadding + root.visualPosition * (root.availableWidth - root.knobDiameter) - cutoutExtra / 2
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  handle: Item {
    width: knob.implicitWidth
    height: knob.implicitHeight
    x: root.leftPadding + Math.round(root.visualPosition * (root.availableWidth - width))
    y: root.topPadding + root.availableHeight / 2 - height / 2

    Rectangle {
      id: knob
      implicitWidth: knobDiameter
      implicitHeight: knobDiameter
      radius: width * 0.5
      color: root.pressed ? Color.mTertiary : Color.mSurface
      border.color: Color.mPrimary
      border.width: Math.max(1, Style.borderL * scaling)
      anchors.centerIn: parent

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }
    }
  }
}
