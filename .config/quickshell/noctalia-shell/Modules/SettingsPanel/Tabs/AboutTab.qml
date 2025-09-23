import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL * scaling

  property string latestVersion: GitHubService.latestVersion
  property string currentVersion: UpdateService.currentVersion
  property var contributors: GitHubService.contributors

  NHeader {
    label: "Noctalia shell"
    description: "A sleek and minimal desktop shell thoughtfully crafted for Wayland, built with Quickshell."
  }

  RowLayout {
    spacing: Style.marginL * scaling

    // Versions
    GridLayout {
      columns: 2
      rowSpacing: Style.marginXS * scaling
      columnSpacing: Style.marginS * scaling

      NText {
        text: "Latest version:"
        color: Color.mOnSurface
      }

      NText {
        text: root.latestVersion
        color: Color.mOnSurface
        font.weight: Style.fontWeightBold
      }

      NText {
        text: "Installed version:"
        color: Color.mOnSurface
      }

      NText {
        text: root.currentVersion
        color: Color.mOnSurface
        font.weight: Style.fontWeightBold
      }
    }

    Item {
      Layout.fillWidth: true
    }

    // Update button
    Rectangle {
      Layout.alignment: Qt.AlignRight
      Layout.preferredWidth: Math.round(updateRow.implicitWidth + (Style.marginL * scaling * 2))
      Layout.preferredHeight: Math.round(Style.barHeight * scaling)
      radius: Style.radiusL * scaling
      color: updateArea.containsMouse ? Color.mPrimary : Color.transparent
      border.color: Color.mPrimary
      border.width: Math.max(1, Style.borderS * scaling)
      visible: {
        if (root.latestVersion === "Unknown")
          return false

        const latest = root.latestVersion.replace("v", "").split(".")
        const current = root.currentVersion.replace("v", "").split(".")
        for (var i = 0; i < Math.max(latest.length, current.length); i++) {
          const l = parseInt(latest[i] || "0")
          const c = parseInt(current[i] || "0")
          if (l > c)
            return true

          if (l < c)
            return false
        }
        return false
      }

      RowLayout {
        id: updateRow
        anchors.centerIn: parent
        spacing: Style.marginS * scaling

        NIcon {
          icon: "download"
          font.pointSize: Style.fontSizeXXL * scaling
          color: updateArea.containsMouse ? Color.mSurface : Color.mPrimary
        }

        NText {
          id: updateText
          text: "Download latest release"
          font.pointSize: Style.fontSizeL * scaling
          color: updateArea.containsMouse ? Color.mSurface : Color.mPrimary
        }
      }

      MouseArea {
        id: updateArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          Quickshell.execDetached(["xdg-open", "https://github.com/Ly-sec/Noctalia/releases/latest"])
        }
      }
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  NHeader {
    label: "Contributors"
    description: `Shout-out to our ${root.contributors.length} <b>awesome</b> contributors!`
  }

  GridView {
    id: contributorsGrid
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: cellWidth * 3 // Fixed 3 columns
    Layout.preferredHeight: {
      if (root.contributors.length === 0)
        return 0
      const columns = 3
      const rows = Math.ceil(root.contributors.length / columns)
      return rows * cellHeight
    }
    cellWidth: Style.baseWidgetSize * 7 * scaling
    cellHeight: Style.baseWidgetSize * 3 * scaling
    model: root.contributors
    clip: true

    delegate: Rectangle {
      width: contributorsGrid.cellWidth - Style.marginM * scaling
      height: contributorsGrid.cellHeight - Style.marginM * scaling
      radius: Style.radiusL * scaling
      color: contributorArea.containsMouse ? Color.mTertiary : Color.transparent

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }

      RowLayout {
        anchors.fill: parent
        anchors.margins: Style.marginS * scaling
        spacing: Style.marginM * scaling

        Item {
          Layout.alignment: Qt.AlignVCenter
          Layout.preferredWidth: Style.baseWidgetSize * 2 * scaling
          Layout.preferredHeight: Style.baseWidgetSize * 2 * scaling

          NImageCircled {
            imagePath: modelData.avatar_url || ""
            anchors.fill: parent
            anchors.margins: Style.marginXS * scaling
            fallbackIcon: "person"
            borderColor: contributorArea.containsMouse ? Color.mOnTertiary : Color.mPrimary
            borderWidth: Math.max(1, Style.borderM * scaling)

            Behavior on borderColor {
              ColorAnimation {
                duration: Style.animationFast
              }
            }
          }
        }

        ColumnLayout {
          spacing: Style.marginXS * scaling
          Layout.alignment: Qt.AlignVCenter
          Layout.fillWidth: true

          NText {
            text: modelData.login || "Unknown"
            font.weight: Style.fontWeightBold
            color: contributorArea.containsMouse ? Color.mOnTertiary : Color.mOnSurface
            elide: Text.ElideRight
            Layout.fillWidth: true
          }

          NText {
            text: (modelData.contributions || 0) + " " + ((modelData.contributions || 0) === 1 ? "commit" : "commits")
            font.pointSize: Style.fontSizeXS * scaling
            color: contributorArea.containsMouse ? Color.mOnTertiary : Color.mOnSurface
          }
        }
      }

      MouseArea {
        id: contributorArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          if (modelData.html_url)
            Quickshell.execDetached(["xdg-open", modelData.html_url])
        }
      }
    }
  }

  Item {
    Layout.fillHeight: true
  }
}
