import QtQuick
import QtQuick.Layouts
import qs.Commons

ColumnLayout {
  id: root

  property string label: ""
  property string description: ""
  property color labelColor: Color.mOnSurface
  property color descriptionColor: Color.mOnSurfaceVariant

  spacing: Style.marginXXS * scaling
  Layout.fillWidth: true

  NText {
    text: label
    font.pointSize: Style.fontSizeL * scaling
    font.weight: Style.fontWeightBold
    color: labelColor
    visible: label !== ""
    Layout.fillWidth: true
  }

  NText {
    text: description
    font.pointSize: Style.fontSizeS * scaling
    color: descriptionColor
    wrapMode: Text.WordWrap
    visible: description !== ""
    Layout.fillWidth: true
  }
}
