import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons

Rectangle {
  id: root
  color: Color.mSurface
  border.color: Color.mOutline
  border.width: Math.max(1, Style.borderS * scaling)
  radius: Style.radiusM * scaling

  property date sampleDate: new Date() // Dec 25, 2023, 2:30:45.123 PM

  // Signal emitted when a token is clicked
  signal tokenClicked(string token)

  ColumnLayout {
    id: column
    anchors.fill: parent
    anchors.margins: Style.marginS * scaling
    spacing: Style.marginS * scaling

    // Scrollable list of tokens
    NScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      horizontalPolicy: ScrollBar.AlwaysOff
      verticalPolicy: ScrollBar.AsNeeded

      ListView {
        id: tokensList
        model: ListModel {

          // Common format combinations
          ListElement {
            category: "Common"
            token: "h:mm AP"
            description: "12-hour time with minutes"
            example: "2:30 PM"
          }
          ListElement {
            category: "Common"
            token: "HH:mm"
            description: "24-hour time with minutes"
            example: "14:30"
          }
          ListElement {
            category: "Common"
            token: "HH:mm:ss"
            description: "24-hour time with seconds"
            example: "14:30:45"
          }
          ListElement {
            category: "Common"
            token: "ddd MMM d"
            description: "Weekday, month and day"
            example: "Mon Dec 25"
          }
          ListElement {
            category: "Common"
            token: "yyyy-MM-dd"
            description: "ISO date format"
            example: "2023-12-25"
          }
          ListElement {
            category: "Common"
            token: "MM/dd/yyyy"
            description: "US date format"
            example: "12/25/2023"
          }
          ListElement {
            category: "Common"
            token: "dd.MM.yyyy"
            description: "European date format"
            example: "25.12.2023"
          }
          ListElement {
            category: "Common"
            token: "ddd, MMM dd"
            description: "Weekday with date"
            example: "Fri, Dec 12"
          }

          // Hour tokens
          // ListElement {
          //   category: "Hour"
          //   token: "h"
          //   description: "Hour without leading zero (12-hour when used with AP/ap, otherwise 24-hour)"
          //   example: "2 (needs AP/ap for 12hr)"
          // }
          // ListElement {
          //   category: "Hour"
          //   token: "hh"
          //   description: "Hour with leading zero (12-hour when used with AP/ap, otherwise 24-hour)"
          //   example: "02 (needs AP/ap for 12hr)"
          // }
          // ListElement {
          //   category: "Hour"
          //   token: "h AP"
          //   description: "12-hour format with AM/PM"
          //   example: "2 PM"
          // }
          // ListElement {
          //   category: "Hour"
          //   token: "hh AP"
          //   description: "12-hour format with leading zero and AM/PM"
          //   example: "02 PM"
          // }
          ListElement {
            category: "Hour"
            token: "H"
            description: "Hour without leading zero (0-23) - 24-hour format"
            example: "14"
          }
          ListElement {
            category: "Hour"
            token: "HH"
            description: "Hour with leading zero (00-23) - 24-hour format"
            example: "14"
          }

          // Minute tokens
          ListElement {
            category: "Minute"
            token: "m"
            description: "Minute without leading zero (0-59)"
            example: "30"
          }
          ListElement {
            category: "Minute"
            token: "mm"
            description: "Minute with leading zero (00-59)"
            example: "30"
          }

          // Second tokens
          ListElement {
            category: "Second"
            token: "s"
            description: "Second without leading zero (0-59)"
            example: "45"
          }
          ListElement {
            category: "Second"
            token: "ss"
            description: "Second with leading zero (00-59)"
            example: "45"
          }

          // AM/PM tokens
          ListElement {
            category: "AM/PM"
            token: "AP"
            description: "AM/PM in uppercase"
            example: "PM"
          }
          ListElement {
            category: "AM/PM"
            token: "ap"
            description: "am/pm in lowercase"
            example: "pm"
          }

          // Timezone tokens
          ListElement {
            category: "Timezone"
            token: "t"
            description: "Timezone abbreviation"
            example: "UTC"
          }

          // Year tokens
          ListElement {
            category: "Year"
            token: "yy"
            description: "Year as two-digit number (00-99)"
            example: "23"
          }
          ListElement {
            category: "Year"
            token: "yyyy"
            description: "Year as four-digit number"
            example: "2023"
          }

          // Month tokens
          ListElement {
            category: "Month"
            token: "M"
            description: "Month as number without leading zero (1-12)"
            example: "12"
          }
          ListElement {
            category: "Month"
            token: "MM"
            description: "Month as number with leading zero (01-12)"
            example: "12"
          }
          ListElement {
            category: "Month"
            token: "MMM"
            description: "Abbreviated month name"
            example: "Dec"
          }
          ListElement {
            category: "Month"
            token: "MMMM"
            description: "Full month name"
            example: "December"
          }

          // Day tokens
          ListElement {
            category: "Day"
            token: "d"
            description: "Day without leading zero (1-31)"
            example: "25"
          }
          ListElement {
            category: "Day"
            token: "dd"
            description: "Day with leading zero (01-31)"
            example: "25"
          }
          ListElement {
            category: "Day"
            token: "ddd"
            description: "Abbreviated day name"
            example: "Mon"
          }
          ListElement {
            category: "Day"
            token: "dddd"
            description: "Full day name"
            example: "Monday"
          }
        }

        delegate: Rectangle {
          id: tokenDelegate
          width: tokensList.width
          height: layout.implicitHeight + Style.marginS * scaling
          radius: Style.radiusS * scaling
          color: {
            if (tokenMouseArea.containsMouse) {
              return Qt.alpha(Color.mPrimary, 0.1)
            }
            return index % 2 === 0 ? Color.mSurfaceVariant : Qt.alpha(Color.mSurfaceVariant, 0.6)
          }

          // Mouse area for the entire delegate
          MouseArea {
            id: tokenMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
              // Emit the signal with the token
              root.tokenClicked(model.token)

              // Visual feedback
              clickAnimation.start()
            }
          }

          // Click animation
          SequentialAnimation {
            id: clickAnimation
            PropertyAnimation {
              target: tokenDelegate
              property: "color"
              to: Qt.alpha(Color.mPrimary, 0.3)
              duration: 100
            }
            PropertyAnimation {
              target: tokenDelegate
              property: "color"
              to: tokenMouseArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.1) : (index % 2 === 0 ? Color.mSurface : Color.mSurfaceVariant)
              duration: 200
            }
          }

          RowLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Style.marginXS * scaling
            spacing: Style.marginM * scaling

            // Category badge
            Rectangle {
              Layout.alignment: Qt.AlignVCenter
              width: 70 * scaling
              height: 22 * scaling
              color: getCategoryColor(model.category)[0]
              radius: Style.radiusS * scaling
              opacity: tokenMouseArea.containsMouse ? 0.9 : 1.0

              Behavior on opacity {
                NumberAnimation {
                  duration: Style.animationFast
                }
              }

              NText {
                anchors.centerIn: parent
                text: model.category
                color: getCategoryColor(model.category)[1]
                font.pointSize: Style.fontSizeXS * scaling
              }
            }

            // Token - Made more prominent and clickable
            Rectangle {
              id: tokenButton
              Layout.alignment: Qt.AlignVCenter // Added this line
              width: 100 * scaling
              height: 22 * scaling
              color: tokenMouseArea.containsMouse ? Color.mPrimary : Color.mOnSurface
              radius: Style.radiusS * scaling

              Behavior on color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }

              NText {
                anchors.centerIn: parent
                text: model.token
                color: tokenMouseArea.containsMouse ? Color.mOnPrimary : Color.mSurface
                font.pointSize: Style.fontSizeS * scaling
                font.weight: Style.fontWeightBold

                Behavior on color {
                  ColorAnimation {
                    duration: Style.animationFast
                  }
                }
              }
            }

            // Description
            NText {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter // Added this line
              text: model.description
              color: tokenMouseArea.containsMouse ? Color.mOnSurface : Color.mOnSurfaceVariant
              font.pointSize: Style.fontSizeS * scaling
              wrapMode: Text.WordWrap

              Behavior on color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }
            }

            // Live example
            Rectangle {
              Layout.alignment: Qt.AlignVCenter // Added this line
              width: 90 * scaling
              height: 22 * scaling
              color: tokenMouseArea.containsMouse ? Color.mPrimary : Color.mOnSurfaceVariant
              radius: Style.radiusS * scaling
              border.color: tokenMouseArea.containsMouse ? Color.mPrimary : Color.mOutline
              border.width: Math.max(1, Style.borderS * scaling)

              Behavior on color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }

              Behavior on border.color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }

              NText {
                anchors.centerIn: parent
                text: Qt.formatDateTime(root.sampleDate, model.token)
                color: tokenMouseArea.containsMouse ? Color.mOnPrimary : Color.mSurfaceVariant
                font.pointSize: Style.fontSizeS * scaling

                Behavior on color {
                  ColorAnimation {
                    duration: Style.animationFast
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  function getCategoryColor(category) {
    switch (category) {
    case "Year":
      return [Color.mPrimary, Color.mOnPrimary]
    case "Month":
      return [Color.mSecondary, Color.mOnSecondary]
    case "Day":
      return [Color.mTertiary, Color.mOnTertiary]
    case "Hour":
      return [Color.mPrimary, Color.mOnPrimary]
    case "Minute":
      return [Color.mSecondary, Color.mOnSecondary]
    case "Second":
      return [Color.mTertiary, Color.mOnTertiary]
    case "AM/PM":
      return [Color.mError, Color.mOnError]
    case "Timezone":
      return [Color.mOnSurface, Color.mSurface]
    case "Common":
      return [Color.mError, Color.mOnError]
    default:
      return [Color.mOnSurfaceVariant, Color.mSurfaceVariant]
    }
  }
}
