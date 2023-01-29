////
////  ContentView.swift
////  ui
////
////  Created by Leo Grützner on 25.01.23.
////
//
//import SwiftUI
//
//
//
//struct RadioList: View{
//    public var title: String
//    public var options: [PromptOption]
//    @Binding public var selected: UUID
//    
//    public var body: some View {
//        Picker(selection: $selected, label: Text(title).fontWeight(.bold)) {
//            ForEach(options) { option in
//                Text(option.title).tag(option.id)
//            }
//        }
//        .pickerStyle(.radioGroup)
//        .horizontalRadioGroupLayout()
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//    
//}
//
//extension Binding {
//    func onChange(_ handler: @escaping (Value) async -> Void) -> Binding<Value> {
//        Binding(
//            get: { self.wrappedValue },
//            set: { newValue in
//                self.wrappedValue = newValue
//                Task {
//                    await handler(newValue)
//                }
//            }
//        )
//    }
//}
//
//struct ContentView: View {
//    private var env: [String: String]?
//    private var apiUrl: URL?
//    private var apiKey: String?
//    private var inputText: String?
//    @State private var selectedStyle = UUID()
//    @State private var selectedMedium = UUID()
//    @State private var selectedLanguage = UUID()
//    @State private var versions: [String]?
//    @State private var loading = false
//    @State private var status = StatusMessages.Selection.rawValue
//    
//    func getPlist(withName name: String) -> [String:String]?
//    {
//        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else {return nil}
//        
//        let url = URL(fileURLWithPath: path)
//
//        let data = try! Data(contentsOf: url)
//
//        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String] else {return nil}
//        
//        return plist
//    }
//    
//    init () {
//        self.env = getPlist(withName: "Env")
//        self.apiUrl = URL(string: self.env!["API_URL"]!)!
//        self.apiKey = self.env!["API_KEY"]!
//        updateInput()
//    }
//    
//    private mutating func updateInput () {
//        let pasteboard = NSPasteboard.general
//        let clipboardText = pasteboard.pasteboardItems?.first?.string(forType: .string)
//        inputText = clipboardText != nil ? clipboardText! : ""
//    }
//    
//    

//    
//    var body: some View {
//        VStack {
//            Button("Read Clipboard"){
////                updateInput()
//            }
//            RadioList(title: "Style", options: styles, selected: $selectedStyle.onChange(fetchApi))
//            RadioList(title: "Medium", options: mediums, selected: $selectedMedium.onChange(fetchApi))
//            RadioList(title: "Language", options: languages, selected: $selectedLanguage.onChange(fetchApi))
//            ProgressView().opacity(loading ? 1 : 0)
//            Text(status)
//        }
//        .padding()
//        .frame(width: 500)
//        
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
