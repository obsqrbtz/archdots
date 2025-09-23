import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets

// Unified system card: monitors CPU, temp, memory, disk
NBox {
  id: root

  ColumnLayout {
    id: content
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.leftMargin: Style.marginS * scaling
    anchors.rightMargin: Style.marginS * scaling
    anchors.topMargin: Style.marginXS * scaling
    anchors.bottomMargin: Style.marginM * scaling
    spacing: Style.marginS * scaling

    NCircleStat {
      value: SystemStatService.cpuUsage
      icon: "cpu-usage"
      flat: true
      contentScale: 0.8
      width: 72 * scaling
      height: 68 * scaling
    }
    NCircleStat {
      value: SystemStatService.cpuTemp
      suffix: "°C"
      icon: "cpu-temperature"
      flat: true
      contentScale: 0.8
      width: 72 * scaling
      height: 68 * scaling
    }
    NCircleStat {
      value: SystemStatService.memPercent
      icon: "memory"
      flat: true
      contentScale: 0.8
      width: 72 * scaling
      height: 68 * scaling
    }
    NCircleStat {
      value: SystemStatService.diskPercent
      icon: "storage"
      flat: true
      contentScale: 0.8
      width: 72 * scaling
      height: 68 * scaling
    }
  }
}
