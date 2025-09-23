import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Modules.SettingsPanel
import qs.Widgets

Variants {
  id: backgroundVariants
  model: Quickshell.screens

  delegate: Loader {

    required property ShellScreen modelData

    active: Settings.isLoaded && modelData && Settings.data.wallpaper.enabled

    sourceComponent: PanelWindow {
      id: root

      // Internal state management
      property string transitionType: "fade"
      property real transitionProgress: 0

      readonly property real edgeSmoothness: Settings.data.wallpaper.transitionEdgeSmoothness
      readonly property var allTransitions: WallpaperService.allTransitions
      readonly property bool transitioning: transitionAnimation.running

      // Wipe direction: 0=left, 1=right, 2=up, 3=down
      property real wipeDirection: 0

      // Disc
      property real discCenterX: 0.5
      property real discCenterY: 0.5

      // Stripe
      property real stripesCount: 16
      property real stripesAngle: 0

      // Used to debounce wallpaper changes
      property string futureWallpaper: ""

      // Fillmode default is "crop"
      property real fillMode: 1.0
      property vector4d fillColor: Qt.vector4d(Settings.data.wallpaper.fillColor.r, Settings.data.wallpaper.fillColor.g, Settings.data.wallpaper.fillColor.b, 1.0)

      // On startup assign wallpaper immediately
      Component.onCompleted: {
        fillMode = WallpaperService.getFillModeUniform()

        var path = modelData ? WallpaperService.getWallpaper(modelData.name) : ""
        setWallpaperImmediate(path)
      }

      Connections {
        target: Settings.data.wallpaper
        function onFillModeChanged() {
          fillMode = WallpaperService.getFillModeUniform()
        }
      }

      // External state management
      Connections {
        target: WallpaperService
        function onWallpaperChanged(screenName, path) {
          if (screenName === modelData.name) {

            // Update wallpaper display
            // Set wallpaper immediately on startup
            futureWallpaper = path
            debounceTimer.restart()
          }
        }
      }

      color: Color.transparent
      screen: modelData
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "quickshell-wallpaper"

      anchors {
        bottom: true
        top: true
        right: true
        left: true
      }

      Timer {
        id: debounceTimer
        interval: 333
        running: false
        repeat: false
        onTriggered: {
          changeWallpaper()
        }
      }

      Image {
        id: currentWallpaper
        source: ""
        smooth: true
        mipmap: false
        visible: false
        cache: false
        asynchronous: true
      }

      Image {
        id: nextWallpaper
        source: ""
        smooth: true
        mipmap: false
        visible: false
        cache: false
        asynchronous: true
      }

      // Fade or None transition shader
      ShaderEffect {
        id: fadeShader
        anchors.fill: parent
        visible: transitionType === "fade" || transitionType === "none"

        property variant source1: currentWallpaper
        property variant source2: nextWallpaper
        property real progress: root.transitionProgress

        // Fill mode properties
        property real fillMode: root.fillMode
        property vector4d fillColor: root.fillColor
        property real imageWidth1: source1.sourceSize.width
        property real imageHeight1: source1.sourceSize.height
        property real imageWidth2: source2.sourceSize.width
        property real imageHeight2: source2.sourceSize.height
        property real screenWidth: width
        property real screenHeight: height

        fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/Shaders/qsb/wp_fade.frag.qsb")
      }

      // Wipe transition shader
      ShaderEffect {
        id: wipeShader
        anchors.fill: parent
        visible: transitionType === "wipe"

        property variant source1: currentWallpaper
        property variant source2: nextWallpaper
        property real progress: root.transitionProgress
        property real smoothness: root.edgeSmoothness
        property real direction: root.wipeDirection

        // Fill mode properties
        property real fillMode: root.fillMode
        property vector4d fillColor: root.fillColor
        property real imageWidth1: source1.sourceSize.width
        property real imageHeight1: source1.sourceSize.height
        property real imageWidth2: source2.sourceSize.width
        property real imageHeight2: source2.sourceSize.height
        property real screenWidth: width
        property real screenHeight: height

        fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/Shaders/qsb/wp_wipe.frag.qsb")
      }

      // Disc reveal transition shader
      ShaderEffect {
        id: discShader
        anchors.fill: parent
        visible: transitionType === "disc"

        property variant source1: currentWallpaper
        property variant source2: nextWallpaper
        property real progress: root.transitionProgress
        property real smoothness: root.edgeSmoothness
        property real aspectRatio: root.width / root.height
        property real centerX: root.discCenterX
        property real centerY: root.discCenterY

        // Fill mode properties
        property real fillMode: root.fillMode
        property vector4d fillColor: root.fillColor
        property real imageWidth1: source1.sourceSize.width
        property real imageHeight1: source1.sourceSize.height
        property real imageWidth2: source2.sourceSize.width
        property real imageHeight2: source2.sourceSize.height
        property real screenWidth: width
        property real screenHeight: height

        fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/Shaders/qsb/wp_disc.frag.qsb")
      }

      // Diagonal stripes transition shader
      ShaderEffect {
        id: stripesShader
        anchors.fill: parent
        visible: transitionType === "stripes"

        property variant source1: currentWallpaper
        property variant source2: nextWallpaper
        property real progress: root.transitionProgress
        property real smoothness: root.edgeSmoothness
        property real aspectRatio: root.width / root.height
        property real stripeCount: root.stripesCount
        property real angle: root.stripesAngle

        // Fill mode properties
        property real fillMode: root.fillMode
        property vector4d fillColor: root.fillColor
        property real imageWidth1: source1.sourceSize.width
        property real imageHeight1: source1.sourceSize.height
        property real imageWidth2: source2.sourceSize.width
        property real imageHeight2: source2.sourceSize.height
        property real screenWidth: width
        property real screenHeight: height

        fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/Shaders/qsb/wp_stripes.frag.qsb")
      }

      // Animation for the transition progress
      NumberAnimation {
        id: transitionAnimation
        target: root
        property: "transitionProgress"
        from: 0.0
        to: 1.0
        // The stripes shader feels faster visually, we make it a bit slower here.
        duration: transitionType == "stripes" ? Settings.data.wallpaper.transitionDuration * 1.6 : Settings.data.wallpaper.transitionDuration
        easing.type: Easing.InOutCubic
        onFinished: {
          // Swap images after transition completes
          currentWallpaper.source = nextWallpaper.source
          nextWallpaper.source = ""
          transitionProgress = 0.0
          Qt.callLater(() => {
                         currentWallpaper.asynchronous = true
                       })
        }
      }

      function setWallpaperImmediate(source) {
        transitionAnimation.stop()
        transitionProgress = 0.0
        currentWallpaper.source = source
        nextWallpaper.source = ""
      }

      function setWallpaperWithTransition(source) {
        if (source === currentWallpaper.source) {
          return
        }

        if (transitioning) {
          // We are interrupting a transition
          transitionAnimation.stop()
          transitionProgress = 0
          currentWallpaper.source = nextWallpaper.source
          nextWallpaper.source = ""
        }

        nextWallpaper.source = source
        currentWallpaper.asynchronous = false
        transitionAnimation.start()
      }

      // Main method that actually trigger the wallpaper change
      function changeWallpaper() {
        // Get the transitionType from the settings
        transitionType = Settings.data.wallpaper.transitionType

        if (transitionType == "random") {
          var index = Math.floor(Math.random() * allTransitions.length)
          transitionType = allTransitions[index]
        }

        // Ensure the transition type really exists
        if (transitionType !== "none" && !allTransitions.includes(transitionType)) {
          transitionType = "fade"
        }

        //Logger.log("Background", "New wallpaper: ", futureWallpaper, "On:", modelData.name, "Transition:", transitionType)
        switch (transitionType) {
        case "none":
          setWallpaperImmediate(futureWallpaper)
          break
        case "wipe":
          wipeDirection = Math.random() * 4
          setWallpaperWithTransition(futureWallpaper)
          break
        case "disc":
          discCenterX = Math.random()
          discCenterY = Math.random()
          setWallpaperWithTransition(futureWallpaper)
          break
        case "stripes":
          stripesCount = Math.round(Math.random() * 20 + 4)
          stripesAngle = Math.random() * 360
          setWallpaperWithTransition(futureWallpaper)
          break
        default:
          setWallpaperWithTransition(futureWallpaper)
          break
        }
      }
    }
  }
}
