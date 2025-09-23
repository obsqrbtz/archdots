pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services

Singleton {
  id: root

  readonly property var settings: Settings.data.screenRecorder
  property bool isRecording: false
  property bool isPending: false
  property string outputPath: ""
  property bool isAvailable: ProgramCheckerService.gpuScreenRecorderAvailable

  // Update availability when ProgramCheckerService completes its checks
  Connections {
    target: ProgramCheckerService
    function onChecksCompleted() {// Availability is now automatically updated via property binding
    }
  }

  // Start or Stop recording
  function toggleRecording() {
    (isRecording || isPending) ? stopRecording() : startRecording()
  }

  // Start screen recording using Quickshell.execDetached
  function startRecording() {
    if (!isAvailable) {
      return
    }
    if (isRecording || isPending) {
      return
    }
    isPending = true

    var filename = Time.getFormattedTimestamp() + ".mp4"
    var videoDir = settings.directory
    if (videoDir && !videoDir.endsWith("/")) {
      videoDir += "/"
    }
    outputPath = videoDir + filename
    var flags = `-w ${settings.videoSource} -f ${settings.frameRate} -ac ${settings.audioCodec} -k ${settings.videoCodec} -a ${settings.audioSource} -q ${settings.quality} -cursor ${settings.showCursor ? "yes" : "no"} -cr ${settings.colorRange} -o ${outputPath}`
    var command = `
    _gpuscreenrecorder_flatpak_installed() {
    flatpak list --app | grep -q "com.dec05eba.gpu_screen_recorder"
    }
    if command -v gpu-screen-recorder >/dev/null 2>&1; then
    gpu-screen-recorder ${flags}
    elif command -v flatpak >/dev/null 2>&1 && _gpuscreenrecorder_flatpak_installed; then
    flatpak run --command=gpu-screen-recorder --file-forwarding com.dec05eba.gpu_screen_recorder ${flags}
    else
    notify-send "gpu-screen-recorder not installed!" -u critical
    fi`

    // Use Process instead of execDetached so we can monitor it
    recorderProcess.exec({
                           "command": ["sh", "-c", command]
                         })

    // Start monitoring - if process ends quickly, it was likely cancelled
    pendingTimer.running = true
  }

  // Stop recording using Quickshell.execDetached
  function stopRecording() {
    if (!isRecording && !isPending) {
      return
    }

    Quickshell.execDetached(["sh", "-c", "pkill -SIGINT -f 'gpu-screen-recorder' || pkill -SIGINT -f 'com.dec05eba.gpu_screen_recorder'"])

    isRecording = false
    isPending = false
    pendingTimer.running = false
    monitorTimer.running = false

    // Just in case, force kill after 3 seconds
    killTimer.running = true
  }

  // Process to run and monitor gpu-screen-recorder
  Process {
    id: recorderProcess
    onExited: function (exitCode, exitStatus) {
      if (isPending) {
        // Process ended while we were pending - likely cancelled or error
        isPending = false
        pendingTimer.running = false
      } else if (isRecording) {
        // Process ended normally while recording
        isRecording = false
        monitorTimer.running = false
      }
    }
  }

  Timer {
    id: pendingTimer
    interval: 2000 // Wait 2 seconds to see if process stays alive
    running: false
    repeat: false
    onTriggered: {
      if (isPending && recorderProcess.running) {
        // Process is still running after 2 seconds - assume recording started successfully
        isPending = false
        isRecording = true
        monitorTimer.running = true
      } else if (isPending) {
        // Process not running anymore - was cancelled or failed
        isPending = false
      }
    }
  }

  // Monitor timer to periodically check if we're still recording
  Timer {
    id: monitorTimer
    interval: 2000
    running: false
    repeat: true
    onTriggered: {
      if (!recorderProcess.running && isRecording) {
        isRecording = false
        running = false
      }
    }
  }

  Timer {
    id: killTimer
    interval: 3000
    running: false
    repeat: false
    onTriggered: {
      Quickshell.execDetached(["sh", "-c", "pkill -9 -f 'gpu-screen-recorder' 2>/dev/null || pkill -9 -f 'com.dec05eba.gpu_screen_recorder' 2>/dev/null || true"])
    }
  }
}
