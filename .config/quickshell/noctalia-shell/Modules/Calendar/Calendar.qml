import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets

NPanel {
  id: root

  preferredWidth: Settings.data.location.showWeekNumberInCalendar ? 350 : 330
  preferredHeight: 320

  // Main Column
  panelContent: ColumnLayout {
    id: content
    anchors.fill: parent
    anchors.margins: Style.marginM * scaling
    spacing: Style.marginXS * scaling

    readonly property int firstDayOfWeek: Qt.locale().firstDayOfWeek

    // Header: Month/Year with navigation
    RowLayout {
      Layout.fillWidth: true
      Layout.leftMargin: Style.marginM * scaling
      Layout.rightMargin: Style.marginM * scaling
      spacing: Style.marginS * scaling

      NIconButton {
        icon: "chevron-left"
        tooltipText: "Previous month"
        onClicked: {
          let newDate = new Date(grid.year, grid.month - 1, 1)
          grid.year = newDate.getFullYear()
          grid.month = newDate.getMonth()
        }
      }

      NText {
        text: grid.title
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: Style.fontSizeM * scaling
        font.weight: Style.fontWeightBold
        color: Color.mPrimary
      }

      NIconButton {
        icon: "chevron-right"
        tooltipText: "Next month"
        onClicked: {
          let newDate = new Date(grid.year, grid.month + 1, 1)
          grid.year = newDate.getFullYear()
          grid.month = newDate.getMonth()
        }
      }
    }

    // Divider between header and weekdays
    NDivider {
      Layout.fillWidth: true
      Layout.topMargin: Style.marginS * scaling
      Layout.bottomMargin: Style.marginL * scaling
    }

    // Columns label (respects locale's first day of week)
    RowLayout {
      Layout.fillWidth: true
      Layout.leftMargin: Style.marginS * scaling // Align with grid
      Layout.rightMargin: Style.marginS * scaling
      Layout.bottomMargin: Style.marginM * scaling
      spacing: 0

      // Week header spacer or label (same width as week number column)
      Item {
        visible: Settings.data.location.showWeekNumberInCalendar
        Layout.preferredWidth: visible ? Style.baseWidgetSize * scaling : 0

        NText {
          anchors.centerIn: parent
          text: "Week"
          color: Color.mOutline
          font.pointSize: Style.fontSizeXS * scaling
          font.weight: Style.fontWeightRegular
          horizontalAlignment: Text.AlignHCenter
        }
      }

      // Day name headers - now properly aligned with calendar grid
      GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: 7
        rows: 1
        columnSpacing: 0
        rowSpacing: 0

        Repeater {
          model: 7

          Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: Style.baseWidgetSize * scaling

            NText {
              anchors.centerIn: parent
              text: {
                let dayIndex = (content.firstDayOfWeek + index) % 7
                return Qt.locale().dayName(dayIndex, Locale.ShortFormat)
              }
              color: Color.mSecondary
              font.pointSize: Style.fontSizeM * scaling
              font.weight: Style.fontWeightBold
              horizontalAlignment: Text.AlignHCenter
            }
          }
        }
      }
    }

    // Grids: days with optional week numbers
    RowLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.leftMargin: Style.marginS * scaling
      Layout.rightMargin: Style.marginS * scaling
      spacing: 0

      // Week numbers column (only visible when enabled)
      ColumnLayout {
        visible: Settings.data.location.showWeekNumberInCalendar
        Layout.preferredWidth: visible ? Style.baseWidgetSize * scaling : 0
        Layout.fillHeight: true
        spacing: 0

        Repeater {
          model: 6 // Maximum 6 weeks in a month view

          Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: Style.baseWidgetSize * scaling

            NText {
              anchors.centerIn: parent
              color: Color.mOutline
              font.pointSize: Style.fontSizeXS * scaling
              font.weight: Style.fontWeightBold
              text: {
                // Calculate the date shown in the first column of this row
                // MonthGrid always shows 42 days (6 weeks × 7 days)

                // First, find the first day of the month
                let firstOfMonth = new Date(grid.year, grid.month, 1)

                // Calculate how many days before the 1st to start the grid
                // This depends on the locale's first day of week
                let firstDayOfWeek = content.firstDayOfWeek
                let firstOfMonthDayOfWeek = firstOfMonth.getDay()

                // Calculate offset: how many days before the 1st should the grid start?
                let daysBeforeFirst = (firstOfMonthDayOfWeek - firstDayOfWeek + 7) % 7

                // MonthGrid typically shows the previous month's days to fill the first week
                // If the 1st is already on the first day of week, show the previous week
                if (daysBeforeFirst === 0) {
                  daysBeforeFirst = 7
                }

                // Calculate the start date of the grid
                let gridStartDate = new Date(grid.year, grid.month, 1 - daysBeforeFirst)

                // Calculate the date for this specific row (week)
                let rowStartDate = new Date(gridStartDate)
                rowStartDate.setDate(gridStartDate.getDate() + (index * 7))

                // For ISO week numbers, we need to find the Thursday of this week
                // ISO 8601 week numbering: week with year's first Thursday is week 1
                // The week number is determined by the Thursday

                // Find the Thursday of this row's week
                // If firstDayOfWeek is Monday (1), Thursday is +3 days
                // If firstDayOfWeek is Sunday (0), we need to adjust
                let thursday = new Date(rowStartDate)
                if (firstDayOfWeek === 0) {
                  // Sunday start: Thursday is 4 days after Sunday
                  thursday.setDate(rowStartDate.getDate() + 4)
                } else if (firstDayOfWeek === 1) {
                  // Monday start: Thursday is 3 days after Monday
                  thursday.setDate(rowStartDate.getDate() + 3)
                } else {
                  // Other start days: calculate offset to Thursday
                  let daysToThursday = (4 - firstDayOfWeek + 7) % 7
                  thursday.setDate(rowStartDate.getDate() + daysToThursday)
                }

                return `${getISOWeekNumber(thursday)}`
              }
            }
          }
        }
      }

      // The actual calendar grid
      MonthGrid {
        id: grid

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0
        month: Time.date.getMonth()
        year: Time.date.getFullYear()
        locale: Qt.locale()

        delegate: Rectangle {
          width: Style.baseWidgetSize * scaling
          height: Style.baseWidgetSize * scaling
          radius: Style.radiusS * scaling
          color: model.today ? Color.mPrimary : Color.transparent

          NText {
            anchors.centerIn: parent
            text: model.day
            color: model.today ? Color.mOnPrimary : Color.mOnSurface
            opacity: model.month === grid.month ? Style.opacityHeavy : Style.opacityLight
            font.pointSize: Style.fontSizeM * scaling
            font.weight: model.today ? Style.fontWeightBold : Style.fontWeightRegular
          }

          Behavior on color {
            ColorAnimation {
              duration: Style.animationFast
            }
          }
        }
      }
    }
  }

  // ISO 8601 week number calculation
  // This is locale-independent and always uses Monday as first day of week
  function getISOWeekNumber(date) {
    // Create a copy and set to nearest Thursday (current date + 4 - current day number)
    // ISO week starts on Monday (1) to Sunday (7)
    const target = new Date(date.getTime())
    target.setHours(0, 0, 0, 0)

    // Get day of week where Monday = 1, Sunday = 7
    const dayOfWeek = target.getDay() || 7

    // Set to nearest Thursday (which determines the week number)
    target.setDate(target.getDate() + 4 - dayOfWeek)

    // Get first day of year
    const yearStart = new Date(target.getFullYear(), 0, 1)

    // Calculate full weeks between yearStart and target
    // Add 1 because we're counting weeks, not week differences
    const weekNumber = Math.ceil(((target - yearStart) / 86400000 + 1) / 7)

    return weekNumber
  }
}
