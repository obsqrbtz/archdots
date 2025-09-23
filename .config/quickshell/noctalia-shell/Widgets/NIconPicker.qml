import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import qs.Commons
import qs.Widgets
import qs.Services

Popup {
  id: root
  modal: true

  property string selectedIcon: ""
  property string initialIcon: ""

  signal iconSelected(string iconName)

  width: {
    var w = Math.round(Math.max(screen.width * 0.35, 900) * scaling)
    w = Math.min(w, screen.width - Style.marginL * 2)
    return w
  }
  height: {
    var h = Math.round(Math.max(screen.height * 0.65, 700) * scaling)
    h = Math.min(h, screen.height - Style.barHeight * scaling - Style.marginL * 2)
    return h
  }
  anchors.centerIn: Overlay.overlay
  padding: Style.marginXL * scaling

  property string query: ""
  property var allIcons: Object.keys(Icons.icons)
  property var filteredIcons: allIcons.filter(function (name) {
    return query === "" || name.toLowerCase().indexOf(query.toLowerCase()) !== -1
  })
  readonly property int columns: 6
  readonly property int cellW: Math.floor(grid.width / columns)
  readonly property int cellH: Math.round(cellW * 0.7 + 36 * scaling)

  onOpened: {
    selectedIcon = initialIcon
    query = initialIcon
    searchInput.forceActiveFocus()
  }

  background: Rectangle {
    color: Color.mSurface
    radius: Style.radiusL * scaling
    border.color: Color.mPrimary
    border.width: Style.borderM * scaling
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.marginM * scaling

    // Title row
    RowLayout {
      Layout.fillWidth: true
      NText {
        text: "Icon picker"
        font.pointSize: Style.fontSizeL * scaling
        font.weight: Style.fontWeightBold
        color: Color.mPrimary
        Layout.fillWidth: true
      }
      NIconButton {
        icon: "close"
        onClicked: root.close()
      }
    }

    NDivider {
      Layout.fillWidth: true
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS * scaling
      NTextInput {
        id: searchInput
        Layout.fillWidth: true
        label: "Search"
        placeholderText: "e.g., noctalia, niri, battery, cloud"
        text: root.query
        onTextChanged: root.query = text.trim().toLowerCase()
      }
    }

    // Icon grid
    NScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      horizontalPolicy: ScrollBar.AlwaysOff
      verticalPolicy: ScrollBar.AlwaysOn

      GridView {
        id: grid
        anchors.fill: parent
        anchors.margins: Style.marginM * scaling
        cellWidth: root.cellW
        cellHeight: root.cellH
        model: root.filteredIcons
        delegate: Rectangle {
          width: grid.cellWidth
          height: grid.cellHeight
          radius: Style.radiusS * scaling
          clip: true
          color: (root.selectedIcon === modelData) ? Qt.alpha(Color.mPrimary, 0.15) : "transparent"
          border.color: (root.selectedIcon === modelData) ? Color.mPrimary : Qt.rgba(0, 0, 0, 0)
          border.width: (root.selectedIcon === modelData) ? Style.borderS * scaling : 0

          MouseArea {
            anchors.fill: parent
            onClicked: root.selectedIcon = modelData
            onDoubleClicked: {
              root.selectedIcon = modelData
              root.iconSelected(root.selectedIcon)
              root.close()
            }
          }

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginS * scaling
            spacing: Style.marginS * scaling
            Item {
              Layout.fillHeight: true
              Layout.preferredHeight: 4 * scaling
            }
            NIcon {
              Layout.alignment: Qt.AlignHCenter
              icon: modelData
              font.pointSize: 42 * scaling
            }
            NText {
              Layout.alignment: Qt.AlignHCenter
              Layout.fillWidth: true
              Layout.topMargin: Style.marginXS * scaling
              elide: Text.ElideRight
              wrapMode: Text.NoWrap
              maximumLineCount: 1
              horizontalAlignment: Text.AlignHCenter
              color: Color.mOnSurfaceVariant
              font.pointSize: Style.fontSizeXS * scaling
              text: modelData
            }
            Item {
              Layout.fillHeight: true
            }
          }
        }
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginM * scaling
      Item {
        Layout.fillWidth: true
      }
      NButton {
        text: "Cancel"
        outlined: true
        onClicked: root.close()
      }
      NButton {
        text: "Apply"
        icon: "check"
        enabled: root.selectedIcon !== ""
        onClicked: {
          root.iconSelected(root.selectedIcon)
          root.close()
        }
      }
    }
  }
}
