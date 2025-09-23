import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets

Variants {
  model: Quickshell.screens

  delegate: Loader {
    required property ShellScreen modelData

    active: Settings.isLoaded && CompositorService.isNiri && modelData && Settings.data.wallpaper.enabled

    property string wallpaper: ""

    sourceComponent: PanelWindow {
      Component.onCompleted: {
        if (modelData) {
          Logger.log("Overview", "Loading Overview component for Niri on", modelData.name)
        }
        wallpaper = modelData ? WallpaperService.getWallpaper(modelData.name) : ""
      }

      // External state management
      Connections {
        target: WallpaperService
        function onWallpaperChanged(screenName, path) {
          if (screenName === modelData.name) {
            wallpaper = path
          }
        }
      }

      color: Color.transparent
      screen: modelData
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "quickshell-overview"

      anchors {
        top: true
        bottom: true
        right: true
        left: true
      }

      Image {
        id: bgImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: wallpaper
        smooth: true
        mipmap: false
        cache: false
      }

      MultiEffect {
        anchors.fill: parent
        source: bgImage
        autoPaddingEnabled: false
        blurEnabled: true
        blur: 0.48
        blurMax: 128
      }

      // Make the overview darker
      Rectangle {
        anchors.fill: parent
        color: Settings.data.colorSchemes.darkMode ? Qt.alpha(Color.mSurface, Style.opacityMedium) : Qt.alpha(Color.mOnSurface, Style.opacityMedium)
      }
    }
  }
}
