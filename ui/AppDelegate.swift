//
//  AppDelegate.swift
//  ui
//
//  Created by Leo Grützner on 27.01.23.
//

import Foundation
import SwiftUI

struct Environment {
    var API_KEY: String
    var API_URL: String
}

enum PromptOptionType: String {
    case Language = "langCode"
    case Style = "style"
    case Medium = "medium"
    case Translate = "Translate"
    case Fix = "Fix"
    case Invalid
}

struct PromptOption: Identifiable{
    let id = UUID()
    var type: PromptOptionType
    var title: String
    var prompt: String
}

private let styles = [
    PromptOption(type: PromptOptionType.Style, title: "Friendly", prompt: "friendly"),
    PromptOption(type: PromptOptionType.Style, title: "Professional", prompt: "professional"),
    PromptOption(type: PromptOptionType.Style, title: "Witty", prompt: "witty"),
    PromptOption(type: PromptOptionType.Style, title:
                    "Exciting", prompt: "exciting"
    ),
    PromptOption(type: PromptOptionType.Style, title:
                    "Relaxed", prompt: "relaxed"
    ),
    PromptOption(type: PromptOptionType.Style, title:
                    "Bold", prompt: "bold"
    ),
    PromptOption(type: PromptOptionType.Style, title:
                    "Adventourous", prompt: "adventourous"
    ),
    PromptOption(type: PromptOptionType.Style, title:
                    "Persuasive", prompt: "persuasive"
    ),
    PromptOption(type: PromptOptionType.Style, title:
                    "Empathetic", prompt: "empathetic"
    ),
    PromptOption(type: PromptOptionType.Style, title:
                    "Funny", prompt: "funny"
    ),
    PromptOption(type: PromptOptionType.Style, title:
                    "Sarcastic", prompt: "sarcastic"
    ),
    PromptOption(type: PromptOptionType.Style, title:
                    "Custom", prompt: "custom"
    )
]
private let mediums = [
    PromptOption(type: PromptOptionType.Medium, title: "Joke", prompt: "Joke"),
    PromptOption(type: PromptOptionType.Medium, title: "Email", prompt: "Email"),
    PromptOption(type: PromptOptionType.Medium, title: "Letter", prompt: "Letter"),
    PromptOption(type: PromptOptionType.Medium, title: "Tweet", prompt: "Tweet"),
    PromptOption(type: PromptOptionType.Medium, title: "Bulletpoints", prompt: "Bulletpoints")
]
private let languages = [
    PromptOption(type: PromptOptionType.Language, title: "English", prompt: "en"),
    PromptOption(type: PromptOptionType.Language, title: "German", prompt: "de")
]

private enum StatusMessages: String {
    case Selection = "How would you like your text?"
    case Loading = "Let me think about it..."
    case Copied = "Our masterpiece was copied to your clipboard ✓"
}

class PromptMenuItem: NSMenuItem {
    public var type: PromptOptionType
    public var prompt: String?
    
    init(type: PromptOptionType, title: String, prompt: String, action: Selector?, keyEquivalent: String, subMenuItems: [PromptMenuItem]? = nil){
        self.type = type
        self.prompt = prompt
        super.init(title: title, action: action, keyEquivalent: keyEquivalent)
        if(subMenuItems != nil){
            let menu = NSMenu()
            addPromptOptionsToMenu(baseMenu: menu, items: subMenuItems!)
            self.submenu = menu
        }
    }
    
    init(title: String){
        self.type = PromptOptionType.Invalid
        super.init(title: title, action: nil, keyEquivalent: "")
    }
    
    required init(coder decoder: NSCoder) {
        self.type = PromptOptionType.Invalid
        super.init(coder: decoder)
    }
}

func addPromptOptionsToMenu(baseMenu: NSMenu, items: [PromptMenuItem]) {
    items.forEach { option in
        baseMenu.addItem(option)
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var statusItem: NSStatusItem!
    private var api = BettertextsApi.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "b.circle", accessibilityDescription: "bettertexts")
        }
        
        setupMenus()
    }
    
    @objc func onItemSelected(_ sender: Any) {
        let selectedItem = sender as! PromptMenuItem
        print("Clicked menu item: \(selectedItem)")
        
        
        var langCode = "en"
        var style: String = ""
        var medium: String = ""
        
        var path = ""
        var currentMenuItem: PromptMenuItem? = sender as? PromptMenuItem
        while currentMenuItem != nil {
            path = "/\(currentMenuItem!.title)\(path)"
            
            switch(currentMenuItem!.type){
            case .Language:
                langCode = currentMenuItem!.prompt!
            case .Style:
                style = currentMenuItem!.prompt!
            case .Medium:
                medium = currentMenuItem!.prompt!
            case .Invalid:
                break;
            case .Translate:
                break;
            case .Fix:
                break;
            }
            currentMenuItem = currentMenuItem?.parent as? PromptMenuItem
        }
        
        let input = Clipboard.getString()
        if(input != nil){
            Task{ [style, medium, langCode] in
                let paraphrase = await api.getParaphrase(originalText: input!, style: style, medium: medium, langCode: langCode)
                print("Got response from API", paraphrase)
                if(paraphrase != nil){
                    Clipboard.setString(value: paraphrase!)
                }
            }
        }
    }
    
    func createPromptMenuItems(from options: [PromptOption], subMenuTree: [[PromptOption]]? = nil) -> [PromptMenuItem] {
        var menuItems: [PromptMenuItem] = []
        
        for option in options {
            var subMenuItems: [PromptMenuItem]?
            if(subMenuTree != nil && subMenuTree!.count >= 1){
                let subTree = subMenuTree!.count > 1 ? Array(subMenuTree!.dropFirst().map { $0 as [PromptOption] }) : nil
                subMenuItems = createPromptMenuItems(from: subMenuTree![0], subMenuTree: subTree)
            }
            
            let menuItem = PromptMenuItem(type: option.type, title: option.title, prompt: option.prompt, action: #selector(onItemSelected), keyEquivalent: "", subMenuItems: subMenuItems)

            menuItems.append(menuItem)
        }
        return menuItems
    }
    
    func setupMenus() {
        let mainMenu = NSMenu()

//      Translate & Fix
        mainMenu.addItem(PromptMenuItem(title: "Translate & Fix"))
        mainMenu.addItem(PromptMenuItem(type: PromptOptionType.Language,title: "Translate", prompt: "", action: nil, keyEquivalent: "t"))
        mainMenu.addItem(PromptMenuItem(type: PromptOptionType.Language,title: "Fix Grammar & Spelling", prompt: "",action: nil, keyEquivalent: "g"))

//      Rephrase
        mainMenu.addItem(NSMenuItem.separator())
        mainMenu.addItem(PromptMenuItem(title: "Rephrase"))
                    
        addPromptOptionsToMenu(baseMenu: mainMenu, items: createPromptMenuItems(from: mediums, subMenuTree: [styles, languages]))
        
        mainMenu.addItem(NSMenuItem.separator())

        mainMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = mainMenu
    }

}
