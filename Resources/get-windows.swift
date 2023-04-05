#!/usr/bin/env swift

import AppKit

let windowList: CFArray? = CGWindowListCopyWindowInfo(
  [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)

guard let windows = windowList as? [[String: Any]] else { fatalError("Unable to get window list") }

let sfItems = windows.compactMap { (dict: [String: Any]) -> [String: Any]? in
  guard
    dict["kCGWindowLayer"] as? Int == 0,
    let appName = dict["kCGWindowOwnerName"] as? String,
    let appPID = dict["kCGWindowOwnerPID"] as? Int32,
    let windowTitle = dict["kCGWindowName"] as? String,
    let windowID = dict["kCGWindowNumber"] as? Int32,
    let appPath = NSRunningApplication(processIdentifier: appPID)?.bundleURL?.path
  else { return nil }

  let windowName = windowTitle.isEmpty ? "Unnamed" : windowTitle

  return [
    "title": windowName,
    "subtitle": appName,
    "arg": [appPID, windowID],
    "icon": ["type": "fileicon", "path": appPath],
    "match": "\(windowName) \(appName)"
  ]
}

if sfItems.isEmpty {
  let alfredObject = [
    "items": [
      [
        "title": "No Windows Found",
        "subtitle":
          "Make sure Alfred has Screen Recording permissions. Press ↩ to open System Settings.",
        "arg": "request_permissions"
      ]
    ]
  ]

  let jsonData: Data = try JSONSerialization.data(withJSONObject: alfredObject)
  let jsonString: String = String(data: jsonData, encoding: .utf8)!

  print(jsonString)
  exit(0)
}

let jsonData: Data = try JSONSerialization.data(withJSONObject: ["items": sfItems])
let jsonString: String = String(data: jsonData, encoding: .utf8)!
print(jsonString)
