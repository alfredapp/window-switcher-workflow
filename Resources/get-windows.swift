#!/usr/bin/env swift

import AppKit

// Helpers
struct ScriptFilterItem: Codable {
  let title: String
  let subtitle: String
  let arg: [Int32]
  let icon: [String: String]
  let match: String
}

// Grab windows
let windowList: CFArray? = CGWindowListCopyWindowInfo(
  [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)

guard let windows = windowList as? [[String: Any]] else { fatalError("Unable to get window list") }

// Populate items
let sfItems: [ScriptFilterItem] = windows.compactMap { dict in
  guard
    dict["kCGWindowLayer"] as? Int == 0,
    let appName = dict["kCGWindowOwnerName"] as? String,
    let appPID = dict["kCGWindowOwnerPID"] as? Int32,
    let windowTitle = dict["kCGWindowName"] as? String,
    let windowID = dict["kCGWindowNumber"] as? Int32,
    let appPath = NSRunningApplication(processIdentifier: appPID)?.bundleURL?.path
  else { return nil }

  let windowName = windowTitle.isEmpty ? "Unnamed" : windowTitle

  return ScriptFilterItem(
    title: windowName,
    subtitle: appName,
    arg: [appPID, windowID],
    icon: ["type": "fileicon", "path": appPath],
    match: "\(windowName) \(appName)"
  )
}

// Fallback if no valid items
guard !sfItems.isEmpty else {
  let notFound = [
    "title": "No Windows Found",
    "subtitle":
      "Make sure Alfred has Screen Recording permissions. Press ↩ to open System Settings.",
    "arg": "request_permissions"
  ]

  let jsonData: Data = try JSONSerialization.data(withJSONObject: ["items": [notFound]])
  let jsonString: String = String(data: jsonData, encoding: .utf8)!

  print(jsonString)
  exit(0)
}

// Output JSON
let jsonData = try JSONEncoder().encode(["items": sfItems])
print(String(data: jsonData, encoding: .utf8)!)
