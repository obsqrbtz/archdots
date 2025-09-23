import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Text {
  id: root

  property string icon: Icons.defaultIcon

  visible: (icon !== undefined) && (icon !== "")
  text: {
    if ((icon === undefined) || (icon === "")) {
      return ""
    }
    if (Icons.get(icon) === undefined) {
      Logger.warn("Icon", `"${icon}"`, "doesn't exist in the icons font")
      Logger.callStack()
      return Icons.get(Icons.defaultIcon)
    }
    return Icons.get(icon)
  }
  font.family: Icons.fontFamily
  font.pointSize: Style.fontSizeL * scaling
  color: Color.mOnSurface
  verticalAlignment: Text.AlignVCenter
}
