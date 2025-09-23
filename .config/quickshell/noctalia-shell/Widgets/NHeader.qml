import QtQuick
import QtQuick.Layouts
import qs.Commons

ColumnLayout {
  id: root

  property string label: ""
  property string description: ""

  spacing: Style.marginXXS * scaling
  Layout.fillWidth: true
  Layout.bottomMargin: Style.marginM * scaling

  NText {
    text: root.label
    font.pointSize: Style.fontSizeXL * scaling
    font.weight: Style.fontWeightBold
    color: Color.mSecondary
    visible: root.title !== ""
  }

  NText {
    text: root.description
    font.pointSize: Style.fontSizeM * scaling
    color: Color.mOnSurfaceVariant
    wrapMode: Text.WordWrap
    Layout.fillWidth: true
    visible: root.description !== ""
  }
}
