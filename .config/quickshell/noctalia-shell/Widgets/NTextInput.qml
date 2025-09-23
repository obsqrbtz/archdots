import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services

ColumnLayout {
  id: root

  property string label: ""
  property string description: ""
  property bool readOnly: false
  property bool enabled: true
  property color labelColor: Color.mOnSurface
  property color descriptionColor: Color.mOnSurfaceVariant
  property string fontFamily: Settings.data.ui.fontDefault
  property real fontSize: Style.fontSizeS * scaling
  property int fontWeight: Style.fontWeightRegular

  property alias text: input.text
  property alias placeholderText: input.placeholderText
  property alias inputMethodHints: input.inputMethodHints
  property alias inputItem: input

  signal editingFinished

  spacing: Style.marginS * scaling

  NLabel {
    label: root.label
    description: root.description
    labelColor: root.labelColor
    descriptionColor: root.descriptionColor
    visible: root.label !== "" || root.description !== ""
    Layout.fillWidth: true
  }

  // An active control that blocks input, to avoid events leakage and dragging stuff in the background.
  Control {
    id: frameControl

    Layout.fillWidth: true
    Layout.minimumWidth: 80 * scaling
    implicitHeight: Style.baseWidgetSize * 1.1 * scaling

    // This is important - makes the control accept focus
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true

    background: Rectangle {
      id: frame

      radius: Style.radiusM * scaling
      color: Color.mSurface
      border.color: input.activeFocus ? Color.mSecondary : Color.mOutline
      border.width: Math.max(1, Style.borderS * scaling)

      Behavior on border.color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }
    }

    contentItem: Item {
      // Invisible background that captures ALL mouse events
      MouseArea {
        id: backgroundCapture
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        preventStealing: true
        propagateComposedEvents: false

        onPressed: mouse => {
                     mouse.accepted = true
                     // Focus the input and position cursor
                     input.forceActiveFocus()
                     var inputPos = mapToItem(inputContainer, mouse.x, mouse.y)
                     if (inputPos.x >= 0 && inputPos.x <= inputContainer.width) {
                       var textPos = inputPos.x - Style.marginM * scaling
                       if (textPos >= 0 && textPos <= input.width) {
                         input.cursorPosition = input.positionAt(textPos, input.height / 2)
                       }
                     }
                   }

        onReleased: mouse => {
                      mouse.accepted = true
                    }
        onDoubleClicked: mouse => {
                           mouse.accepted = true
                           input.selectAll()
                         }
        onPositionChanged: mouse => {
                             mouse.accepted = true
                           }
        onWheel: wheel => {
                   wheel.accepted = true
                 }
      }

      // Container for the actual text field
      Item {
        id: inputContainer
        anchors.fill: parent
        anchors.leftMargin: Style.marginM * scaling
        anchors.rightMargin: Style.marginM * scaling
        z: 1

        TextField {
          id: input

          anchors.fill: parent
          verticalAlignment: TextInput.AlignVCenter

          echoMode: TextInput.Normal
          readOnly: root.readOnly
          enabled: root.enabled
          color: Color.mOnSurface
          placeholderTextColor: Qt.alpha(Color.mOnSurfaceVariant, 0.6)

          selectByMouse: true

          topPadding: 0
          bottomPadding: 0
          leftPadding: 0
          rightPadding: 0

          background: null

          font.family: root.fontFamily
          font.pointSize: root.fontSize
          font.weight: root.fontWeight

          onEditingFinished: root.editingFinished()

          // Override mouse handling to prevent propagation
          MouseArea {
            id: textFieldMouse
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            preventStealing: true
            propagateComposedEvents: false
            cursorShape: Qt.IBeamCursor

            property int selectionStart: 0

            onPressed: mouse => {
                         mouse.accepted = true
                         input.forceActiveFocus()
                         var pos = input.positionAt(mouse.x, mouse.y)
                         input.cursorPosition = pos
                         selectionStart = pos
                       }

            onPositionChanged: mouse => {
                                 if (mouse.buttons & Qt.LeftButton) {
                                   mouse.accepted = true
                                   var pos = input.positionAt(mouse.x, mouse.y)
                                   input.select(selectionStart, pos)
                                 }
                               }

            onDoubleClicked: mouse => {
                               mouse.accepted = true
                               input.selectAll()
                             }

            onReleased: mouse => {
                          mouse.accepted = true
                        }
            onWheel: wheel => {
                       wheel.accepted = true
                     }
          }
        }
      }
    }
  }
}
