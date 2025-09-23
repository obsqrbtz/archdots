import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets
import "../Helpers/FuzzySort.js" as Fuzzysort

RowLayout {
  id: root

  property real minimumWidth: 280 * scaling
  property real popupHeight: 180 * scaling

  property string label: ""
  property string description: ""
  property ListModel model: {

  }
  property string currentKey: ""
  property string placeholder: ""
  property string searchPlaceholder: "Search..."

  readonly property real preferredHeight: Style.baseWidgetSize * 1.1 * scaling

  signal selected(string key)

  spacing: Style.marginL * scaling
  Layout.fillWidth: true

  // Filtered model for search results
  property ListModel filteredModel: ListModel {}
  property string searchText: ""

  function findIndexByKey(key) {
    for (var i = 0; i < root.model.count; i++) {
      if (root.model.get(i).key === key) {
        return i
      }
    }
    return -1
  }

  function findIndexByKeyInFiltered(key) {
    for (var i = 0; i < root.filteredModel.count; i++) {
      if (root.filteredModel.get(i).key === key) {
        return i
      }
    }
    return -1
  }

  function filterModel() {
    filteredModel.clear()

    if (searchText.trim() === "") {
      // If no search text, show all items
      for (var i = 0; i < root.model.count; i++) {
        filteredModel.append(root.model.get(i))
      }
    } else {
      // Convert ListModel to array for fuzzy search
      var items = []
      for (var i = 0; i < root.model.count; i++) {
        items.push(root.model.get(i))
      }

      // Use fuzzy search if available, fallback to simple search
      if (typeof Fuzzysort !== 'undefined') {
        var fuzzyResults = Fuzzysort.go(searchText, items, {
                                          "key": "name",
                                          "threshold": -1000,
                                          "limit": 50
                                        })

        // Add results in order of relevance
        for (var j = 0; j < fuzzyResults.length; j++) {
          filteredModel.append(fuzzyResults[j].obj)
        }
      } else {
        // Fallback to simple search
        var searchLower = searchText.toLowerCase()
        for (var i = 0; i < items.length; i++) {
          var item = items[i]
          if (item.name.toLowerCase().includes(searchLower)) {
            filteredModel.append(item)
          }
        }
      }
    }
  }

  onSearchTextChanged: filterModel()
  onModelChanged: filterModel()

  NLabel {
    label: root.label
    description: root.description
  }

  Item {
    Layout.fillWidth: true
  }

  ComboBox {
    id: combo

    Layout.minimumWidth: root.minimumWidth
    Layout.preferredHeight: root.preferredHeight
    model: filteredModel
    currentIndex: findIndexByKeyInFiltered(currentKey)
    onActivated: {
      if (combo.currentIndex >= 0 && combo.currentIndex < filteredModel.count) {
        root.selected(filteredModel.get(combo.currentIndex).key)
      }
    }

    background: Rectangle {
      implicitWidth: Style.baseWidgetSize * 3.75 * scaling
      implicitHeight: preferredHeight
      color: Color.mSurface
      border.color: combo.activeFocus ? Color.mSecondary : Color.mOutline
      border.width: Math.max(1, Style.borderS * scaling)
      radius: Style.radiusM * scaling

      Behavior on border.color {
        ColorAnimation {
          duration: Style.animationFast
        }
      }
    }

    contentItem: NText {
      leftPadding: Style.marginL * scaling
      rightPadding: combo.indicator.width + Style.marginL * scaling
      font.pointSize: Style.fontSizeM * scaling
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      color: (combo.currentIndex >= 0 && combo.currentIndex < filteredModel.count) ? Color.mOnSurface : Color.mOnSurfaceVariant
      text: (combo.currentIndex >= 0 && combo.currentIndex < filteredModel.count) ? filteredModel.get(combo.currentIndex).name : root.placeholder
    }

    indicator: NIcon {
      x: combo.width - width - Style.marginM * scaling
      y: combo.topPadding + (combo.availableHeight - height) / 2
      icon: "caret-down"
      font.pointSize: Style.fontSizeL * scaling
    }

    popup: Popup {
      y: combo.height
      width: combo.width
      height: root.popupHeight + 60 * scaling
      padding: Style.marginM * scaling

      contentItem: ColumnLayout {
        spacing: Style.marginS * scaling

        // Search input
        NTextInput {
          id: searchInput
          Layout.fillWidth: true
          placeholderText: root.searchPlaceholder
          text: root.searchText
          onTextChanged: root.searchText = text
          fontSize: Style.fontSizeS * scaling
        }

        ListView {
          id: listView
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          model: combo.popup.visible ? filteredModel : null
          ScrollIndicator.vertical: ScrollIndicator {}

          delegate: ItemDelegate {
            width: listView.width
            hoverEnabled: true
            highlighted: ListView.view.currentIndex === index

            onHoveredChanged: {
              if (hovered) {
                ListView.view.currentIndex = index
              }
            }

            onClicked: {
              root.selected(filteredModel.get(index).key)
              combo.currentIndex = root.findIndexByKeyInFiltered(filteredModel.get(index).key)
              combo.popup.close()
            }

            contentItem: NText {
              text: name
              font.pointSize: Style.fontSizeM * scaling
              color: highlighted ? Color.mSurface : Color.mOnSurface
              verticalAlignment: Text.AlignVCenter
              elide: Text.ElideRight
              Behavior on color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }
            }

            background: Rectangle {
              width: listView.width * scaling
              color: highlighted ? Color.mTertiary : Color.transparent
              radius: Style.radiusS * scaling
              Behavior on color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }
            }
          }
        }
      }

      background: Rectangle {
        color: Color.mSurfaceVariant
        border.color: Color.mOutline
        border.width: Math.max(1, Style.borderS * scaling)
        radius: Style.radiusM * scaling
      }
    }

    // Update the currentIndex if the currentKey is changed externally
    Connections {
      target: root
      function onCurrentKeyChanged() {
        combo.currentIndex = root.findIndexByKeyInFiltered(currentKey)
      }
    }

    // Focus search input when popup opens
    Connections {
      target: combo.popup
      function onVisibleChanged() {
        if (combo.popup.visible) {
          // Small delay to ensure the popup is fully rendered
          Qt.callLater(function () {
            if (searchInput && searchInput.inputItem) {
              searchInput.inputItem.forceActiveFocus()
            }
          })
        }
      }
    }
  }
}
