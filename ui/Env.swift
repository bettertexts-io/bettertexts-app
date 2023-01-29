//
//  Environment.swift
//  ui
//
//  Created by Leo Grützner on 29.01.23.
//

import Foundation

class Env {
    static let shared = Env()
    public var variables: [String: String]
    
    private init() {
        variables = Plist.getStringMap(withName: "Env")!
    }
    
    public func getValue(for key: String) -> String{
        return variables[key]!
    }
}
