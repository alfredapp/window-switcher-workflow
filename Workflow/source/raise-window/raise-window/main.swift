#!/usr/bin/env swift

guard let appPID = Int(CommandLine.arguments[1]),
  let windowNumber = Int(CommandLine.arguments[2])
else { fatalError("Requires two arguments: app PID and window number") }

let axApp = AXUIElementCreateApplication(pid_t(appPID))
var axWindows: AnyObject?
AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &axWindows)

(axWindows as! [AXUIElement]).forEach { axWindow in
  var axWindowNumber: CGWindowID = 0
  _AXUIElementGetWindow(axWindow, &axWindowNumber)

  guard axWindowNumber == windowNumber else { return }

  let app = NSRunningApplication(processIdentifier: pid_t(appPID))
  app?.activate(options: .activateIgnoringOtherApps)
  AXUIElementPerformAction(axWindow, kAXRaiseAction as CFString)
}
