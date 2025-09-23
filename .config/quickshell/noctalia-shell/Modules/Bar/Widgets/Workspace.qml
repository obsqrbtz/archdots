import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services

Item {
  id: root

  property ShellScreen screen
  property real scaling: 1.0

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property var widgetMetadata: BarWidgetRegistry.widgetMetadata[widgetId]
  property var widgetSettings: {
    if (section && sectionWidgetIndex >= 0) {
      var widgets = Settings.data.bar.widgets[section]
      if (widgets && sectionWidgetIndex < widgets.length) {
        return widgets[sectionWidgetIndex]
      }
    }
    return {}
  }

  readonly property string barPosition: Settings.data.bar.position
  readonly property bool isVertical: barPosition === "left" || barPosition === "right"
  readonly property bool compact: (Settings.data.bar.density === "compact")
  readonly property real baseDimensionRatio: {
    const b = compact ? 0.85 : 0.65
    if (widgetSettings.labelMode === "none") {
      return b * 0.75
    }
    return b
  }

  readonly property string labelMode: (widgetSettings.labelMode !== undefined) ? widgetSettings.labelMode : widgetMetadata.labelMode
  readonly property bool hideUnoccupied: (widgetSettings.hideUnoccupied !== undefined) ? widgetSettings.hideUnoccupied : widgetMetadata.hideUnoccupied

  property bool isDestroying: false
  property bool hovered: false

  property ListModel localWorkspaces: ListModel {}
  property real masterProgress: 0.0
  property bool effectsActive: false
  property color effectColor: Color.mPrimary

  property int horizontalPadding: Math.round(Style.marginS * scaling)
  property int spacingBetweenPills: Math.round(Style.marginXS * scaling)

  signal workspaceChanged(int workspaceId, color accentColor)

  implicitWidth: isVertical ? Math.round(Style.barHeight * scaling) : computeWidth()
  implicitHeight: isVertical ? computeHeight() : Math.round(Style.barHeight * scaling)

  function getWorkspaceWidth(ws) {
    const d = Style.capsuleHeight * root.baseDimensionRatio
    const factor = ws.isFocused ? 2.2 : 1
    return d * factor * scaling
  }

  function getWorkspaceHeight(ws) {
    const d = Style.capsuleHeight * root.baseDimensionRatio
    const factor = ws.isFocused ? 2.2 : 1
    return d * factor * scaling
  }

  function computeWidth() {
    let total = 0
    for (var i = 0; i < localWorkspaces.count; i++) {
      const ws = localWorkspaces.get(i)
      total += getWorkspaceWidth(ws)
    }
    total += Math.max(localWorkspaces.count - 1, 0) * spacingBetweenPills
    total += horizontalPadding * 2
    return Math.round(total)
  }

  function computeHeight() {
    let total = 0
    for (var i = 0; i < localWorkspaces.count; i++) {
      const ws = localWorkspaces.get(i)
      total += getWorkspaceHeight(ws)
    }
    total += Math.max(localWorkspaces.count - 1, 0) * spacingBetweenPills
    total += horizontalPadding * 2
    return Math.round(total)
  }

  Component.onCompleted: {
    refreshWorkspaces()
  }

  Component.onDestruction: {
    root.isDestroying = true
  }

  onScreenChanged: refreshWorkspaces()
  onHideUnoccupiedChanged: refreshWorkspaces()

  Connections {
    target: CompositorService
    function onWorkspacesChanged() {
      refreshWorkspaces()
    }
  }

  function refreshWorkspaces() {
    localWorkspaces.clear()
    if (screen !== null) {
      for (var i = 0; i < CompositorService.workspaces.count; i++) {
        const ws = CompositorService.workspaces.get(i)
        if (ws.output.toLowerCase() === screen.name.toLowerCase()) {
          if (hideUnoccupied && !ws.isOccupied && !ws.isFocused) {
            continue
          }
          localWorkspaces.append(ws)
        }
      }
    }
    workspaceRepeaterHorizontal.model = localWorkspaces
    workspaceRepeaterVertical.model = localWorkspaces
    updateWorkspaceFocus()
  }

  function triggerUnifiedWave() {
    effectColor = Color.mPrimary
    masterAnimation.restart()
  }

  function updateWorkspaceFocus() {
    for (var i = 0; i < localWorkspaces.count; i++) {
      const ws = localWorkspaces.get(i)
      if (ws.isFocused === true) {
        root.triggerUnifiedWave()
        root.workspaceChanged(ws.id, Color.mPrimary)
        break
      }
    }
  }

  SequentialAnimation {
    id: masterAnimation
    PropertyAction {
      target: root
      property: "effectsActive"
      value: true
    }
    NumberAnimation {
      target: root
      property: "masterProgress"
      from: 0.0
      to: 1.0
      duration: Style.animationSlow * 2
      easing.type: Easing.OutQuint
    }
    PropertyAction {
      target: root
      property: "effectsActive"
      value: false
    }
    PropertyAction {
      target: root
      property: "masterProgress"
      value: 0.0
    }
  }

  Rectangle {
    id: workspaceBackground
    width: isVertical ? Math.round(Style.capsuleHeight * scaling) : parent.width
    height: isVertical ? parent.height : Math.round(Style.capsuleHeight * scaling)
    radius: Math.round(Style.radiusM * scaling)
    color: Settings.data.bar.showCapsule ? Color.mSurfaceVariant : Color.transparent

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
  }

  // Horizontal layout for top/bottom bars
  Row {
    id: pillRow
    spacing: spacingBetweenPills
    anchors.verticalCenter: workspaceBackground.verticalCenter
    x: horizontalPadding
    visible: !isVertical

    Repeater {
      id: workspaceRepeaterHorizontal
      model: localWorkspaces
      Item {
        id: workspacePillContainer
        width: root.getWorkspaceWidth(model)
        height: Style.capsuleHeight * root.baseDimensionRatio * scaling

        Rectangle {
          id: pill
          anchors.fill: parent

          Loader {
            active: (labelMode !== "none")
            sourceComponent: Component {
              Text {
                x: (pill.width - width) / 2
                y: (pill.height - height) / 2 + (height - contentHeight) / 2
                text: {
                  if (labelMode === "name" && model.name && model.name.length > 0) {
                    return model.name.substring(0, 2)
                  } else {
                    return model.idx.toString()
                  }
                }
                font.pointSize: model.isFocused ? workspacePillContainer.height * 0.45 : workspacePillContainer.height * 0.42
                font.capitalization: Font.AllUppercase
                font.family: Settings.data.ui.fontFixed
                font.weight: Style.fontWeightBold
                wrapMode: Text.Wrap
                color: {
                  if (model.isFocused)
                    return Color.mOnPrimary
                  if (model.isUrgent)
                    return Color.mOnError
                  if (model.isActive || model.isOccupied)
                    return Color.mOnSecondary

                  return Color.mOnSurface
                }
              }
            }
          }

          radius: width * 0.5
          color: {
            if (model.isFocused)
              return Color.mPrimary
            if (model.isUrgent)
              return Color.mError
            if (model.isActive || model.isOccupied)
              return Color.mSecondary

            return Color.mOutline
          }
          scale: model.isFocused ? 1.0 : 0.9
          z: 0

          MouseArea {
            id: pillMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              CompositorService.switchToWorkspace(model.idx)
            }
            hoverEnabled: true
          }
          // Material 3-inspired smooth animation for width, height, scale, color, opacity, and radius
          Behavior on width {
            NumberAnimation {
              duration: Style.animationNormal
              easing.type: Easing.OutBack
            }
          }
          Behavior on height {
            NumberAnimation {
              duration: Style.animationNormal
              easing.type: Easing.OutBack
            }
          }
          Behavior on scale {
            NumberAnimation {
              duration: Style.animationNormal
              easing.type: Easing.OutBack
            }
          }
          Behavior on color {
            ColorAnimation {
              duration: Style.animationFast
              easing.type: Easing.InOutCubic
            }
          }
          Behavior on opacity {
            NumberAnimation {
              duration: Style.animationFast
              easing.type: Easing.InOutCubic
            }
          }
          Behavior on radius {
            NumberAnimation {
              duration: Style.animationNormal
              easing.type: Easing.OutBack
            }
          }
        }

        Behavior on width {
          NumberAnimation {
            duration: Style.animationNormal
            easing.type: Easing.OutBack
          }
        }
        Behavior on height {
          NumberAnimation {
            duration: Style.animationNormal
            easing.type: Easing.OutBack
          }
        }
        // Burst effect overlay for focused pill (smaller outline)
        Rectangle {
          id: pillBurst
          anchors.centerIn: workspacePillContainer
          width: workspacePillContainer.width + 18 * root.masterProgress * scale
          height: workspacePillContainer.height + 18 * root.masterProgress * scale
          radius: width / 2
          color: Color.transparent
          border.color: root.effectColor
          border.width: Math.max(1, Math.round((2 + 6 * (1.0 - root.masterProgress)) * scaling))
          opacity: root.effectsActive && model.isFocused ? (1.0 - root.masterProgress) * 0.7 : 0
          visible: root.effectsActive && model.isFocused
          z: 1
        }
      }
    }
  }

  // Vertical layout for left/right bars
  Column {
    id: pillColumn
    spacing: spacingBetweenPills
    anchors.horizontalCenter: workspaceBackground.horizontalCenter
    y: horizontalPadding
    visible: isVertical

    Repeater {
      id: workspaceRepeaterVertical
      model: localWorkspaces
      Item {
        id: workspacePillContainerVertical
        width: Style.capsuleHeight * root.baseDimensionRatio * scaling
        height: root.getWorkspaceHeight(model)

        Rectangle {
          id: pillVertical
          anchors.fill: parent

          Loader {
            active: (labelMode !== "none")
            sourceComponent: Component {
              Text {
                x: (pillVertical.width - width) / 2
                y: (pillVertical.height - height) / 2 + (height - contentHeight) / 2
                text: {
                  if (labelMode === "name" && model.name && model.name.length > 0) {
                    return model.name.substring(0, 2)
                  } else {
                    return model.idx.toString()
                  }
                }
                font.pointSize: model.isFocused ? workspacePillContainerVertical.width * 0.45 : workspacePillContainerVertical.width * 0.42
                font.capitalization: Font.AllUppercase
                font.family: Settings.data.ui.fontFixed
                font.weight: Style.fontWeightBold
                wrapMode: Text.Wrap
                color: {
                  if (model.isFocused)
                    return Color.mOnPrimary
                  if (model.isUrgent)
                    return Color.mOnError
                  if (model.isActive || model.isOccupied)
                    return Color.mOnSecondary

                  return Color.mOnSurface
                }
              }
            }
          }

          radius: width * 0.5
          color: {
            if (model.isFocused)
              return Color.mPrimary
            if (model.isUrgent)
              return Color.mError
            if (model.isActive || model.isOccupied)
              return Color.mSecondary

            return Color.mOutline
          }
          scale: model.isFocused ? 1.0 : 0.9
          z: 0

          MouseArea {
            id: pillMouseAreaVertical
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              CompositorService.switchToWorkspace(model.idx)
            }
            hoverEnabled: true
          }
          // Material 3-inspired smooth animation for width, height, scale, color, opacity, and radius
          Behavior on width {
            NumberAnimation {
              duration: Style.animationNormal
              easing.type: Easing.OutBack
            }
          }
          Behavior on height {
            NumberAnimation {
              duration: Style.animationNormal
              easing.type: Easing.OutBack
            }
          }
          Behavior on scale {
            NumberAnimation {
              duration: Style.animationNormal
              easing.type: Easing.OutBack
            }
          }
          Behavior on color {
            ColorAnimation {
              duration: Style.animationFast
              easing.type: Easing.InOutCubic
            }
          }
          Behavior on opacity {
            NumberAnimation {
              duration: Style.animationFast
              easing.type: Easing.InOutCubic
            }
          }
          Behavior on radius {
            NumberAnimation {
              duration: Style.animationNormal
              easing.type: Easing.OutBack
            }
          }
        }

        Behavior on width {
          NumberAnimation {
            duration: Style.animationNormal
            easing.type: Easing.OutBack
          }
        }
        Behavior on height {
          NumberAnimation {
            duration: Style.animationNormal
            easing.type: Easing.OutBack
          }
        }
        // Burst effect overlay for focused pill (smaller outline)
        Rectangle {
          id: pillBurstVertical
          anchors.centerIn: workspacePillContainerVertical
          width: workspacePillContainerVertical.width + 18 * root.masterProgress * scale
          height: workspacePillContainerVertical.height + 18 * root.masterProgress * scale
          radius: width / 2
          color: Color.transparent
          border.color: root.effectColor
          border.width: Math.max(1, Math.round((2 + 6 * (1.0 - root.masterProgress)) * scaling))
          opacity: root.effectsActive && model.isFocused ? (1.0 - root.masterProgress) * 0.7 : 0
          visible: root.effectsActive && model.isFocused
          z: 1
        }
      }
    }
  }
}
