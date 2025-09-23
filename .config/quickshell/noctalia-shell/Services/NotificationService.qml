pragma Singleton

import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.Commons
import qs.Services
import "../Helpers/sha256.js" as Checksum

Singleton {
  id: root

  // Configuration
  property int maxVisible: 5
  property int maxHistory: 100
  property string historyFile: Quickshell.env("NOCTALIA_NOTIF_HISTORY_FILE") || (Settings.cacheDir + "notifications.json")

  // Models
  property ListModel activeList: ListModel {}
  property ListModel historyList: ListModel {}

  // Internal state
  property var activeMap: ({})
  property var imageQueue: []

  // Simple image cacher
  PanelWindow {
    implicitHeight: 1
    implicitWidth: 1
    color: "transparent"
    mask: Region {}

    Image {
      id: cacher
      width: 64
      height: 64
      visible: true
      cache: false
      asynchronous: true
      mipmap: true
      antialiasing: true

      onStatusChanged: {
        if (imageQueue.length === 0)
        return
        const req = imageQueue[0]

        if (status === Image.Ready) {
          Logger.log("Notification", "Caching image to:", req.dest)
          Quickshell.execDetached(["mkdir", "-p", Settings.cacheDirImagesNotifications])
          grabToImage(result => {
                        if (result.saveToFile(req.dest))
                        updateImagePath(req.imageId, req.dest)
                        processNextImage()
                      })
        } else if (status === Image.Error) {
          processNextImage()
        }
      }

      function processNextImage() {
        imageQueue.shift()
        if (imageQueue.length > 0) {
          source = imageQueue[0].src
        } else {
          source = ""
        }
      }
    }
  }

  // Notification server
  NotificationServer {
    keepOnReload: false
    imageSupported: true
    actionsSupported: true
    onNotification: notification => handleNotification(notification)
  }

  // Main handler
  function handleNotification(notification) {
    const data = createData(notification)
    addToHistory(data)

    if (Settings.data.notifications?.doNotDisturb)
      return

    activeMap[data.id] = notification
    notification.tracked = true
    notification.closed.connect(() => removeActive(data.id))

    activeList.insert(0, data)
    while (activeList.count > maxVisible) {
      const last = activeList.get(activeList.count - 1)
      activeMap[last.id]?.dismiss()
      activeList.remove(activeList.count - 1)
    }
  }

  function createData(n) {
    const time = new Date()
    const id = Checksum.sha256(JSON.stringify({
                                                "summary": n.summary,
                                                "body": n.body,
                                                "app": n.appName,
                                                "time": time.getTime()
                                              }))

    const image = n.image || getIcon(n.appIcon)
    const imageId = generateImageId(n, image)
    queueImage(image, imageId)

    return {
      "id": id,
      "summary": (n.summary || ""),
      "body": stripTags(n.body || ""),
      "appName": getAppName(n.appName),
      "urgency": n.urgency || 1,
      "timestamp": time,
      "originalImage": image,
      "cachedImage": imageId ? (Settings.cacheDirImagesNotifications + imageId + ".png") : image,
      "actionsJson": JSON.stringify((n.actions || []).map(a => ({
                                                                  "text": a.text || "Action",
                                                                  "identifier": a.identifier || ""
                                                                })))
    }
  }

  function queueImage(path, imageId) {
    if (!path || !path.startsWith("image://") || !imageId)
      return

    const dest = Settings.cacheDirImagesNotifications + imageId + ".png"

    // Skip if already queued
    for (const req of imageQueue) {
      if (req.imageId === imageId)
        return
    }

    imageQueue.push({
                      "src": path,
                      "dest": dest,
                      "imageId": imageId
                    })

    // If we have a single item in the queue, process it immediately
    if (imageQueue.length === 1)
      cacher.source = path
  }

  function updateImagePath(id, path) {
    updateModel(activeList, id, "cachedImage", path)
    updateModel(historyList, id, "cachedImage", path)
    saveHistory()
  }

  function updateModel(model, id, prop, value) {
    for (var i = 0; i < model.count; i++) {
      if (model.get(i).id === id) {
        model.setProperty(i, prop, "")
        model.setProperty(i, prop, value)
        break
      }
    }
  }

  function removeActive(id) {
    for (var i = 0; i < activeList.count; i++) {
      if (activeList.get(i).id === id) {
        activeList.remove(i)
        delete activeMap[id]
        break
      }
    }
  }

  // Auto-hide timer
  Timer {
    interval: 1000
    repeat: true
    running: activeList.count > 0
    onTriggered: {
      const now = Date.now()
      const durations = [3000, 8000, 15000] // low, normal, critical

      for (var i = activeList.count - 1; i >= 0; i--) {
        const notif = activeList.get(i)
        const elapsed = now - notif.timestamp.getTime()

        if (elapsed >= durations[notif.urgency] || elapsed >= 8000) {
          animateAndRemove(notif.id, i)
          break
        }
      }
    }
  }

  // History management
  function addToHistory(data) {
    historyList.insert(0, data)

    while (historyList.count > maxHistory) {
      const old = historyList.get(historyList.count - 1)
      if (old.cachedImage && !old.cachedImage.startsWith("image://")) {
        Quickshell.execDetached(["rm", "-f", old.cachedImage])
      }
      historyList.remove(historyList.count - 1)
    }
    saveHistory()
  }

  // Persistence
  FileView {
    id: historyFileView
    path: historyFile
    printErrors: false
    onLoaded: loadHistory()
    onLoadFailed: error => {
      if (error === 2)
      writeAdapter()
    }

    JsonAdapter {
      id: adapter
      property var notifications: []
    }
  }

  Timer {
    id: saveTimer
    interval: 200
    onTriggered: performSaveHistory()
  }

  function saveHistory() {
    saveTimer.restart()
  }

  function performSaveHistory() {
    try {
      const items = []
      for (var i = 0; i < historyList.count; i++) {
        const n = historyList.get(i)
        const copy = Object.assign({}, n)
        copy.timestamp = n.timestamp.getTime()
        items.push(copy)
      }
      adapter.notifications = items
      // Actually write the file
      historyFileView.writeAdapter()
    } catch (e) {
      Logger.error("Notifications", "Save history failed:", e)
    }
  }

  function loadHistory() {
    try {
      historyList.clear()
      for (const item of adapter.notifications || []) {
        const time = new Date(item.timestamp)

        // Check if we have a cached image and try to use it
        let cachedImage = item.cachedImage || ""
        if (item.originalImage && item.originalImage.startsWith("image://") && !cachedImage) {
          // Try to generate the expected cached path
          const imageId = generateImageId(item, item.originalImage)
          if (imageId) {
            cachedImage = Settings.cacheDirImagesNotifications + imageId + ".png"
          }
        }

        historyList.append({
                             "id": item.id || "",
                             "summary": item.summary || "",
                             "body": item.body || "",
                             "appName": item.appName || "",
                             "urgency": item.urgency || 1,
                             "timestamp": time,
                             "originalImage": item.originalImage || "",
                             "cachedImage": cachedImage
                           })
      }
    } catch (e) {
      Logger.error("Notifications", "Load failed:", e)
    }
  }

  // Helpers
  function getAppName(name) {
    if (!name?.includes("."))
      return name || ""
    const entries = DesktopEntries.byId(name)
    if (entries?.length)
      return entries[0].name || name
    const parts = name.split(".")
    return parts[parts.length - 1].charAt(0).toUpperCase() + parts[parts.length - 1].slice(1)
  }

  function getIcon(icon) {
    if (!icon)
      return ""
    if (icon.startsWith("/") || icon.startsWith("file://"))
      return icon
    return AppIcons.iconFromName(icon)
  }

  function stripTags(text) {
    return text.replace(/<[^>]*>?/gm, '')
  }

  function generateImageId(notification, image) {
    if (image && image.startsWith("image://")) {
      // For qsimage URLs, try to use a combination that's unique per user
      if (image.startsWith("image://qsimage/")) {
        // Try to use app name + summary for uniqueness (summary often contains username)
        const key = (notification.appName || "") + "|" + (notification.summary || "")
        return Checksum.sha256(key)
      }

      return Checksum.sha256(image)
    }
    return ""
  }

  // Public API
  function dismissActiveNotification(id) {
    activeMap[id]?.dismiss()
    removeActive(id)
  }

  function dismissAllActive() {
    Object.values(activeMap).forEach(n => n.dismiss())
    activeList.clear()
    activeMap = {}
  }

  function invokeAction(id, actionId) {
    const n = activeMap[id]
    if (!n?.actions)
      return false

    for (const action of n.actions) {
      if (action.identifier === actionId && action.invoke) {
        action.invoke()
        return true
      }
    }
    return false
  }

  function removeFromHistory(notificationId) {
    for (var i = 0; i < historyList.count; i++) {
      const notif = historyList.get(i)
      if (notif.id === notificationId) {
        // Delete cached image if it exists
        if (notif.cachedImage && !notif.cachedImage.startsWith("image://")) {
          Quickshell.execDetached(["rm", "-f", notif.cachedImage])
        }
        historyList.remove(i)
        saveHistory()
        return true
      }
    }
    return false
  }

  function clearHistory() {
    // Remove all cached images
    try {
      Quickshell.execDetached(["sh", "-c", `rm -rf "${Settings.cacheDirImagesNotifications}"*`])
    } catch (e) {
      Logger.error("Notifications", "Failed to clear cache directory:", e)
    }

    historyList.clear()
    saveHistory()
  }

  // Signals & connections
  signal animateAndRemove(string notificationId, int index)

  Connections {
    target: Settings.data.notifications
    function onDoNotDisturbChanged() {
      const enabled = Settings.data.notifications.doNotDisturb
      ToastService.showNotice(enabled ? "'Do not disturb' enabled" : "'Do not disturb' disabled", enabled ? "You'll find these notifications in your history." : "Showing all notifications.")
    }
  }
}
