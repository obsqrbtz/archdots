import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: contentColumn
  spacing: Style.marginL * scaling
  width: root.width

  NHeader {
    label: "System hooks"
    description: "Configure commands to be executed when system events occur."
  }

  // Enable/Disable Toggle
  NToggle {
    label: "Enable hooks"
    description: "Enable or disable all hook commands."
    checked: Settings.data.hooks.enabled
    onToggled: checked => Settings.data.hooks.enabled = checked
  }

  ColumnLayout {
    visible: Settings.data.hooks.enabled
    spacing: Style.marginL * scaling
    Layout.fillWidth: true

    NDivider {
      Layout.fillWidth: true
    }

    // Wallpaper Hook Section
    NInputAction {
      id: wallpaperHookInput
      label: "Wallpaper changed"
      description: "Command to be executed when wallpaper changes."
      placeholderText: "e.g., notify-send \"Wallpaper\" \"Changed\""
      text: Settings.data.hooks.wallpaperChange
      onEditingFinished: {
        Settings.data.hooks.wallpaperChange = wallpaperHookInput.text
      }
      onActionClicked: {
        if (wallpaperHookInput.text) {
          HooksService.executeWallpaperHook("test", "test-screen")
        }
      }
      Layout.fillWidth: true
    }

    NDivider {
      Layout.fillWidth: true
    }

    // Dark Mode Hook Section
    NInputAction {
      id: darkModeHookInput
      label: "Theme changed"
      description: "Command to be executed when theme toggles between dark and light mode."
      placeholderText: "e.g., notify-send \"Theme\" \"Toggled\""
      text: Settings.data.hooks.darkModeChange
      onEditingFinished: {
        Settings.data.hooks.darkModeChange = darkModeHookInput.text
      }
      onActionClicked: {
        if (darkModeHookInput.text) {
          HooksService.executeDarkModeHook(Settings.data.colorSchemes.darkMode)
        }
      }
      Layout.fillWidth: true
    }

    NDivider {
      Layout.fillWidth: true
    }

    // Info section
    ColumnLayout {
      spacing: Style.marginM * scaling
      Layout.fillWidth: true

      NLabel {
        label: "Hook Command Information"
        description: "• Commands are executed via shell (sh -c)\n• Commands run in background (detached)\n• Test buttons execute with current values"
      }

      NLabel {
        label: "Available Parameters"
        description: "• Wallpaper Hook: $1 = wallpaper path, $2 = screen name\n• Theme Toggle Hook: $1 = true/false (dark mode state)"
      }
    }
  }
}
