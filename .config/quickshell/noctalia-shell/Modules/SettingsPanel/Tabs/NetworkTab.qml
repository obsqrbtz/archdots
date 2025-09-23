import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL * scaling

  NHeader {
    label: "Manage Wi-Fi and Bluetooth connections."
  }

  NToggle {
    label: "Enable Wi-Fi"
    checked: Settings.data.network.wifiEnabled
    onToggled: checked => NetworkService.setWifiEnabled(checked)
  }

  NToggle {
    label: "Enable Bluetooth"
    checked: Settings.data.network.bluetoothEnabled
    onToggled: checked => BluetoothService.setBluetoothEnabled(checked)
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }
}
