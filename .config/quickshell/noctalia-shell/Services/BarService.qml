pragma Singleton

import Quickshell
import qs.Commons

Singleton {
  id: root

  // Registry to store actual widget instances
  // Key format: "screenName|section|widgetId|index"
  property var widgetInstances: ({})
  // Register a widget instance
  function registerWidget(screenName, section, widgetId, index, instance) {
    const key = [screenName, section, widgetId, index].join("|")
    widgetInstances[key] = {
      "key": key,
      "screenName": screenName,
      "section": section,
      "widgetId": widgetId,
      "index": index,
      "instance": instance
    }
    Logger.log("BarService", "Registered widget:", key)
  }

  // Unregister a widget instance
  function unregisterWidget(screenName, section, widgetId, index) {
    const key = [screenName, section, widgetId, index].join("|")
    delete widgetInstances[key]
    Logger.log("BarService", "Unregistered widget:", key)
  }

  // Lookup a specific widget instance (returns the actual QML instance)
  function lookupWidget(widgetId, screenName = null, section = null, index = null) {
    // If looking for a specific instance
    if (screenName && section !== null) {
      for (var key in widgetInstances) {
        var widget = widgetInstances[key]
        if (widget.widgetId === widgetId && widget.screenName === screenName && widget.section === section) {
          if (index === null) {
            return widget.instance
          } else if (widget.index == index) {
            return widget.instance
          }
        }
      }
    }

    // Return first match if no specific screen/section specified
    for (var key in widgetInstances) {
      var widget = widgetInstances[key]
      if (widget.widgetId === widgetId) {
        if (!screenName || widget.screenName === screenName) {
          if (section === null || widget.section === section) {
            return widget.instance
          }
        }
      }
    }

    return undefined
  }

  // Get all instances of a widget type
  function getAllWidgetInstances(widgetId = null, screenName = null, section = null) {
    var instances = []

    for (var key in widgetInstances) {
      var widget = widgetInstances[key]

      var matches = true
      if (widgetId && widget.widgetId !== widgetId)
        matches = false
      if (screenName && widget.screenName !== screenName)
        matches = false
      if (section !== null && widget.section !== section)
        matches = false

      if (matches) {
        instances.push(widget.instance)
      }
    }

    return instances
  }

  // Get widget with full metadata
  function getWidgetWithMetadata(widgetId, screenName = null, section = null) {
    for (var key in widgetInstances) {
      var widget = widgetInstances[key]
      if (widget.widgetId === widgetId) {
        if (!screenName || widget.screenName === screenName) {
          if (section === null || widget.section === section) {
            return widget
          }
        }
      }
    }
    return undefined
  }

  // Get all widgets in a specific section
  function getWidgetsBySection(section, screenName = null) {
    var widgets = []

    for (var key in widgetInstances) {
      var widget = widgetInstances[key]
      if (widget.section === section) {
        if (!screenName || widget.screenName === screenName) {
          widgets.push(widget.instance)
        }
      }
    }

    // Sort by index to maintain order
    widgets.sort(function (a, b) {
      var aWidget = getWidgetWithMetadata(a.widgetId, a.screen?.name, a.section)
      var bWidget = getWidgetWithMetadata(b.widgetId, b.screen?.name, b.section)
      return (aWidget?.index || 0) - (bWidget?.index || 0)
    })

    return widgets
  }

  // Get all registered widgets (for debugging)
  function getAllRegisteredWidgets() {
    var result = []
    for (var key in widgetInstances) {
      result.push({
                    "key": key,
                    "widgetId": widgetInstances[key].widgetId,
                    "section": widgetInstances[key].section,
                    "screenName": widgetInstances[key].screenName,
                    "index": widgetInstances[key].index
                  })
    }
    return result
  }

  // Check if a widget type exists in a section
  function hasWidget(widgetId, section = null, screenName = null) {
    for (var key in widgetInstances) {
      var widget = widgetInstances[key]
      if (widget.widgetId === widgetId) {
        if (section === null || widget.section === section) {
          if (!screenName || widget.screenName === screenName) {
            return true
          }
        }
      }
    }
    return false
  }

  // Get pill direction for a widget instance
  function getPillDirection(widgetInstance) {
    try {
      if (widgetInstance.section === "left") {
        return true
      } else if (widgetInstance.section === "right") {
        return false
      } else {
        // middle section
        if (widgetInstance.sectionWidgetIndex < widgetInstance.sectionWidgetsCount / 2) {
          return false
        } else {
          return true
        }
      }
    } catch (e) {
      Logger.error(e)
    }
    return false
  }
}
