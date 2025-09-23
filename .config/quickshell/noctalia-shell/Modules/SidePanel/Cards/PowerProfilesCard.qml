import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Services
import qs.Widgets

// Power Profiles: performance, balanced, eco
NBox {

  property real spacing: 0

  // Centralized service
  readonly property bool hasPP: PowerProfileService.available

  RowLayout {
    id: powerRow
    anchors.fill: parent
    anchors.margins: Style.marginS * scaling
    spacing: spacing
    Item {
      Layout.fillWidth: true
    }
    // Performance
    NIconButton {
      icon: PowerProfileService.getIcon(PowerProfile.Performance)
      tooltipText: `Set "${PowerProfileService.getName(PowerProfile.Performance)}" power profile`
      enabled: hasPP
      opacity: enabled ? Style.opacityFull : Style.opacityMedium
      colorBg: (enabled && PowerProfileService.profile === PowerProfile.Performance) ? Color.mPrimary : Color.mSurfaceVariant
      colorFg: (enabled && PowerProfileService.profile === PowerProfile.Performance) ? Color.mOnPrimary : Color.mPrimary
      onClicked: PowerProfileService.setProfile(PowerProfile.Performance)
    }
    // Balanced
    NIconButton {
      icon: PowerProfileService.getIcon(PowerProfile.Balanced)
      tooltipText: `Set "${PowerProfileService.getName(PowerProfile.Balanced)}" power profile`
      enabled: hasPP
      opacity: enabled ? Style.opacityFull : Style.opacityMedium
      colorBg: (enabled && PowerProfileService.profile === PowerProfile.Balanced) ? Color.mPrimary : Color.mSurfaceVariant
      colorFg: (enabled && PowerProfileService.profile === PowerProfile.Balanced) ? Color.mOnPrimary : Color.mPrimary
      onClicked: PowerProfileService.setProfile(PowerProfile.Balanced)
    }
    // Eco
    NIconButton {
      icon: PowerProfileService.getIcon(PowerProfile.PowerSaver)
      tooltipText: `Set "${PowerProfileService.getName(PowerProfile.PowerSaver)}" power profile`
      enabled: hasPP
      opacity: enabled ? Style.opacityFull : Style.opacityMedium
      colorBg: (enabled && PowerProfileService.profile === PowerProfile.PowerSaver) ? Color.mPrimary : Color.mSurfaceVariant
      colorFg: (enabled && PowerProfileService.profile === PowerProfile.PowerSaver) ? Color.mOnPrimary : Color.mPrimary
      onClicked: PowerProfileService.setProfile(PowerProfile.PowerSaver)
    }
    Item {
      Layout.fillWidth: true
    }
  }
}
