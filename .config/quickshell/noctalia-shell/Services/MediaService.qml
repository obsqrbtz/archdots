pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons
import qs.Services

Singleton {
  id: root

  property var currentPlayer: null
  property real currentPosition: 0
  property bool isSeeking: false
  property int selectedPlayerIndex: 0
  property bool isPlaying: currentPlayer ? (currentPlayer.playbackState === MprisPlaybackState.Playing || currentPlayer.isPlaying) : false
  property string trackTitle: currentPlayer ? (currentPlayer.trackTitle || "") : ""
  property string trackArtist: currentPlayer ? (currentPlayer.trackArtist || "") : ""
  property string trackAlbum: currentPlayer ? (currentPlayer.trackAlbum || "") : ""
  property string trackArtUrl: currentPlayer ? (currentPlayer.trackArtUrl || "") : ""
  property real trackLength: currentPlayer ? ((currentPlayer.length < infiniteTrackLength) ? currentPlayer.length : 0) : 0
  property bool canPlay: currentPlayer ? currentPlayer.canPlay : false
  property bool canPause: currentPlayer ? currentPlayer.canPause : false
  property bool canGoNext: currentPlayer ? currentPlayer.canGoNext : false
  property bool canGoPrevious: currentPlayer ? currentPlayer.canGoPrevious : false
  property bool canSeek: currentPlayer ? currentPlayer.canSeek : false
  property real infiniteTrackLength: 922337203685

  Component.onCompleted: {
    updateCurrentPlayer()
  }

  function getAvailablePlayers() {
    if (!Mpris.players || !Mpris.players.values) {
      return []
    }

    let allPlayers = Mpris.players.values
    let controllablePlayers = []

    // Apply blacklist and controllable filter
    const blacklist = (Settings.data.audio && Settings.data.audio.mprisBlacklist) ? Settings.data.audio.mprisBlacklist : []
    for (var i = 0; i < allPlayers.length; i++) {
      let player = allPlayers[i]
      if (!player)
        continue
      const identity = String(player.identity || "")
      const busName = String(player.busName || "")
      const desktop = String(player.desktopEntry || "")
      const idKey = identity.toLowerCase()
      const match = blacklist.find(b => {
                                     const s = String(b || "").toLowerCase()
                                     return s && (idKey.includes(s) || busName.toLowerCase().includes(s) || desktop.toLowerCase().includes(s))
                                   })
      if (match)
        continue
      if (player.canControl)
        controllablePlayers.push(player)
    }

    return controllablePlayers
  }

  function findActivePlayer() {
    let availablePlayers = getAvailablePlayers()
    if (availablePlayers.length === 0) {
      Logger.log("Media", "No active player found")
      return null
    }

    // Preferred player logic (preferred > fallback)
    const preferred = (Settings.data.audio.preferredPlayer || "")
    if (preferred !== "") {
      for (var i = 0; i < availablePlayers.length; i++) {
        const p = availablePlayers[i]
        const identity = String(p.identity || "").toLowerCase()
        const busName = String(p.busName || "").toLowerCase()
        const desktop = String(p.desktopEntry || "").toLowerCase()
        const pref = preferred.toLowerCase()
        if (identity.includes(pref) || busName.includes(pref) || desktop.includes(pref)) {
          selectedPlayerIndex = i
          return p
        }
      }
    }

    if (selectedPlayerIndex < availablePlayers.length) {
      return availablePlayers[selectedPlayerIndex]
    } else {
      selectedPlayerIndex = 0
      return availablePlayers[0]
    }
  }

  // Switch to the most recently active player
  function updateCurrentPlayer() {
    let newPlayer = findActivePlayer()
    if (newPlayer !== currentPlayer) {
      currentPlayer = newPlayer
      currentPosition = currentPlayer ? currentPlayer.position : 0
      Logger.log("Media", "Switching player")
    }
  }

  function playPause() {
    if (currentPlayer) {
      if (currentPlayer.isPlaying) {
        currentPlayer.pause()
      } else {
        currentPlayer.play()
      }
    }
  }

  function play() {
    if (currentPlayer && currentPlayer.canPlay) {
      currentPlayer.play()
    }
  }

  function pause() {
    if (currentPlayer && currentPlayer.canPause) {
      currentPlayer.pause()
    }
  }

  function next() {
    if (currentPlayer && currentPlayer.canGoNext) {
      currentPlayer.next()
    }
  }

  function previous() {
    if (currentPlayer && currentPlayer.canGoPrevious) {
      currentPlayer.previous()
    }
  }

  function seek(position) {
    if (currentPlayer && currentPlayer.canSeek) {
      currentPlayer.position = position
      currentPosition = position
    }
  }

  // Seek to position based on ratio (0.0 to 1.0)
  function seekByRatio(ratio) {
    if (currentPlayer && currentPlayer.canSeek && currentPlayer.length > 0) {
      let seekPosition = ratio * currentPlayer.length
      currentPlayer.position = seekPosition
      currentPosition = seekPosition
    }
  }

  // Update progress bar every second while playing
  Timer {
    id: positionTimer
    interval: 1000
    running: currentPlayer && !root.isSeeking && currentPlayer.isPlaying && currentPlayer.length > 0 && currentPlayer.playbackState === MprisPlaybackState.Playing
    repeat: true
    onTriggered: {
      if (currentPlayer && !root.isSeeking && currentPlayer.isPlaying && currentPlayer.playbackState === MprisPlaybackState.Playing) {
        currentPosition = currentPlayer.position
      } else {
        running = false
      }
    }
  }

  // Avoid overwriting currentPosition while seeking due to backend position changes
  Connections {
    target: currentPlayer
    function onPositionChanged() {
      if (!root.isSeeking && currentPlayer) {
        currentPosition = currentPlayer.position
      }
    }
    function onPlaybackStateChanged() {
      if (!root.isSeeking && currentPlayer) {
        currentPosition = currentPlayer.position
      }
    }
  }

  // Reset position when switching to inactive player
  onCurrentPlayerChanged: {
    if (!currentPlayer || !currentPlayer.isPlaying || currentPlayer.playbackState !== MprisPlaybackState.Playing) {
      currentPosition = 0
    }
  }

  // Update current player when available players change
  Connections {
    target: Mpris.players
    function onValuesChanged() {
      Logger.log("Media", "Players changed")
      updateCurrentPlayer()
    }
  }
}
