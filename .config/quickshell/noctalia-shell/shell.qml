
/*
 * Noctalia – made by https://github.com/noctalia-dev
 * Licensed under the MIT License.
 * Forks and modifications are allowed under the MIT License,
 * but proper credit must be given to the original author.
*/

// Disable reload popup add this as a new row:  //pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.Commons
import qs.Modules.Launcher
import qs.Modules.Background
import qs.Modules.Bar
import qs.Modules.Bar.Extras
import qs.Modules.BluetoothPanel
import qs.Modules.Calendar
import qs.Modules.Dock
import qs.Modules.IPC
import qs.Modules.LockScreen
import qs.Modules.Notification
import qs.Modules.SettingsPanel
import qs.Modules.PowerPanel
import qs.Modules.SidePanel
import qs.Modules.Toast
import qs.Modules.WiFiPanel
import qs.Modules.WallpaperSelector
import qs.Services
import qs.Widgets

ShellRoot {
  id: shellRoot

  Background {}
  Overview {}
  ScreenCorners {}
  Bar {}
  Dock {}

  Notification {
    id: notification
  }

  LockScreen {
    id: lockScreen
  }

  ToastOverlay {}

  IPCManager {}

  // ------------------------------
  // All the NPanels
  Launcher {
    id: launcherPanel
    objectName: "launcherPanel"
  }

  SidePanel {
    id: sidePanel
    objectName: "sidePanel"
  }

  Calendar {
    id: calendarPanel
    objectName: "calendarPanel"
  }

  SettingsPanel {
    id: settingsPanel
    objectName: "settingsPanel"
  }

  NotificationHistoryPanel {
    id: notificationHistoryPanel
    objectName: "notificationHistoryPanel"
  }

  PowerPanel {
    id: powerPanel
    objectName: "powerPanel"
  }

  WiFiPanel {
    id: wifiPanel
    objectName: "wifiPanel"
  }

  BluetoothPanel {
    id: bluetoothPanel
    objectName: "bluetoothPanel"
  }

  WallpaperSelector {
    id: wallpaperSelector
    objectName: "wallpaperSelector"
  }

  Component.onCompleted: {
    // Save a ref. to our lockScreen so we can access it  easily
    PanelService.lockScreen = lockScreen
  }
}
