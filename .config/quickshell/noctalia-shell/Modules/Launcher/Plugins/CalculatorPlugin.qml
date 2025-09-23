import QtQuick
import qs.Services
import "../../../Helpers/AdvancedMath.js" as AdvancedMath

Item {
  property var launcher: null
  property string name: "Calculator"

  function handleCommand(query) {
    // Handle >calc command or direct math expressions after >
    return query.startsWith(">calc") || (query.startsWith(">") && query.length > 1 && isMathExpression(query.substring(1)))
  }

  function commands() {
    return [{
              "name": ">calc",
              "description": "Calculator - evaluate mathematical expressions",
              "icon": "accessories-calculator",
              "isImage": false,
              "onActivate": function () {
                launcher.setSearchText(">calc ")
              }
            }]
  }

  function getResults(query) {
    let expression = ""

    if (query.startsWith(">calc")) {
      expression = query.substring(5).trim()
    } else if (query.startsWith(">")) {
      expression = query.substring(1).trim()
    } else {
      return []
    }

    if (!expression) {
      return [{
                "name": "Calculator",
                "description": "Enter a mathematical expression",
                "icon": "accessories-calculator",
                "isImage": false,
                "onActivate": function () {}
              }]
    }

    try {
      let result = AdvancedMath.evaluate(expression.trim())

      return [{
                "name": AdvancedMath.formatResult(result),
                "description": `${expression} = ${result}`,
                "icon": "accessories-calculator",
                "isImage": false,
                "onActivate": function () {
                  // TODO: copy entry to clipboard via ClipHist
                  launcher.close()
                }
              }]
    } catch (error) {
      return [{
                "name": "Error",
                "description": error.message || "Invalid expression",
                "icon": "dialog-error",
                "isImage": false,
                "onActivate": function () {}
              }]
    }
  }

  function evaluateExpression(expr) {
    // Sanitize input - only allow safe characters
    const sanitized = expr.replace(/[^0-9\+\-\*\/\(\)\.\s\%]/g, '')
    if (sanitized !== expr) {
      throw new Error("Invalid characters in expression")
    }

    // Don't allow empty expressions
    if (!sanitized.trim()) {
      throw new Error("Empty expression")
    }

    try {
      // Use Function constructor for safe evaluation
      // This is safer than eval() but still evaluate math
      const result = Function('"use strict"; return (' + sanitized + ')')()

      // Check for valid result
      if (!isFinite(result)) {
        throw new Error("Result is not a finite number")
      }

      // Round to reasonable precision to avoid floating point issues
      return Math.round(result * 1000000000) / 1000000000
    } catch (e) {
      throw new Error("Invalid mathematical expression")
    }
  }

  function isMathExpression(expr) {
    // Check if string looks like a math expression
    // Allow digits, operators, parentheses, decimal points, and whitespace
    return /^[\d\s\+\-\*\/\(\)\.\%]+$/.test(expr)
  }
  }
