import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets

Rectangle {
  id: root

  property color selectedColor: "#000000"

  signal colorSelected(color color)

  implicitWidth: 150 * scaling
  implicitHeight: Math.round(Style.baseWidgetSize * 1.1 * scaling)

  radius: Style.radiusM * scaling
  color: Color.mSurface
  border.color: Color.mOutline
  border.width: Math.max(1, Style.borderS * scaling)

  // Minimized Look
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      var dialog = Qt.createComponent("NColorPickerDialog.qml").createObject(root, {
                                                                               "selectedColor": selectedColor,
                                                                               "parent": Overlay.overlay
                                                                             })
      // Connect the dialog's signal to the picker's signal
      dialog.colorSelected.connect(function (color) {
        root.selectedColor = color
        root.colorSelected(color)
      })

      dialog.open()
    }

    RowLayout {
      anchors.fill: parent
      anchors {
        leftMargin: Style.marginL * scaling
        rightMargin: Style.marginL * scaling
      }
      spacing: Style.marginS * scaling

      // Color preview circle
      Rectangle {
        Layout.preferredWidth: root.height * 0.6 * scaling
        Layout.preferredHeight: root.height * 0.6 * scaling
        radius: Layout.preferredWidth * 0.5
        color: root.selectedColor
        border.color: Color.mOutline
        border.width: Math.max(1, Style.borderS * scaling)
      }

      NText {
        text: root.selectedColor.toString().toUpperCase()
        font.family: Settings.data.ui.fontFixed
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
      }

      NIcon {
        icon: "color-picker"
        color: Color.mOnSurfaceVariant
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
      }
    }
  }
}
