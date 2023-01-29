////
////  Interaction.swift
////  ui
////
////  Created by Leo Grützner on 29.01.23.
////
//
//import Foundation
//
//func getForegroundAppPID() -> pid_t {
//    let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
//    let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0)) as NSArray? as? [[String: Any]]
//
//    for window in windowListInfo ?? [] {
//        if let windowNumber = window[kCGWindowNumber as String] as? CGWindowID,
//           let ownerName = window[kCGWindowOwnerName as String] as? String,
//           let onScreen = window[kCGWindowIsOnscreen as String] as? Bool,
//           onScreen,
//           let layer = window[kCGWindowLayer as String] as? Int,
//           layer == 0 {
//            let appRef = AXUIElementCreateApplication(pid_t(windowNumber))
//            var appPID: pid_t = 0
//            AXUIElementGetPid(appRef, &appPID)
//            print("ownerName", ownerName)
//            return appPID
//        }
//    }
//
//    return 0
//}
//
//let pid = getForegroundAppPID()
//print(pid)
//let app = AXUIElementCreateApplication(pid)
//var value: AnyObject?
//AXUIElementCopyAttributeValue(app, kAXSelectedTextAttribute as CFString, &value)
//if let selectedText = value as? String {
//    print("selected text", selectedText)
//}
//print("end", value)
