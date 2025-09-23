pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  // Simple signal-based notification system
  signal notify(string message, string description, string type, int duration)

  // Convenience methods
  function showNotice(message, description = "", duration = 3000) {
    notify(message, description, "notice", duration)
  }

  function showWarning(message, description = "", duration = 4000) {
    notify(message, description, "warning", duration)
  }

  function showError(message, description = "", duration = 5000) {
    notify(message, description, "error", duration)
  }
}
