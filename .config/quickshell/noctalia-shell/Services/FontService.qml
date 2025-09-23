pragma Singleton

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons

Singleton {
  id: root

  property ListModel availableFonts: ListModel {}
  property ListModel monospaceFonts: ListModel {}
  property ListModel displayFonts: ListModel {}
  property bool fontsLoaded: false
  property var fontconfigMonospaceFonts: []

  // -------------------------------------------
  function init() {
    Logger.log("Font", "Service started")
    loadFontconfigMonospaceFonts()
  }

  function loadFontconfigMonospaceFonts() {
    fontconfigProcess.command = ["fc-list", ":mono", "family"]
    fontconfigProcess.running = true
  }

  function loadSystemFonts() {
    Logger.log("Font", "Loading system fonts...")

    var fontFamilies = Qt.fontFamilies()

    availableFonts.clear()
    monospaceFonts.clear()
    displayFonts.clear()

    for (var i = 0; i < fontFamilies.length; i++) {
      var fontName = fontFamilies[i]
      if (fontName && fontName.trim() !== "") {
        availableFonts.append({
                                "key": fontName,
                                "name": fontName
                              })

        if (isMonospaceFont(fontName)) {
          monospaceFonts.append({
                                  "key": fontName,
                                  "name": fontName
                                })
        }

        if (isDisplayFont(fontName)) {
          displayFonts.append({
                                "key": fontName,
                                "name": fontName
                              })
        }
      }
    }

    sortModel(availableFonts)
    sortModel(monospaceFonts)
    sortModel(displayFonts)

    if (monospaceFonts.count === 0) {
      addFallbackFonts(monospaceFonts, ["DejaVu Sans Mono"])
    }

    if (displayFonts.count === 0) {
      addFallbackFonts(displayFonts, ["Inter", "Roboto", "DejaVu Sans"])
    }

    fontsLoaded = true
    Logger.log("Font", "Loaded", availableFonts.count, "fonts:", monospaceFonts.count, "monospace,", displayFonts.count, "display")
  }

  function isMonospaceFont(fontName) {
    // First, check if fontconfig detected this as monospace
    if (fontconfigMonospaceFonts.indexOf(fontName) !== -1) {
      return true
    }

    // Minimal fallback: only check for basic monospace patterns
    var lowerFontName = fontName.toLowerCase()
    if (lowerFontName.includes("mono") || lowerFontName.includes("monospace")) {
      return true
    }

    return false
  }

  function isDisplayFont(fontName) {
    // Minimal fallback: only check for basic display patterns
    var lowerFontName = fontName.toLowerCase()
    if (lowerFontName.includes("display") || lowerFontName.includes("headline") || lowerFontName.includes("title")) {
      return true
    }

    // Essential fallback fonts only
    var essentialFonts = ["Inter", "Roboto", "DejaVu Sans"]
    return essentialFonts.includes(fontName)
  }

  function sortModel(model) {
    var fontsArray = []
    for (var i = 0; i < model.count; i++) {
      fontsArray.push({
                        "key": model.get(i).key,
                        "name": model.get(i).name
                      })
    }

    fontsArray.sort(function (a, b) {
      return a.name.localeCompare(b.name)
    })

    model.clear()
    for (var j = 0; j < fontsArray.length; j++) {
      model.append(fontsArray[j])
    }
  }

  function addFallbackFonts(model, fallbackFonts) {
    for (var i = 0; i < fallbackFonts.length; i++) {
      var fontName = fallbackFonts[i]
      var exists = false
      for (var j = 0; j < model.count; j++) {
        if (model.get(j).name === fontName) {
          exists = true
          break
        }
      }

      if (!exists) {
        model.append({
                       "key": fontName,
                       "name": fontName
                     })
      }
    }

    sortModel(model)
  }

  function searchFonts(query) {
    if (!query || query.trim() === "")
      return availableFonts

    var results = []
    var lowerQuery = query.toLowerCase()

    for (var i = 0; i < availableFonts.count; i++) {
      var font = availableFonts.get(i)
      if (font.name.toLowerCase().includes(lowerQuery)) {
        results.push(font)
      }
    }

    return results
  }

  // Process for fontconfig commands
  Process {
    id: fontconfigProcess
    running: false

    stdout: StdioCollector {
      onStreamFinished: {
        if (this.text !== "") {
          var lines = this.text.split('\n')
          fontconfigMonospaceFonts = []

          for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line && line !== "") {
              if (fontconfigMonospaceFonts.indexOf(line) === -1) {
                fontconfigMonospaceFonts.push(line)
              }
            }
          }
        }
        loadSystemFonts()
      }
    }

    onExited: function (exitCode, exitStatus) {
      if (exitCode !== 0) {
        fontconfigMonospaceFonts = []
      }
      loadSystemFonts()
    }
  }
}
