import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services
import qs.Widgets
import qs.Modules.SettingsPanel.Bar

ColumnLayout {
  id: root
  spacing: Style.marginL * scaling

  // Helper functions to update arrays immutably
  function addMonitor(list, name) {
    const arr = (list || []).slice()
    if (!arr.includes(name))
      arr.push(name)
    return arr
  }
  function removeMonitor(list, name) {
    return (list || []).filter(function (n) {
      return n !== name
    })
  }

  // Handler for drag start - disables panel background clicks
  function handleDragStart() {
    var panel = PanelService.getPanel("settingsPanel")
    if (panel && panel.disableBackgroundClick) {
      panel.disableBackgroundClick()
    }
  }

  // Handler for drag end - re-enables panel background clicks
  function handleDragEnd() {
    var panel = PanelService.getPanel("settingsPanel")
    if (panel && panel.enableBackgroundClick) {
      panel.enableBackgroundClick()
    }
  }

  NHeader {
    label: "Appearance"
    description: "Customize the bar's appearance and position."
  }

  NComboBox {
    Layout.fillWidth: true
    label: "Bar position"
    description: "Choose where to place the bar on the screen."
    model: ListModel {
      ListElement {
        key: "top"
        name: "Top"
      }
      ListElement {
        key: "bottom"
        name: "Bottom"
      }
      ListElement {
        key: "left"
        name: "Left"
      }
      ListElement {
        key: "right"
        name: "Right"
      }
    }
    currentKey: Settings.data.bar.position
    onSelected: key => Settings.data.bar.position = key
  }

  NComboBox {
    Layout.fillWidth: true
    label: "Bar density"
    description: "Adjust the bar's padding for a compact or spacious look."
    model: ListModel {
      ListElement {
        key: "compact"
        name: "Compact"
      }
      ListElement {
        key: "default"
        name: "Default"
      }
      ListElement {
        key: "comfortable"
        name: "Comfortable"
      }
    }
    currentKey: Settings.data.bar.density
    onSelected: key => Settings.data.bar.density = key
  }

  ColumnLayout {
    spacing: Style.marginXXS * scaling
    Layout.fillWidth: true

    NLabel {
      label: "Background opacity"
      description: "Adjust the background opacity of the bar."
    }

    NValueSlider {
      Layout.fillWidth: true
      from: 0
      to: 1
      stepSize: 0.01
      value: Settings.data.bar.backgroundOpacity
      onMoved: value => Settings.data.bar.backgroundOpacity = value
      text: Math.floor(Settings.data.bar.backgroundOpacity * 100) + "%"
    }
  }

  NToggle {
    Layout.fillWidth: true
    label: "Show capsule"
    description: "Show widget backgrounds."
    checked: Settings.data.bar.showCapsule
    onToggled: checked => Settings.data.bar.showCapsule = checked
  }

  NToggle {
    Layout.fillWidth: true
    label: "Floating bar"
    description: "Displays the bar as a floating 'pill'. Note: This will move the screen corners to the edges."
    checked: Settings.data.bar.floating
    onToggled: checked => Settings.data.bar.floating = checked
  }

  // Floating bar options - only show when floating is enabled
  ColumnLayout {
    visible: Settings.data.bar.floating
    spacing: Style.marginS * scaling
    Layout.fillWidth: true

    NLabel {
      label: "Margins"
      description: "Adjust the margins around the floating bar."
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginL * scaling

      ColumnLayout {
        spacing: Style.marginXXS * scaling

        NText {
          text: "Vertical"
          font.pointSize: Style.fontSizeXS * scaling
          color: Color.mOnSurfaceVariant
        }

        NValueSlider {
          Layout.fillWidth: true
          from: 0
          to: 1
          stepSize: 0.01
          value: Settings.data.bar.marginVertical
          onMoved: value => Settings.data.bar.marginVertical = value
          text: Math.round(Settings.data.bar.marginVertical * 100) + "%"
        }
      }

      ColumnLayout {
        spacing: Style.marginXXS * scaling

        NText {
          text: "Horizontal"
          font.pointSize: Style.fontSizeXS * scaling
          color: Color.mOnSurfaceVariant
        }

        NValueSlider {
          Layout.fillWidth: true
          from: 0
          to: 1
          stepSize: 0.01
          value: Settings.data.bar.marginHorizontal
          onMoved: value => Settings.data.bar.marginHorizontal = value
          text: Math.round(Settings.data.bar.marginHorizontal * 100) + "%"
        }
      }
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // Widgets Management Section
  ColumnLayout {
    spacing: Style.marginXXS * scaling
    Layout.fillWidth: true

    NHeader {
      label: "Widgets positioning"
      description: "Drag and drop widgets to reorder them within each section, or use the add/remove buttons to manage widgets."
    }

    // Bar Sections
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.topMargin: Style.marginM * scaling
      spacing: Style.marginM * scaling

      // Left Section
      BarSectionEditor {
        sectionName: "Left"
        sectionId: "left"
        widgetModel: Settings.data.bar.widgets.left
        availableWidgets: availableWidgets
        onAddWidget: (widgetId, section) => _addWidgetToSection(widgetId, section)
        onRemoveWidget: (section, index) => _removeWidgetFromSection(section, index)
        onReorderWidget: (section, fromIndex, toIndex) => _reorderWidgetInSection(section, fromIndex, toIndex)
        onUpdateWidgetSettings: (section, index, settings) => _updateWidgetSettingsInSection(section, index, settings)
        onDragPotentialStarted: root.handleDragStart()
        onDragPotentialEnded: root.handleDragEnd()
      }

      // Center Section
      BarSectionEditor {
        sectionName: "Center"
        sectionId: "center"
        widgetModel: Settings.data.bar.widgets.center
        availableWidgets: availableWidgets
        onAddWidget: (widgetId, section) => _addWidgetToSection(widgetId, section)
        onRemoveWidget: (section, index) => _removeWidgetFromSection(section, index)
        onReorderWidget: (section, fromIndex, toIndex) => _reorderWidgetInSection(section, fromIndex, toIndex)
        onUpdateWidgetSettings: (section, index, settings) => _updateWidgetSettingsInSection(section, index, settings)
        onDragPotentialStarted: root.handleDragStart()
        onDragPotentialEnded: root.handleDragEnd()
      }

      // Right Section
      BarSectionEditor {
        sectionName: "Right"
        sectionId: "right"
        widgetModel: Settings.data.bar.widgets.right
        availableWidgets: availableWidgets
        onAddWidget: (widgetId, section) => _addWidgetToSection(widgetId, section)
        onRemoveWidget: (section, index) => _removeWidgetFromSection(section, index)
        onReorderWidget: (section, fromIndex, toIndex) => _reorderWidgetInSection(section, fromIndex, toIndex)
        onUpdateWidgetSettings: (section, index, settings) => _updateWidgetSettingsInSection(section, index, settings)
        onDragPotentialStarted: root.handleDragStart()
        onDragPotentialEnded: root.handleDragEnd()
      }
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // Monitor Configuration
  ColumnLayout {
    spacing: Style.marginM * scaling
    Layout.fillWidth: true

    NHeader {
      label: "Monitor display"
      description: "Show bar on specific monitors. Defaults to all if none are chosen."
    }

    Repeater {
      model: Quickshell.screens || []
      delegate: NCheckbox {
        Layout.fillWidth: true
        label: modelData.name || "Unknown"
        description: `${modelData.model} (${modelData.width}x${modelData.height})`
        checked: (Settings.data.bar.monitors || []).indexOf(modelData.name) !== -1
        onToggled: checked => {
                     if (checked) {
                       Settings.data.bar.monitors = addMonitor(Settings.data.bar.monitors, modelData.name)
                     } else {
                       Settings.data.bar.monitors = removeMonitor(Settings.data.bar.monitors, modelData.name)
                     }
                   }
      }
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // ---------------------------------
  // Signal functions
  // ---------------------------------
  function _addWidgetToSection(widgetId, section) {
    var newWidget = {
      "id": widgetId
    }
    if (BarWidgetRegistry.widgetHasUserSettings(widgetId)) {
      var metadata = BarWidgetRegistry.widgetMetadata[widgetId]
      if (metadata) {
        Object.keys(metadata).forEach(function (key) {
          if (key !== "allowUserSettings") {
            newWidget[key] = metadata[key]
          }
        })
      }
    }
    Settings.data.bar.widgets[section].push(newWidget)
  }

  function _removeWidgetFromSection(section, index) {
    if (index >= 0 && index < Settings.data.bar.widgets[section].length) {
      var newArray = Settings.data.bar.widgets[section].slice()
      newArray.splice(index, 1)
      Settings.data.bar.widgets[section] = newArray
    }
  }

  function _reorderWidgetInSection(section, fromIndex, toIndex) {
    if (fromIndex >= 0 && fromIndex < Settings.data.bar.widgets[section].length && toIndex >= 0 && toIndex < Settings.data.bar.widgets[section].length) {

      // Create a new array to avoid modifying the original
      var newArray = Settings.data.bar.widgets[section].slice()
      var item = newArray[fromIndex]
      newArray.splice(fromIndex, 1)
      newArray.splice(toIndex, 0, item)

      Settings.data.bar.widgets[section] = newArray
      //Logger.log("BarTab", "Widget reordered. New array:", JSON.stringify(newArray))
    }
  }

  function _updateWidgetSettingsInSection(section, index, settings) {
    // Update the widget settings in the Settings data
    Settings.data.bar.widgets[section][index] = settings
    //Logger.log("BarTab", `Updated widget settings for ${settings.id} in ${section} section`)
  }

  // Base list model for all combo boxes
  ListModel {
    id: availableWidgets
  }

  Component.onCompleted: {
    // Fill out availableWidgets ListModel
    availableWidgets.clear()
    BarWidgetRegistry.getAvailableWidgets().forEach(entry => {
                                                      availableWidgets.append({
                                                                                "key": entry,
                                                                                "name": entry
                                                                              })
                                                    })
  }
}
