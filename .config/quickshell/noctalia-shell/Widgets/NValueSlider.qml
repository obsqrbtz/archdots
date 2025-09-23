import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets

RowLayout {
  id: root

  property real from: 0
  property real to: 1
  property real value: 0
  property real stepSize: 0.01
  property var cutoutColor: Color.mSurface
  property bool snapAlways: true
  property real heightRatio: 0.7
  property string text: ""

  // Signals
  signal moved(real value)
  signal pressedChanged(bool pressed, real value)

  spacing: Style.marginL * scaling

  NSlider {
    id: slider
    Layout.fillWidth: true
    from: root.from
    to: root.to
    value: root.value
    stepSize: root.stepSize
    cutoutColor: root.cutoutColor
    snapAlways: root.snapAlways
    heightRatio: root.heightRatio
    onMoved: root.moved(value)
    onPressedChanged: root.pressedChanged(pressed, value)
  }

  NText {
    visible: root.text !== ""
    text: root.text
    font.family: Settings.data.ui.fontFixed
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: 40 * scaling
    horizontalAlignment: Text.AlignRight
  }
}
