import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets

Popup {
  id: root

  property color selectedColor: "#000000"
  property real currentHue: 0
  property real currentSaturation: 0

  signal colorSelected(color color)

  width: 580 * scaling
  height: {
    const h = scrollView.implicitHeight + padding * 2
    Math.min(h, screen?.height - Style.barHeight * scaling - Style.marginL * 2)
  }
  padding: Style.marginXL * scaling

  // Center popup in parent
  x: (parent.width - width) * 0.5
  y: (parent.height - height) * 0.5

  modal: true
  clip: true

  function rgbToHsv(r, g, b) {
    r /= 255
    g /= 255
    b /= 255
    var max = Math.max(r, g, b), min = Math.min(r, g, b)
    var h, s, v = max
    var d = max - min
    s = max === 0 ? 0 : d / max
    if (max === min) {
      h = 0
    } else {
      switch (max) {
      case r:
        h = (g - b) / d + (g < b ? 6 : 0)
        break
      case g:
        h = (b - r) / d + 2
        break
      case b:
        h = (r - g) / d + 4
        break
      }
      h /= 6
    }
    return [h * 360, s * 100, v * 100]
  }

  function hsvToRgb(h, s, v) {
    h /= 360
    s /= 100
    v /= 100

    var r, g, b
    var i = Math.floor(h * 6)
    var f = h * 6 - i
    var p = v * (1 - s)
    var q = v * (1 - f * s)
    var t = v * (1 - (1 - f) * s)

    switch (i % 6) {
    case 0:
      r = v
      g = t
      b = p
      break
    case 1:
      r = q
      g = v
      b = p
      break
    case 2:
      r = p
      g = v
      b = t
      break
    case 3:
      r = p
      g = q
      b = v
      break
    case 4:
      r = t
      g = p
      b = v
      break
    case 5:
      r = v
      g = p
      b = q
      break
    }

    return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)]
  }

  background: Rectangle {
    color: Color.mSurface
    radius: Style.radiusS * scaling
    border.color: Color.mPrimary
    border.width: Math.max(1, Style.borderM * scaling)
  }

  NScrollView {
    id: scrollView
    anchors.fill: parent

    verticalPolicy: ScrollBar.AlwaysOff
    horizontalPolicy: ScrollBar.AlwaysOff
    clip: true

    ColumnLayout {
      width: scrollView.availableWidth
      spacing: Style.marginL * scaling

      // Header
      RowLayout {
        Layout.fillWidth: true

        RowLayout {
          spacing: Style.marginS * scaling

          NIcon {
            icon: "color-picker"
            font.pointSize: Style.fontSizeXXL * scaling
            color: Color.mPrimary
          }

          NText {
            text: "Color picker"
            font.pointSize: Style.fontSizeXL * scaling
            font.weight: Style.fontWeightBold
            color: Color.mPrimary
          }
        }

        Item {
          Layout.fillWidth: true
        }

        NIconButton {
          icon: "close"
          onClicked: root.close()
        }
      }

      // Color preview section
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 80 * scaling
        radius: Style.radiusS * scaling
        color: root.selectedColor
        border.color: Color.mOutline
        border.width: Math.max(1, Style.borderS * scaling)

        ColumnLayout {
          spacing: 0
          anchors.fill: parent

          Item {
            Layout.fillHeight: true
          }

          NText {
            text: root.selectedColor.toString().toUpperCase()
            font.family: Settings.data.ui.fontFixed
            font.pointSize: Style.fontSizeL * scaling
            font.weight: Font.Bold
            color: root.selectedColor.r + root.selectedColor.g + root.selectedColor.b > 1.5 ? "#000000" : "#FFFFFF"
            Layout.alignment: Qt.AlignHCenter
          }

          NText {
            text: "RGB(" + Math.round(root.selectedColor.r * 255) + ", " + Math.round(root.selectedColor.g * 255) + ", " + Math.round(root.selectedColor.b * 255) + ")"
            font.family: Settings.data.ui.fontFixed
            font.pointSize: Style.fontSizeM * scaling
            color: root.selectedColor.r + root.selectedColor.g + root.selectedColor.b > 1.5 ? "#000000" : "#FFFFFF"
            Layout.alignment: Qt.AlignHCenter
          }

          Item {
            Layout.fillHeight: true
          }
        }
      }

      // Hex input
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM * scaling

        NLabel {
          label: "Hex color"
          description: "Enter a hexadecimal color code."
          Layout.fillWidth: true
        }

        NTextInput {
          text: root.selectedColor.toString().toUpperCase()
          fontFamily: Settings.data.ui.fontFixed
          Layout.fillWidth: true
          onEditingFinished: {
            if (/^#[0-9A-F]{6}$/i.test(text)) {
              root.selectedColor = text
            }
          }
        }
      }

      // RGB sliders section
      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: slidersSection.implicitHeight + Style.marginL * scaling * 2

        ColumnLayout {
          id: slidersSection
          anchors.fill: parent
          anchors.margins: Style.marginL * scaling
          spacing: Style.marginM * scaling

          NLabel {
            label: "RGB values"
            description: "Adjust red, green, blue, and brightness values."
            Layout.fillWidth: true
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM * scaling

            NText {
              text: "R"
              font.weight: Font.Bold
              Layout.preferredWidth: 20 * scaling
            }

            NValueSlider {
              id: redSlider
              Layout.fillWidth: true
              from: 0
              to: 255
              value: Math.round(root.selectedColor.r * 255)
              onMoved: value => {
                         root.selectedColor = Qt.rgba(value / 255, root.selectedColor.g, root.selectedColor.b, 1)
                         var hsv = root.rgbToHsv(root.selectedColor.r * 255, root.selectedColor.g * 255, root.selectedColor.b * 255)
                         root.currentHue = hsv[0]
                         root.currentSaturation = hsv[1]
                       }
              text: Math.round(value)
            }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM * scaling

            NText {
              text: "G"
              font.weight: Font.Bold
              Layout.preferredWidth: 20 * scaling
            }

            NValueSlider {
              id: greenSlider
              Layout.fillWidth: true
              from: 0
              to: 255
              value: Math.round(root.selectedColor.g * 255)
              onMoved: value => {
                         root.selectedColor = Qt.rgba(root.selectedColor.r, value / 255, root.selectedColor.b, 1)
                         // Update stored hue and saturation when RGB changes
                         var hsv = root.rgbToHsv(root.selectedColor.r * 255, root.selectedColor.g * 255, root.selectedColor.b * 255)
                         root.currentHue = hsv[0]
                         root.currentSaturation = hsv[1]
                       }
              text: Math.round(value)
            }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM * scaling

            NText {
              text: "B"
              font.weight: Font.Bold
              Layout.preferredWidth: 20 * scaling
            }

            NValueSlider {
              id: blueSlider
              Layout.fillWidth: true
              from: 0
              to: 255
              value: Math.round(root.selectedColor.b * 255)
              onMoved: value => {
                         root.selectedColor = Qt.rgba(root.selectedColor.r, root.selectedColor.g, value / 255, 1)
                         // Update stored hue and saturation when RGB changes
                         var hsv = root.rgbToHsv(root.selectedColor.r * 255, root.selectedColor.g * 255, root.selectedColor.b * 255)
                         root.currentHue = hsv[0]
                         root.currentSaturation = hsv[1]
                       }
              text: Math.round(value)
            }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM * scaling

            NText {
              text: "Brightness"
              font.weight: Font.Bold
              Layout.preferredWidth: 80 * scaling
            }

            NValueSlider {
              id: brightnessSlider
              Layout.fillWidth: true
              from: 0
              to: 100
              value: {
                var hsv = root.rgbToHsv(root.selectedColor.r * 255, root.selectedColor.g * 255, root.selectedColor.b * 255)
                return hsv[2]
              }
              onMoved: value => {
                         var hue = root.currentHue
                         var saturation = root.currentSaturation

                         if (hue === 0 && saturation === 0) {
                           var hsv = root.rgbToHsv(root.selectedColor.r * 255, root.selectedColor.g * 255, root.selectedColor.b * 255)
                           hue = hsv[0]
                           saturation = hsv[1]
                           root.currentHue = hue
                           root.currentSaturation = saturation
                         }

                         var rgb = root.hsvToRgb(hue, saturation, value)
                         root.selectedColor = Qt.rgba(rgb[0] / 255, rgb[1] / 255, rgb[2] / 255, 1)
                       }
              text: Math.round(brightnessSlider.value) + "%"
            }
          }
        }
      }

      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: themePalette.implicitHeight + Style.marginL * scaling * 2

        ColumnLayout {
          id: themePalette
          anchors.fill: parent
          anchors.margins: Style.marginL * scaling
          spacing: Style.marginS * scaling

          NLabel {
            label: "Theme colors"
            description: "Quick access to your theme's color palette."
            Layout.fillWidth: true
          }

          Flow {
            spacing: 6 * scaling
            Layout.fillWidth: true
            flow: Flow.LeftToRight

            Repeater {
              model: [Color.mPrimary, Color.mSecondary, Color.mTertiary, Color.mError, Color.mSurface, Color.mSurfaceVariant, Color.mOutline, "#FFFFFF", "#000000"]

              Rectangle {
                width: 24 * scaling
                height: 24 * scaling
                radius: 4 * scaling
                color: modelData
                border.color: root.selectedColor === modelData ? Color.mPrimary : Color.mOutline
                border.width: root.selectedColor === modelData ? 2 * scaling : 1 * scaling

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.selectedColor = modelData
                    var hsv = root.rgbToHsv(root.selectedColor.r * 255, root.selectedColor.g * 255, root.selectedColor.b * 255)
                    root.currentHue = hsv[0]
                    root.currentSaturation = hsv[1]
                  }
                }
              }
            }
          }
        }
      }

      NBox {
        Layout.fillWidth: true
        Layout.preferredHeight: genericPalette.implicitHeight + Style.marginL * scaling * 2

        ColumnLayout {
          id: genericPalette
          anchors.fill: parent
          anchors.margins: Style.marginL * scaling
          spacing: Style.marginS * scaling

          NLabel {
            label: "Palette"
            description: "Choose from a wide range of predefined colors."
            Layout.fillWidth: true
          }

          Flow {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6 * scaling
            flow: Flow.LeftToRight

            Repeater {
              model: ["#F44336", "#E91E63", "#9C27B0", "#673AB7", "#3F51B5", "#2196F3", "#03A9F4", "#00BCD4", "#009688", "#4CAF50", "#8BC34A", "#CDDC39", "#FFEB3B", "#FFC107", "#FF9800", "#FF5722", "#795548", "#9E9E9E", "#E74C3C", "#E67E22", "#F1C40F", "#2ECC71", "#1ABC9C", "#3498DB", "#2980B9", "#9B59B6", "#34495E", "#2C3E50", "#95A5A6", "#7F8C8D", "#FFFFFF", "#000000"]

              Rectangle {
                width: 24 * scaling
                height: 24 * scaling
                radius: Style.radiusXXS * scaling
                color: modelData
                border.color: root.selectedColor === modelData ? Color.mPrimary : Color.mOutline
                border.width: Math.max(1, root.selectedColor === modelData ? Style.borderM * scaling : Style.borderS * scaling)

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.selectedColor = modelData
                    var hsv = root.rgbToHsv(root.selectedColor.r * 255, root.selectedColor.g * 255, root.selectedColor.b * 255)
                    root.currentHue = hsv[0]
                    root.currentSaturation = hsv[1]
                  }
                }
              }
            }
          }
        }
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 20 * scaling
        Layout.bottomMargin: 20 * scaling
        spacing: 10 * scaling

        Item {
          Layout.fillWidth: true
        }

        NButton {
          id: cancelButton
          text: "Cancel"
          outlined: cancelButton.hovered ? false : true
          onClicked: {
            root.close()
          }
        }

        NButton {
          text: "Apply"
          icon: "check"
          onClicked: {
            root.colorSelected(root.selectedColor)
            root.close()
          }
        }
      }
    }
  }
}
