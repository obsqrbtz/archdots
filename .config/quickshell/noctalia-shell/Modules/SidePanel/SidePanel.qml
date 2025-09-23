import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Modules.SidePanel.Cards
import qs.Commons
import qs.Services
import qs.Widgets

NPanel {
  id: root

  preferredWidth: 460
  preferredHeight: 734
  panelKeyboardFocus: true

  panelContent: Item {
    id: content

    property real cardSpacing: Style.marginL * scaling

    // Layout content
    ColumnLayout {
      id: layout
      x: content.cardSpacing
      y: content.cardSpacing
      width: parent.width - (2 * content.cardSpacing)
      spacing: content.cardSpacing

      // Cards (consistent inter-card spacing via ColumnLayout spacing)
      ProfileCard {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(64 * scaling)
      }

      WeatherCard {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(220 * scaling)
      }

      // Middle section: media + stats column
      RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(310 * scaling)
        spacing: content.cardSpacing

        // Media card
        MediaCard {
          Layout.fillWidth: true
          Layout.fillHeight: true
        }

        // System monitors combined in one card
        SystemMonitorCard {
          Layout.preferredWidth: Style.baseWidgetSize * 2.625 * scaling
          Layout.fillHeight: true
        }
      }

      // Bottom actions (two grouped rows of round buttons)
      RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(60 * scaling)
        spacing: content.cardSpacing

        // Power Profiles switcher
        PowerProfilesCard {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: content.cardSpacing
        }

        // Utilities buttons
        UtilitiesCard {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: content.cardSpacing
        }
      }
    }
  }
}
