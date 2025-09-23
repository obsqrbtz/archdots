import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services

NBox {
  id: root

  property string sectionName: ""
  property string sectionId: ""
  property var widgetModel: []
  property var availableWidgets: []

  readonly property real miniButtonSize: Style.baseWidgetSize * 0.65

  signal addWidget(string widgetId, string section)
  signal removeWidget(string section, int index)
  signal reorderWidget(string section, int fromIndex, int toIndex)
  signal updateWidgetSettings(string section, int index, var settings)
  signal dragPotentialStarted
  signal dragPotentialEnded

  color: Color.mSurface
  Layout.fillWidth: true
  Layout.minimumHeight: {
    var widgetCount = widgetModel.length
    if (widgetCount === 0)
      return 140 * scaling

    var availableWidth = parent.width
    var avgWidgetWidth = 150 * scaling
    var widgetsPerRow = Math.max(1, Math.floor(availableWidth / avgWidgetWidth))
    var rows = Math.ceil(widgetCount / widgetsPerRow)

    return (50 + 20 + (rows * 48) + ((rows - 1) * Style.marginS) + 20) * scaling
  }

  // Generate widget color from name checksum
  function getWidgetColor(widget) {
    const totalSum = JSON.stringify(widget).split('').reduce((acc, character) => {
                                                               return acc + character.charCodeAt(0)
                                                             }, 0)
    switch (totalSum % 6) {
    case 0:
      return [Color.mPrimary, Color.mOnPrimary]
    case 1:
      return [Color.mSecondary, Color.mOnSecondary]
    case 2:
      return [Color.mTertiary, Color.mOnTertiary]
    case 3:
      return [Color.mError, Color.mOnError]
    case 4:
      return [Color.mOnSurface, Color.mSurface]
    case 5:
      return [Color.mOnSurfaceVariant, Color.mSurfaceVariant]
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.marginL * scaling
    spacing: Style.marginM * scaling

    RowLayout {
      Layout.fillWidth: true

      NText {
        text: sectionName + " Section"
        font.pointSize: Style.fontSizeL * scaling
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
        Layout.alignment: Qt.AlignVCenter
      }

      Item {
        Layout.fillWidth: true
      }
      NComboBox {
        id: comboBox
        model: availableWidgets
        label: ""
        description: ""
        placeholder: "Select a widget to add..."
        onSelected: key => comboBox.currentKey = key
        popupHeight: 340 * scaling

        Layout.alignment: Qt.AlignVCenter
      }

      NIconButton {
        icon: "add"

        colorBg: Color.mPrimary
        colorFg: Color.mOnPrimary
        colorBgHover: Color.mSecondary
        colorFgHover: Color.mOnSecondary
        enabled: comboBox.currentKey !== ""
        tooltipText: "Add widget"
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: Style.marginS * scaling
        onClicked: {
          if (comboBox.currentKey !== "") {
            addWidget(comboBox.currentKey, sectionId)
            comboBox.currentKey = ""
          }
        }
      }
    }

    // Drag and Drop Widget Area
    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.minimumHeight: 65 * scaling
      clip: false // Don't clip children so ghost can move freely

      Flow {
        id: widgetFlow
        anchors.fill: parent
        spacing: Style.marginS * scaling
        flow: Flow.LeftToRight

        Repeater {
          model: widgetModel
          delegate: Rectangle {
            id: widgetItem
            required property int index
            required property var modelData

            width: widgetContent.implicitWidth + Style.marginL * scaling
            height: Style.baseWidgetSize * 1.15 * scaling
            radius: Style.radiusL * scaling
            color: root.getWidgetColor(modelData)[0]
            border.color: Color.mOutline
            border.width: Math.max(1, Style.borderS * scaling)

            // Store the widget index for drag operations
            property int widgetIndex: index
            readonly property int buttonsWidth: Math.round(20 * scaling)
            readonly property int buttonsCount: 1 + BarWidgetRegistry.widgetHasUserSettings(modelData.id)

            // Visual feedback during drag
            opacity: flowDragArea.draggedIndex === index ? 0.5 : 1.0
            scale: flowDragArea.draggedIndex === index ? 0.95 : 1.0
            z: flowDragArea.draggedIndex === index ? 1000 : 0

            Behavior on opacity {
              NumberAnimation {
                duration: Style.animationFast
              }
            }
            Behavior on scale {
              NumberAnimation {
                duration: Style.animationFast
              }
            }

            RowLayout {
              id: widgetContent
              anchors.centerIn: parent
              spacing: Style.marginXXS * scaling

              NText {
                text: modelData.id
                font.pointSize: Style.fontSizeS * scaling
                color: root.getWidgetColor(modelData)[1]
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                Layout.preferredWidth: 80 * scaling
              }

              RowLayout {
                spacing: 0
                Layout.preferredWidth: buttonsCount * buttonsWidth

                Loader {
                  active: BarWidgetRegistry.widgetHasUserSettings(modelData.id)
                  sourceComponent: NIconButton {
                    icon: "settings"
                    baseSize: miniButtonSize
                    colorBorder: Qt.alpha(Color.mOutline, Style.opacityLight)
                    colorBg: Color.mOnSurface
                    colorFg: Color.mOnPrimary
                    colorBgHover: Qt.alpha(Color.mOnPrimary, Style.opacityLight)
                    colorFgHover: Color.mOnPrimary
                    onClicked: {
                      var component = Qt.createComponent(Qt.resolvedUrl("BarWidgetSettingsDialog.qml"))
                      function instantiateAndOpen() {
                        var dialog = component.createObject(root, {
                                                              "widgetIndex": index,
                                                              "widgetData": modelData,
                                                              "widgetId": modelData.id,
                                                              "parent": Overlay.overlay
                                                            })
                        if (dialog) {
                          dialog.open()
                        } else {
                          Logger.error("BarSectionEditor", "Failed to create settings dialog instance")
                        }
                      }
                      if (component.status === Component.Ready) {
                        instantiateAndOpen()
                      } else if (component.status === Component.Error) {
                        Logger.error("BarSectionEditor", component.errorString())
                      } else {
                        component.statusChanged.connect(function () {
                          if (component.status === Component.Ready) {
                            instantiateAndOpen()
                          } else if (component.status === Component.Error) {
                            Logger.error("BarSectionEditor", component.errorString())
                          }
                        })
                      }
                    }
                  }
                }

                NIconButton {
                  icon: "close"
                  baseSize: miniButtonSize
                  colorBorder: Qt.alpha(Color.mOutline, Style.opacityLight)
                  colorBg: Color.mOnSurface
                  colorFg: Color.mOnPrimary
                  colorBgHover: Qt.alpha(Color.mOnPrimary, Style.opacityLight)
                  colorFgHover: Color.mOnPrimary
                  onClicked: {
                    removeWidget(sectionId, index)
                  }
                }
              }
            }
          }
        }
      }

      // Ghost/Clone widget for dragging
      Rectangle {
        id: dragGhost
        width: 0
        height: Style.baseWidgetSize * 1.15 * scaling
        radius: Style.radiusL * scaling
        color: Color.transparent
        border.color: Color.mOutline
        border.width: Math.max(1, Style.borderS * scaling)
        opacity: 0.7
        visible: flowDragArea.dragStarted
        z: 2000
        clip: false // Ensure ghost isn't clipped

        Text {
          id: ghostText
          anchors.centerIn: parent
          font.pointSize: Style.fontSizeS * scaling
          color: Color.mOnPrimary
        }
      }

      // Drop indicator - visual feedback for where the widget will be inserted
      Rectangle {
        id: dropIndicator
        width: 3 * scaling
        height: Style.baseWidgetSize * 1.15 * scaling
        radius: width / 2
        color: Color.mPrimary
        opacity: 0
        visible: opacity > 0
        z: 1999

        SequentialAnimation on opacity {
          id: pulseAnimation
          running: false
          loops: Animation.Infinite
          NumberAnimation {
            to: 1
            duration: 400
            easing.type: Easing.InOutQuad
          }
          NumberAnimation {
            to: 0.6
            duration: 400
            easing.type: Easing.InOutQuad
          }
        }

        Behavior on x {
          NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
          }
        }
        Behavior on y {
          NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
          }
        }
      }

      // MouseArea for drag and drop
      MouseArea {
        id: flowDragArea
        anchors.fill: parent
        z: -1

        acceptedButtons: Qt.LeftButton
        preventStealing: false
        propagateComposedEvents: false
        hoverEnabled: true // Always track mouse for drag operations

        property point startPos: Qt.point(0, 0)
        property bool dragStarted: false
        property bool potentialDrag: false // Track if we're in a potential drag interaction
        property int draggedIndex: -1
        property real dragThreshold: 15 * scaling
        property Item draggedWidget: null
        property int dropTargetIndex: -1
        property var draggedModelData: null

        // Drop position calculation
        function updateDropIndicator(mouseX, mouseY) {
          if (!dragStarted || draggedIndex === -1) {
            dropIndicator.opacity = 0
            pulseAnimation.running = false
            return
          }

          let bestIndex = -1
          let bestPosition = null
          let minDistance = Infinity

          // Check position relative to each widget
          for (var i = 0; i < widgetModel.length; i++) {
            if (i === draggedIndex)
              continue

            const widget = widgetFlow.children[i]
            if (!widget || widget.widgetIndex === undefined)
              continue

            // Check distance to left edge (insert before)
            const leftDist = Math.sqrt(Math.pow(mouseX - widget.x, 2) + Math.pow(mouseY - (widget.y + widget.height / 2), 2))

            // Check distance to right edge (insert after)
            const rightDist = Math.sqrt(Math.pow(mouseX - (widget.x + widget.width), 2) + Math.pow(mouseY - (widget.y + widget.height / 2), 2))

            if (leftDist < minDistance) {
              minDistance = leftDist
              bestIndex = i
              bestPosition = Qt.point(widget.x - dropIndicator.width / 2 - Style.marginXS * scaling, widget.y)
            }

            if (rightDist < minDistance) {
              minDistance = rightDist
              bestIndex = i + 1
              bestPosition = Qt.point(widget.x + widget.width + Style.marginXS * scaling - dropIndicator.width / 2, widget.y)
            }
          }

          // Check if we should insert at position 0 (very beginning)
          if (widgetModel.length > 0 && draggedIndex !== 0) {
            const firstWidget = widgetFlow.children[0]
            if (firstWidget) {
              const dist = Math.sqrt(Math.pow(mouseX, 2) + Math.pow(mouseY - firstWidget.y, 2))
              if (dist < minDistance && mouseX < firstWidget.x + firstWidget.width / 2) {
                minDistance = dist
                bestIndex = 0
                bestPosition = Qt.point(Math.max(0, firstWidget.x - dropIndicator.width - Style.marginS * scaling), firstWidget.y)
              }
            }
          }

          // Only show indicator if we're close enough and it's a different position
          if (minDistance < 80 * scaling && bestIndex !== -1) {
            // Adjust index if we're moving forward
            let adjustedIndex = bestIndex
            if (bestIndex > draggedIndex) {
              adjustedIndex = bestIndex - 1
            }

            // Don't show if it's the same position
            if (adjustedIndex === draggedIndex) {
              dropIndicator.opacity = 0
              pulseAnimation.running = false
              dropTargetIndex = -1
              return
            }

            dropTargetIndex = adjustedIndex
            if (bestPosition) {
              dropIndicator.x = bestPosition.x
              dropIndicator.y = bestPosition.y
              dropIndicator.opacity = 1
              if (!pulseAnimation.running) {
                pulseAnimation.running = true
              }
            }
          } else {
            dropIndicator.opacity = 0
            pulseAnimation.running = false
            dropTargetIndex = -1
          }
        }

        onPressed: mouse => {
                     startPos = Qt.point(mouse.x, mouse.y)
                     dragStarted = false
                     potentialDrag = false
                     draggedIndex = -1
                     draggedWidget = null
                     dropTargetIndex = -1
                     draggedModelData = null

                     // Find which widget was clicked
                     for (var i = 0; i < widgetModel.length; i++) {
                       const widget = widgetFlow.children[i]
                       if (widget && widget.widgetIndex !== undefined) {
                         if (mouse.x >= widget.x && mouse.x <= widget.x + widget.width && mouse.y >= widget.y && mouse.y <= widget.y + widget.height) {

                           const localX = mouse.x - widget.x
                           const buttonsStartX = widget.width - (widget.buttonsCount * widget.buttonsWidth)

                           if (localX < buttonsStartX) {
                             // This is a draggable area - prevent panel close immediately
                             draggedIndex = widget.widgetIndex
                             draggedWidget = widget
                             draggedModelData = widget.modelData
                             potentialDrag = true
                             preventStealing = true

                             // Signal that interaction started (prevents panel close)
                             root.dragPotentialStarted()
                             break
                           } else {
                             // This is a button area - let the click through
                             mouse.accepted = false
                             return
                           }
                         }
                       }
                     }
                   }

        onPositionChanged: mouse => {
                             if (draggedIndex !== -1 && potentialDrag) {
                               const deltaX = mouse.x - startPos.x
                               const deltaY = mouse.y - startPos.y
                               const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY)

                               if (!dragStarted && distance > dragThreshold) {
                                 dragStarted = true

                                 // Setup ghost widget
                                 if (draggedWidget) {
                                   dragGhost.width = draggedWidget.width
                                   dragGhost.color = root.getWidgetColor(draggedModelData)[0]
                                   ghostText.text = draggedModelData.id
                                 }
                               }

                               if (dragStarted) {
                                 // Move ghost widget
                                 dragGhost.x = mouse.x - dragGhost.width / 2
                                 dragGhost.y = mouse.y - dragGhost.height / 2

                                 // Update drop indicator
                                 updateDropIndicator(mouse.x, mouse.y)
                               }
                             }
                           }

        onReleased: mouse => {
                      if (dragStarted && dropTargetIndex !== -1 && dropTargetIndex !== draggedIndex) {
                        // Perform the reorder
                        reorderWidget(sectionId, draggedIndex, dropTargetIndex)
                      }

                      // Always signal end of interaction if we started one
                      if (potentialDrag) {
                        root.dragPotentialEnded()
                      }

                      // Reset everything
                      dragStarted = false
                      potentialDrag = false
                      draggedIndex = -1
                      draggedWidget = null
                      dropTargetIndex = -1
                      draggedModelData = null
                      preventStealing = false
                      dropIndicator.opacity = 0
                      pulseAnimation.running = false
                      dragGhost.width = 0
                    }

        onExited: {
          if (dragStarted) {
            // Hide drop indicator when mouse leaves, but keep ghost visible
            dropIndicator.opacity = 0
            pulseAnimation.running = false
          }
        }

        onCanceled: {
          // Handle cancel (e.g., ESC key pressed during drag)
          if (potentialDrag) {
            root.dragPotentialEnded()
          }

          // Reset everything
          dragStarted = false
          potentialDrag = false
          draggedIndex = -1
          draggedWidget = null
          dropTargetIndex = -1
          draggedModelData = null
          preventStealing = false
          dropIndicator.opacity = 0
          pulseAnimation.running = false
          dragGhost.width = 0
        }
      }
    }
  }
}
