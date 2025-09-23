import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

Text {
  id: root

  font.family: Settings.data.ui.fontDefault
  font.pointSize: Style.fontSizeM * scaling
  font.weight: Style.fontWeightMedium
  font.hintingPreference: Font.PreferNoHinting
  font.kerning: true
  color: Color.mOnSurface
  renderType: Text.QtRendering
  verticalAlignment: Text.AlignVCenter
}
