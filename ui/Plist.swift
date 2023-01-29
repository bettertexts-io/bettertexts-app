//
//  Plist.swift
//  ui
//
//  Created by Leo Grützner on 29.01.23.
//

import Foundation

public class Plist {
    public static func getStringMap(withName name: String) -> [String: String]?
    {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else {return nil}

        let url = URL(fileURLWithPath: path)

        let data = try! Data(contentsOf: url)

        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: String] else {return nil}

        return plist
    }
}
