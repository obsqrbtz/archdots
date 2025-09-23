import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Commons
import qs.Services
import qs.Widgets

// Notification History panel
NPanel {
  id: root

  preferredWidth: 360
  preferredHeight: 480
  panelKeyboardFocus: true

  panelContent: Rectangle {
    id: notificationRect
    color: Color.transparent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL * scaling
      spacing: Style.marginM * scaling

      // Header section
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM * scaling

        NIcon {
          icon: "bell"
          font.pointSize: Style.fontSizeXXL * scaling
          color: Color.mPrimary
        }

        NText {
          text: "Notification history"
          font.pointSize: Style.fontSizeL * scaling
          font.weight: Style.fontWeightBold
          color: Color.mOnSurface
          Layout.fillWidth: true
        }

        NIconButton {
          icon: Settings.data.notifications.doNotDisturb ? "bell-off" : "bell"
          tooltipText: `'Do not disturb' ${Settings.data.notifications.doNotDisturb ? "enabled" : "disabled"}`
          baseSize: Style.baseWidgetSize * 0.8
          onClicked: Settings.data.notifications.doNotDisturb = !Settings.data.notifications.doNotDisturb
        }

        NIconButton {
          icon: "trash"
          tooltipText: "Clear history"
          baseSize: Style.baseWidgetSize * 0.8
          onClicked: {
            NotificationService.clearHistory()
            // Close panel as there is nothing more to see.
            root.close()
          }
        }

        NIconButton {
          icon: "close"
          tooltipText: "Close"
          baseSize: Style.baseWidgetSize * 0.8
          onClicked: root.close()
        }
      }

      NDivider {
        Layout.fillWidth: true
      }

      // Empty state when no notifications
      ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignHCenter
        visible: NotificationService.historyList.count === 0
        spacing: Style.marginL * scaling

        Item {
          Layout.fillHeight: true
        }

        NIcon {
          icon: "bell-off"
          font.pointSize: 64 * scaling
          color: Color.mOnSurfaceVariant
          Layout.alignment: Qt.AlignHCenter
        }

        NText {
          text: "No notifications"
          font.pointSize: Style.fontSizeL * scaling
          color: Color.mOnSurfaceVariant
          Layout.alignment: Qt.AlignHCenter
        }

        NText {
          text: "Your notifications will show up here as they arrive."
          font.pointSize: Style.fontSizeS * scaling
          color: Color.mOnSurfaceVariant
          Layout.alignment: Qt.AlignHCenter
          Layout.fillWidth: true
          wrapMode: Text.Wrap
          horizontalAlignment: Text.AlignHCenter
        }

        Item {
          Layout.fillHeight: true
        }
      }

      // Notification list
      NListView {
        id: notificationList
        Layout.fillWidth: true
        Layout.fillHeight: true
        horizontalPolicy: ScrollBar.AlwaysOff
        verticalPolicy: ScrollBar.AsNeeded

        model: NotificationService.historyList
        spacing: Style.marginM * scaling
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        visible: NotificationService.historyList.count > 0

        delegate: Rectangle {
          property string notificationId: model.id

          width: notificationList.width
          height: notificationLayout.implicitHeight + (Style.marginM * scaling * 2)
          radius: Style.radiusM * scaling
          color: Color.mSurfaceVariant
          border.color: Qt.alpha(Color.mOutline, Style.opacityMedium)
          border.width: Math.max(1, Style.borderS * scaling)

          // Smooth color transition on hover
          Behavior on color {
            ColorAnimation {
              duration: Style.animationFast
            }
          }

          RowLayout {
            id: notificationLayout
            anchors.fill: parent
            anchors.margins: Style.marginM * scaling
            spacing: Style.marginM * scaling

            ColumnLayout {
              NImageCircled {
                Layout.preferredWidth: 40 * scaling
                Layout.preferredHeight: 40 * scaling
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 20 * scaling
                imagePath: model.cachedImage || model.originalImage || ""
                borderColor: Color.transparent
                borderWidth: 0
                fallbackIcon: "bell"
                fallbackIconSize: 24 * scaling
              }
              Item {
                Layout.fillHeight: true
              }
            }

            // Notification content column
            ColumnLayout {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignTop
              spacing: Style.marginXS * scaling

              // Header row with app name and timestamp
              RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginS * scaling

                // Urgency indicator
                Rectangle {
                  Layout.preferredWidth: 6 * scaling
                  Layout.preferredHeight: 6 * scaling
                  Layout.alignment: Qt.AlignVCenter
                  radius: 3 * scaling
                  visible: model.urgency !== 1
                  color: {
                    if (model.urgency === 2)
                      return Color.mError
                    else if (model.urgency === 0)
                      return Color.mOnSurfaceVariant
                    else
                      return Color.transparent
                  }
                }

                NText {
                  text: model.appName || "Unknown App"
                  font.pointSize: Style.fontSizeXS * scaling
                  color: Color.mSecondary
                }

                NText {
                  text: Time.formatRelativeTime(model.timestamp)
                  font.pointSize: Style.fontSizeXS * scaling
                  color: Color.mSecondary
                }

                Item {
                  Layout.fillWidth: true
                }
              }

              // Summary
              NText {
                text: model.summary || "No summary"
                font.pointSize: Style.fontSizeM * scaling
                font.weight: Font.Medium
                color: Color.mOnSurface
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                maximumLineCount: 2
                elide: Text.ElideRight
              }

              // Body
              NText {
                text: model.body || ""
                font.pointSize: Style.fontSizeS * scaling
                color: Color.mOnSurfaceVariant
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                maximumLineCount: 3
                elide: Text.ElideRight
                visible: text.length > 0
              }
            }

            // Delete button
            NIconButton {
              icon: "trash"
              tooltipText: "Delete notification"
              baseSize: Style.baseWidgetSize * 0.7
              Layout.alignment: Qt.AlignTop

              onClicked: {
                // Remove from history using the service API
                NotificationService.removeFromHistory(notificationId)
              }
            }
          }
        }
      }
    }
  }
}
