import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL * scaling

  NHeader {
    label: "Your location"
    description: "Get accurate weather and night light scheduling by setting your location."
  }

  // Location section
  RowLayout {
    Layout.fillWidth: true
    spacing: Style.marginL * scaling

    NTextInput {
      label: "Search for a location"
      description: "e.g., Toronto, ON"
      text: Settings.data.location.name || Settings.defaultLocation
      placeholderText: "Enter the location name"
      onEditingFinished: {
        // Verify the location has really changed to avoid extra resets
        var newLocation = text.trim()
        // If empty, set to default location
        if (newLocation === "") {
          newLocation = Settings.defaultLocation
          text = Settings.defaultLocation // Update the input field to show the default
        }
        if (newLocation != Settings.data.location.name) {
          Settings.data.location.name = newLocation
          LocationService.resetWeather()
        }
      }
      Layout.maximumWidth: 420 * scaling
    }

    NText {
      visible: LocationService.coordinatesReady
      text: `${LocationService.stableName} (${LocationService.displayCoordinates})`
      font.pointSize: Style.fontSizeS * scaling
      color: Color.mOnSurfaceVariant
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignRight
      Layout.alignment: Qt.AlignBottom
      Layout.bottomMargin: 12 * scaling
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // Weather section
  ColumnLayout {
    spacing: Style.marginM * scaling
    Layout.fillWidth: true

    NHeader {
      label: "Weather"
      description: "Choose your preferred temperature unit."
    }

    NToggle {
      label: "Display temperature in Fahrenheit (°F)"
      description: "Display temperature in Fahrenheit instead of Celsius."
      checked: Settings.data.location.useFahrenheit
      onToggled: checked => Settings.data.location.useFahrenheit = checked
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }

  // Weather section
  ColumnLayout {
    spacing: Style.marginM * scaling
    Layout.fillWidth: true

    NHeader {
      label: "Date & time"
      description: "Customize how date and time appear."
    }

    NToggle {
      label: "Use 12-hour time format on the lock screen"
      description: "On for AM/PM format (e.g., 8:00 PM), off for 24-hour format (e.g., 20:00)."
      checked: Settings.data.location.use12hourFormat
      onToggled: checked => Settings.data.location.use12hourFormat = checked
    }

    NToggle {
      label: "Show week numbers"
      description: "Displays the week of the year (e.g., Week 38) in the calendar."
      checked: Settings.data.location.showWeekNumberInCalendar
      onToggled: checked => Settings.data.location.showWeekNumberInCalendar = checked
    }
  }

  NDivider {
    Layout.fillWidth: true
    Layout.topMargin: Style.marginXL * scaling
    Layout.bottomMargin: Style.marginXL * scaling
  }
}
