//
//  Clipboard.swift
//  ui
//
//  Created by Leo Grützner on 28.01.23.
//

import Foundation
import AppKit

class Clipboard {
    public static func setString(value: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
    }
    
    public static func getString() -> String? {
        let pasteboard = NSPasteboard.general
        return pasteboard.pasteboardItems?.first?.string(forType: .string)
    }
}
