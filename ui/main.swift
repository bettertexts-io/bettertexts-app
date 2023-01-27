//
//  main.swift
//  ui
//
//  Created by Leo Grützner on 27.01.23.
//

import Foundation
import SwiftUI  

// 1
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// 2
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
