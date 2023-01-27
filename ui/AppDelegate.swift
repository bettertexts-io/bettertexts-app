//
//  AppDelegate.swift
//  ui
//
//  Created by Leo Grützner on 27.01.23.
//

import Foundation
import SwiftUI

private let styles = [
    PromptOption(title: "Note", prompt: "short precise bundled information"),
    PromptOption(title: "Professional", prompt: "professionaly writting text"),
    PromptOption(title: "Simple", prompt: "simple precise language that a 14 year old could understand"),
    PromptOption(title:
                    "Gen-Z", prompt: "gen-z language without being cringe bro"
    )
]
private let mediums = [
    PromptOption(title: "Bulletpoints", prompt: "bulletpoints"),
    PromptOption(title: "Tweet", prompt: "tweet no longer than 256 characters"),
    PromptOption(title: "E-Mail", prompt: "E-Mail with greeting and ending"),
    PromptOption(title: "Essay", prompt: "essay with introduction, main part and ending")
]
private let languages = [
    PromptOption(title: "English (Default)", prompt: "en"),
    PromptOption(title: "German", prompt: "de")
]

class PromptMenuItem: NSMenuItem {
    var id: UUID = UUID()
    var prompt: PromptOption
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    // 1
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
//            styleMask: [.miniaturizable, .closable, .resizable, .titled],
//            backing: .buffered, defer: false)
//        window.center()
//        window.title = "No Storyboard Window"
//        window.makeKeyAndOrderFront(nil)
//
        // 2
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // 3
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "b.circle", accessibilityDescription: "1")
        }
        
        setupMenus()
    }
    
    @objc func onItemSelected(_ sender: Any) {
        let selectedItem = sender as! MenuItemWithID
        print("Clicked menu item: \(selectedItem)")
        
        var path = ""
        var currentMenuItem: MenuItemWithID? = sender as? MenuItemWithID
        while currentMenuItem != nil {
            path = "/\(currentMenuItem!.id)\(path)"
            currentMenuItem = currentMenuItem?.parent as? MenuItemWithID
        }
        print("Selected path: \(path)")
    }
    
    func arrayToMenu(arr: [PromptOption], subMenuArr: [PromptOption]? = nil) -> NSMenu{
        let menu = NSMenu()
        
        arr.forEach { option in
            let item = MenuItemWithID(title: option.title, action: #selector(onItemSelected), keyEquivalent: "")
            item.id = option.id
            if(subMenuArr != nil){
                item.submenu = arrayToMenu(arr: subMenuArr!)
            }
            
            menu.addItem(item)
        }
        
        return menu
    }
    
    func setupMenus() {
        let mainMenu = NSMenu()

//      Translate & Fix
        mainMenu.addItem(MenuItemWithID(title: "Translate & Fix", action: nil, keyEquivalent: ""))
        mainMenu.addItem(MenuItemWithID(title: "Translate", action: nil, keyEquivalent: "t"))
        mainMenu.addItem(MenuItemWithID(title: "Fix Grammar & Spelling", action: nil, keyEquivalent: "g"))

//      Rephrase
        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(MenuItemWithID(title: "Rephrase", action: nil, keyEquivalent: ""))
        
        mediums.forEach { option in
            let item = MenuItemWithID(title: option.title, action: #selector(onItemSelected), keyEquivalent: "")
            item.id = option.id
            let styleMenu = arrayToMenu(arr: styles, subMenuArr: languages)
            item.submenu = styleMenu
            mainMenu.addItem(item)
        }
    
        mainMenu.addItem(NSMenuItem.separator())

        mainMenu.addItem(MenuItemWithID(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = mainMenu
    }

}
