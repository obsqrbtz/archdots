import QtQuick
import Quickshell
import qs.Services
import qs.Commons

Item {
  id: root

  property string widgetId: ""
  property var widgetProps: ({})
  property string screenName: widgetProps.screen ? widgetProps.screen.name : ""
  property string section: widgetProps.section || ""
  property int sectionIndex: widgetProps.sectionWidgetIndex || 0

  Connections {
    target: ScalingService
    function onScaleChanged(aScreenName, scale) {
      if (loader.item && loader.item.screen && aScreenName === screenName) {
        loader.item['scaling'] = scale
      }
    }
  }

  // Don't reserve space unless the loaded widget is really visible
  implicitWidth: loader.item ? loader.item.visible ? loader.item.implicitWidth : 0 : 0
  implicitHeight: loader.item ? loader.item.visible ? loader.item.implicitHeight : 0 : 0

  Loader {
    id: loader

    anchors.fill: parent
    active: Settings.isLoaded && widgetId !== ""
    sourceComponent: {
      if (!active) {
        return null
      }
      return BarWidgetRegistry.getWidget(widgetId)
    }

    onLoaded: {
      if (item && widgetProps) {
        // Apply properties to loaded widget
        for (var prop in widgetProps) {
          if (item.hasOwnProperty(prop)) {
            item[prop] = widgetProps[prop]
          }
        }
      }

      // Register this widget instance with BarService
      if (screenName && section) {
        BarService.registerWidget(screenName, section, widgetId, sectionIndex, item)
      }

      if (item.hasOwnProperty("onLoaded")) {
        item.onLoaded()
      }

      //Logger.log("BarWidgetLoader", "Loaded", widgetId, "on screen", item.screen.name)
    }

    Component.onDestruction: {
      // Unregister when destroyed
      if (screenName && section) {
        BarService.unregisterWidget(screenName, section, widgetId, sectionIndex)
      }
    }
  }

  // Error handling
  onWidgetIdChanged: {
    if (widgetId && !BarWidgetRegistry.hasWidget(widgetId)) {
      Logger.warn("BarWidgetLoader", "Widget not found in bar registry:", widgetId)
    }
  }
}
