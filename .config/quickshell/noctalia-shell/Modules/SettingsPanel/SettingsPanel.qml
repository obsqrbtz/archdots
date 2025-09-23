import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Modules.SettingsPanel.Tabs as Tabs
import qs.Commons
import qs.Services
import qs.Widgets

NPanel {
  id: root

  preferredWidth: 1000
  preferredHeight: 1000
  preferredWidthRatio: 0.4
  preferredHeightRatio: 0.75

  panelAnchorHorizontalCenter: true
  panelAnchorVerticalCenter: true

  panelKeyboardFocus: true

  draggable: true

  // Tabs enumeration, order is NOT relevant
  enum Tab {
    About,
    Audio,
    Bar,
    ColorScheme,
    Display,
    Dock,
    General,
    Hooks,
    Launcher,
    Location,
    Network,
    Notifications,
    ScreenRecorder,
    Wallpaper
  }

  property int requestedTab: SettingsPanel.Tab.General
  property int currentTabIndex: 0
  property var tabsModel: []
  property var activeScrollView: null

  Component.onCompleted: {
    updateTabsModel()
  }

  Component {
    id: generalTab
    Tabs.GeneralTab {}
  }
  Component {
    id: launcherTab
    Tabs.LauncherTab {}
  }
  Component {
    id: barTab
    Tabs.BarTab {}
  }
  Component {
    id: audioTab
    Tabs.AudioTab {}
  }
  Component {
    id: displayTab
    Tabs.DisplayTab {}
  }
  Component {
    id: networkTab
    Tabs.NetworkTab {}
  }
  Component {
    id: locationTab
    Tabs.LocationTab {}
  }
  Component {
    id: colorSchemeTab
    Tabs.ColorSchemeTab {}
  }
  Component {
    id: wallpaperTab
    Tabs.WallpaperTab {}
  }
  Component {
    id: screenRecorderTab
    Tabs.ScreenRecorderTab {}
  }
  Component {
    id: aboutTab
    Tabs.AboutTab {}
  }
  Component {
    id: hooksTab
    Tabs.HooksTab {}
  }
  Component {
    id: dockTab
    Tabs.DockTab {}
  }
  Component {
    id: notificationsTab
    Tabs.NotificationsTab {}
  }

  // Order *DOES* matter
  function updateTabsModel() {
    let newTabs = [{
                     "id": SettingsPanel.Tab.General,
                     "label": "General",
                     "icon": "settings-general",
                     "source": generalTab
                   }, {
                     "id": SettingsPanel.Tab.Bar,
                     "label": "Bar",
                     "icon": "settings-bar",
                     "source": barTab
                   }, {
                     "id": SettingsPanel.Tab.Dock,
                     "label": "Dock",
                     "icon": "settings-dock",
                     "source": dockTab
                   }, {
                     "id": SettingsPanel.Tab.Launcher,
                     "label": "Launcher",
                     "icon": "settings-launcher",
                     "source": launcherTab
                   }, {
                     "id": SettingsPanel.Tab.Audio,
                     "label": "Audio",
                     "icon": "settings-audio",
                     "source": audioTab
                   }, {
                     "id": SettingsPanel.Tab.Display,
                     "label": "Display",
                     "icon": "settings-display",
                     "source": displayTab
                   }, {
                     "id": SettingsPanel.Tab.Notifications,
                     "label": "Notifications",
                     "icon": "settings-notifications",
                     "source": notificationsTab
                   }, {
                     "id": SettingsPanel.Tab.Network,
                     "label": "Network",
                     "icon": "settings-network",
                     "source": networkTab
                   }, {
                     "id": SettingsPanel.Tab.Location,
                     "label": "Location",
                     "icon": "settings-location",
                     "source": locationTab
                   }, {
                     "id": SettingsPanel.Tab.ColorScheme,
                     "label": "Color scheme",
                     "icon": "settings-color-scheme",
                     "source": colorSchemeTab
                   }, {
                     "id": SettingsPanel.Tab.Wallpaper,
                     "label": "Wallpaper",
                     "icon": "settings-wallpaper",
                     "source": wallpaperTab
                   }, {
                     "id": SettingsPanel.Tab.ScreenRecorder,
                     "label": "Screen recorder",
                     "icon": "settings-screen-recorder",
                     "source": screenRecorderTab
                   }, {
                     "id": SettingsPanel.Tab.Hooks,
                     "label": "Hooks",
                     "icon": "settings-hooks",
                     "source": hooksTab
                   }, {
                     "id": SettingsPanel.Tab.About,
                     "label": "About",
                     "icon": "settings-about",
                     "source": aboutTab
                   }]

    root.tabsModel = newTabs // Assign the generated list to the model
  }
  // When the panel opens, choose the appropriate tab
  onOpened: {
    updateTabsModel()

    var initialIndex = SettingsPanel.Tab.General
    if (root.requestedTab !== null) {
      for (var i = 0; i < root.tabsModel.length; i++) {
        if (root.tabsModel[i].id === root.requestedTab) {
          initialIndex = i
          break
        }
      }
    }
    // Now that the UI is settled, set the current tab index.
    root.currentTabIndex = initialIndex
  }

  // Add scroll functions
  function scrollDown() {
    if (activeScrollView && activeScrollView.ScrollBar.vertical) {
      const scrollBar = activeScrollView.ScrollBar.vertical
      const stepSize = activeScrollView.height * 0.1 // Scroll 10% of viewport
      scrollBar.position = Math.min(scrollBar.position + stepSize / activeScrollView.contentHeight, 1.0 - scrollBar.size)
    }
  }

  function scrollUp() {
    if (activeScrollView && activeScrollView.ScrollBar.vertical) {
      const scrollBar = activeScrollView.ScrollBar.vertical
      const stepSize = activeScrollView.height * 0.1 // Scroll 10% of viewport
      scrollBar.position = Math.max(scrollBar.position - stepSize / activeScrollView.contentHeight, 0)
    }
  }

  function scrollPageDown() {
    if (activeScrollView && activeScrollView.ScrollBar.vertical) {
      const scrollBar = activeScrollView.ScrollBar.vertical
      const pageSize = activeScrollView.height * 0.9 // Scroll 90% of viewport
      scrollBar.position = Math.min(scrollBar.position + pageSize / activeScrollView.contentHeight, 1.0 - scrollBar.size)
    }
  }

  function scrollPageUp() {
    if (activeScrollView && activeScrollView.ScrollBar.vertical) {
      const scrollBar = activeScrollView.ScrollBar.vertical
      const pageSize = activeScrollView.height * 0.9 // Scroll 90% of viewport
      scrollBar.position = Math.max(scrollBar.position - pageSize / activeScrollView.contentHeight, 0)
    }
  }

  // Add navigation functions
  function selectNextTab() {
    if (tabsModel.length > 0) {
      currentTabIndex = (currentTabIndex + 1) % tabsModel.length
    }
  }

  function selectPreviousTab() {
    if (tabsModel.length > 0) {
      currentTabIndex = (currentTabIndex - 1 + tabsModel.length) % tabsModel.length
    }
  }

  panelContent: Rectangle {
    color: Color.transparent

    // Main layout container that fills the panel
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL * scaling
      spacing: 0

      // Keyboard shortcuts container
      Item {
        Layout.preferredWidth: 0
        Layout.preferredHeight: 0

        // Scrolling via keyboard
        Shortcut {
          sequence: "Down"
          onActivated: root.scrollDown()
          enabled: root.opened
        }

        Shortcut {
          sequence: "Up"
          onActivated: root.scrollUp()
          enabled: root.opened
        }

        Shortcut {
          sequence: "Ctrl+J"
          onActivated: root.scrollDown()
          enabled: root.opened
        }

        Shortcut {
          sequence: "Ctrl+K"
          onActivated: root.scrollUp()
          enabled: root.opened
        }

        Shortcut {
          sequence: "PgDown"
          onActivated: root.scrollPageDown()
          enabled: root.opened
        }

        Shortcut {
          sequence: "PgUp"
          onActivated: root.scrollPageUp()
          enabled: root.opened
        }

        // Changing tab via keyboard
        Shortcut {
          sequence: "Tab"
          onActivated: root.selectNextTab()
          enabled: root.opened
        }

        Shortcut {
          sequence: "Shift+Tab"
          onActivated: root.selectPreviousTab()
          enabled: root.opened
        }
      }

      // Main content area
      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Style.marginM * scaling

        // Sidebar
        Rectangle {
          id: sidebar
          Layout.preferredWidth: 220 * scaling
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignTop
          color: Color.mSurfaceVariant
          border.color: Color.mOutline
          border.width: Math.max(1, Style.borderS * scaling)
          radius: Style.radiusM * scaling

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton // Don't interfere with clicks
            property int wheelAccumulator: 0
            onWheel: wheel => {
                       wheelAccumulator += wheel.angleDelta.y
                       if (wheelAccumulator >= 120) {
                         root.selectPreviousTab()
                         wheelAccumulator = 0
                       } else if (wheelAccumulator <= -120) {
                         root.selectNextTab()
                         wheelAccumulator = 0
                       }
                       wheel.accepted = true
                     }
          }

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginS * scaling
            spacing: Style.marginXS * scaling

            Repeater {
              id: sections
              model: root.tabsModel
              delegate: Rectangle {
                id: tabItem
                Layout.fillWidth: true
                Layout.preferredHeight: tabEntryRow.implicitHeight + Style.marginS * scaling * 2
                radius: Style.radiusS * scaling
                color: selected ? Color.mPrimary : (tabItem.hovering ? Color.mTertiary : Color.transparent)
                readonly property bool selected: index === currentTabIndex
                property bool hovering: false
                property color tabTextColor: selected ? Color.mOnPrimary : (tabItem.hovering ? Color.mOnTertiary : Color.mOnSurface)

                Behavior on color {
                  ColorAnimation {
                    duration: Style.animationFast
                  }
                }

                Behavior on tabTextColor {
                  ColorAnimation {
                    duration: Style.animationFast
                  }
                }

                RowLayout {
                  id: tabEntryRow
                  anchors.fill: parent
                  anchors.leftMargin: Style.marginS * scaling
                  anchors.rightMargin: Style.marginS * scaling
                  spacing: Style.marginM * scaling

                  // Tab icon
                  NIcon {
                    icon: modelData.icon
                    color: tabTextColor
                    font.pointSize: Style.fontSizeXL * scaling
                  }

                  // Tab label
                  NText {
                    text: modelData.label
                    color: tabTextColor
                    font.pointSize: Style.fontSizeM * scaling
                    font.weight: Style.fontWeightBold
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  acceptedButtons: Qt.LeftButton
                  onEntered: tabItem.hovering = true
                  onExited: tabItem.hovering = false
                  onCanceled: tabItem.hovering = false
                  onClicked: currentTabIndex = index
                }
              }
            }

            Item {
              Layout.fillHeight: true
            }
          }
        }

        // Content pane
        Rectangle {
          id: contentPane
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignTop
          radius: Style.radiusM * scaling
          color: Color.mSurfaceVariant
          border.color: Color.mOutline
          border.width: Math.max(1, Style.borderS * scaling)
          clip: true

          ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: Style.marginL * scaling
            spacing: Style.marginS * scaling

            // Header row
            RowLayout {
              id: headerRow
              Layout.fillWidth: true
              spacing: Style.marginS * scaling

              // Main icon
              NIcon {
                icon: root.tabsModel[currentTabIndex]?.icon
                color: Color.mPrimary
                font.pointSize: Style.fontSizeXXL * scaling
              }

              // Main title
              NText {
                text: root.tabsModel[currentTabIndex]?.label || ""
                font.pointSize: Style.fontSizeXL * scaling
                font.weight: Style.fontWeightBold
                color: Color.mPrimary
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
              }

              // Close button
              NIconButton {
                icon: "close"
                tooltipText: "Close"
                Layout.alignment: Qt.AlignVCenter
                onClicked: root.close()
              }
            }

            // Divider
            NDivider {
              Layout.fillWidth: true
            }

            // Tab content area
            Rectangle {
              Layout.fillWidth: true
              Layout.fillHeight: true
              color: Color.transparent

              Repeater {
                model: root.tabsModel
                delegate: Loader {
                  anchors.fill: parent
                  active: index === root.currentTabIndex

                  onStatusChanged: {
                    if (status === Loader.Ready && item) {
                      // Find and store reference to the ScrollView
                      const scrollView = item.children[0]
                      if (scrollView && scrollView.toString().includes("ScrollView")) {
                        root.activeScrollView = scrollView
                      }
                    }
                  }

                  sourceComponent: Flickable {
                    // Using a Flickable here with a pressDelay to fix conflict between
                    // ScrollView and NTextInput. This fixes the weird text selection issue.
                    id: flickable
                    anchors.fill: parent
                    pressDelay: 200

                    NScrollView {
                      id: scrollView
                      anchors.fill: parent
                      horizontalPolicy: ScrollBar.AlwaysOff
                      verticalPolicy: ScrollBar.AsNeeded
                      padding: Style.marginL * scaling
                      clip: true

                      Component.onCompleted: {
                        root.activeScrollView = scrollView
                      }

                      Loader {
                        active: true
                        sourceComponent: root.tabsModel[index]?.source
                        width: scrollView.availableWidth
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
