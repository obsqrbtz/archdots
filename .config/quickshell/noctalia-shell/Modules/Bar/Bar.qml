import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import qs.Commons
import qs.Services
import qs.Widgets
import qs.Modules.Notification
import qs.Modules.Bar.Extras

Variants {
  model: Quickshell.screens

  delegate: Loader {
    id: root

    required property ShellScreen modelData
    property real scaling: ScalingService.getScreenScale(modelData)

    Connections {
      target: ScalingService
      function onScaleChanged(screenName, scale) {
        if ((modelData !== null) && (screenName === modelData.name)) {
          scaling = scale
        }
      }
    }

    active: Settings.isLoaded && modelData && modelData.name ? (Settings.data.bar.monitors.includes(modelData.name) || (Settings.data.bar.monitors.length === 0)) : false

    sourceComponent: PanelWindow {
      screen: modelData || null

      WlrLayershell.namespace: "noctalia-bar"

      implicitHeight: (Settings.data.bar.position === "left" || Settings.data.bar.position === "right") ? screen.height : Math.round(Style.barHeight * scaling)
      implicitWidth: (Settings.data.bar.position === "left" || Settings.data.bar.position === "right") ? Math.round(Style.barHeight * scaling) : screen.width
      color: Color.transparent

      anchors {
        top: Settings.data.bar.position === "top" || Settings.data.bar.position === "left" || Settings.data.bar.position === "right"
        bottom: Settings.data.bar.position === "bottom" || Settings.data.bar.position === "left" || Settings.data.bar.position === "right"
        left: Settings.data.bar.position === "left" || Settings.data.bar.position === "top" || Settings.data.bar.position === "bottom"
        right: Settings.data.bar.position === "right" || Settings.data.bar.position === "top" || Settings.data.bar.position === "bottom"
      }

      // Floating bar margins - only apply when floating is enabled
      // Also don't apply margin on the opposite side ot the bar orientation, ex: if bar is floating on top, margin is only applied on top, not bottom.
      margins {
        top: Settings.data.bar.floating && Settings.data.bar.position !== "bottom" ? Settings.data.bar.marginVertical * Style.marginXL * scaling : 0
        bottom: Settings.data.bar.floating && Settings.data.bar.position !== "top" ? Settings.data.bar.marginVertical * Style.marginXL * scaling : 0
        left: Settings.data.bar.floating && Settings.data.bar.position !== "right" ? Settings.data.bar.marginHorizontal * Style.marginXL * scaling : 0
        right: Settings.data.bar.floating && Settings.data.bar.position !== "left" ? Settings.data.bar.marginHorizontal * Style.marginXL * scaling : 0
      }

      Item {
        anchors.fill: parent
        clip: true

        // Background fill with shadow
        Rectangle {
          id: bar

          anchors.fill: parent
          color: Qt.alpha(Color.mSurface, Settings.data.bar.backgroundOpacity)

          // Floating bar rounded corners
          radius: Settings.data.bar.floating ? Style.radiusL : 0
        }

        Loader {
          anchors.fill: parent
          sourceComponent: (Settings.data.bar.position === "left" || Settings.data.bar.position === "right") ? verticalBarComponent : horizontalBarComponent
        }

        // For vertical bars
        Component {
          id: verticalBarComponent
          Item {
            anchors.fill: parent

            // Top section (left widgets)
            ColumnLayout {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.top
              anchors.topMargin: Style.marginM * root.scaling
              spacing: Style.marginS * root.scaling

              Repeater {
                model: Settings.data.bar.widgets.left
                delegate: BarWidgetLoader {
                  widgetId: (modelData.id !== undefined ? modelData.id : "")
                  widgetProps: {
                    "screen": root.modelData || null,
                    "scaling": ScalingService.getScreenScale(screen),
                    "widgetId": modelData.id,
                    "section": "left",
                    "sectionWidgetIndex": index,
                    "sectionWidgetsCount": Settings.data.bar.widgets.left.length
                  }
                  Layout.alignment: Qt.AlignHCenter
                }
              }
            }

            // Center section (center widgets)
            ColumnLayout {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.marginS * root.scaling

              Repeater {
                model: Settings.data.bar.widgets.center
                delegate: BarWidgetLoader {
                  widgetId: (modelData.id !== undefined ? modelData.id : "")
                  widgetProps: {
                    "screen": root.modelData || null,
                    "scaling": ScalingService.getScreenScale(screen),
                    "widgetId": modelData.id,
                    "section": "center",
                    "sectionWidgetIndex": index,
                    "sectionWidgetsCount": Settings.data.bar.widgets.center.length
                  }
                  Layout.alignment: Qt.AlignHCenter
                }
              }
            }

            // Bottom section (right widgets)
            ColumnLayout {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.bottom: parent.bottom
              anchors.bottomMargin: Style.marginM * root.scaling
              spacing: Style.marginS * root.scaling

              Repeater {
                model: Settings.data.bar.widgets.right
                delegate: BarWidgetLoader {
                  widgetId: (modelData.id !== undefined ? modelData.id : "")
                  widgetProps: {
                    "screen": root.modelData || null,
                    "scaling": ScalingService.getScreenScale(screen),
                    "widgetId": modelData.id,
                    "section": "right",
                    "sectionWidgetIndex": index,
                    "sectionWidgetsCount": Settings.data.bar.widgets.right.length
                  }
                  Layout.alignment: Qt.AlignHCenter
                }
              }
            }
          }
        }

        // For horizontal bars
        Component {
          id: horizontalBarComponent
          Item {
            anchors.fill: parent

            // Left Section
            RowLayout {
              id: leftSection
              objectName: "leftSection"
              anchors.left: parent.left
              anchors.leftMargin: Style.marginS * root.scaling
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.marginS * root.scaling

              Repeater {
                model: Settings.data.bar.widgets.left
                delegate: BarWidgetLoader {
                  widgetId: (modelData.id !== undefined ? modelData.id : "")
                  widgetProps: {
                    "screen": root.modelData || null,
                    "scaling": ScalingService.getScreenScale(screen),
                    "widgetId": modelData.id,
                    "section": "left",
                    "sectionWidgetIndex": index,
                    "sectionWidgetsCount": Settings.data.bar.widgets.left.length
                  }
                  Layout.alignment: Qt.AlignVCenter
                }
              }
            }

            // Center Section
            RowLayout {
              id: centerSection
              objectName: "centerSection"
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.marginS * root.scaling

              Repeater {
                model: Settings.data.bar.widgets.center
                delegate: BarWidgetLoader {
                  widgetId: (modelData.id !== undefined ? modelData.id : "")
                  widgetProps: {
                    "screen": root.modelData || null,
                    "scaling": ScalingService.getScreenScale(screen),
                    "widgetId": modelData.id,
                    "section": "center",
                    "sectionWidgetIndex": index,
                    "sectionWidgetsCount": Settings.data.bar.widgets.center.length
                  }
                  Layout.alignment: Qt.AlignVCenter
                }
              }
            }

            // Right Section
            RowLayout {
              id: rightSection
              objectName: "rightSection"
              anchors.right: parent.right
              anchors.rightMargin: Style.marginS * root.scaling
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.marginS * root.scaling

              Repeater {
                model: Settings.data.bar.widgets.right
                delegate: BarWidgetLoader {
                  widgetId: (modelData.id !== undefined ? modelData.id : "")
                  widgetProps: {
                    "screen": root.modelData || null,
                    "scaling": ScalingService.getScreenScale(screen),
                    "widgetId": modelData.id,
                    "section": "right",
                    "sectionWidgetIndex": index,
                    "sectionWidgetsCount": Settings.data.bar.widgets.right.length
                  }
                  Layout.alignment: Qt.AlignVCenter
                }
              }
            }
          }
        }
      }
    }
  }
}
