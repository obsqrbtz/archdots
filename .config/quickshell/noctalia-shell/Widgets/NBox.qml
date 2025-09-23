import QtQuick
import qs.Commons
import qs.Commons
import qs.Services

// Rounded group container using the variant surface color.
// To be used in side panels and settings panes to group fields or buttons.
Rectangle {
  id: root

  implicitWidth: childrenRect.width
  implicitHeight: childrenRect.height

  color: Color.mSurfaceVariant
  radius: Style.radiusM * scaling
  border.color: Color.mOutline
  border.width: Math.max(1, Style.borderS * scaling)
  clip: true
}
