//
//  ContentView.swift
//  ui
//
//  Created by Leo Grützner on 25.01.23.
//

import SwiftUI

struct Environment {
    var API_KEY: String
    var API_URL: String
}

struct ParaphraseRequestBody: Codable {
    var input: String
    var style: String
    var medium: String
    var langCode: String
}

struct ParaphraseResponseBody: Codable {
    var results: [String]
}

struct PromptOption: Identifiable{
    let id = UUID()
    var title: String
    var prompt: String
}

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
    PromptOption(title: "English", prompt: "en"),
    PromptOption(title: "German", prompt: "de")
]

private enum StatusMessages: String {
    case Selection = "How would you like your text?"
    case Loading = "Let me think about it..."
    case Copied = "Our masterpiece was copied to your clipboard ✓"
}

struct RadioList: View{
    public var title: String
    public var options: [PromptOption]
    @Binding public var selected: UUID
    
    public var body: some View {
        Picker(selection: $selected, label: Text(title).fontWeight(.bold)) {
            ForEach(options) { option in
                Text(option.title).tag(option.id)
            }
        }
        .pickerStyle(.radioGroup)
        .horizontalRadioGroupLayout()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

extension Binding {
    func onChange(_ handler: @escaping (Value) async -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                Task {
                    await handler(newValue)
                }
            }
        )
    }
}

struct ContentView: View {
    private var env: [String: String]?
    private var apiUrl: URL?
    private var apiKey: String?
    private var inputText: String?
    @State private var selectedStyle = UUID()
    @State private var selectedMedium = UUID()
    @State private var selectedLanguage = UUID()
    @State private var versions: [String]?
    @State private var loading = false
    @State private var status = StatusMessages.Selection.rawValue
    
    func getPlist(withName name: String) -> [String:String]?
    {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else {return nil}
        
        let url = URL(fileURLWithPath: path)

        let data = try! Data(contentsOf: url)

        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String] else {return nil}
        
        return plist
    }
    
    init () {
        self.env = getPlist(withName: "Env")
        self.apiUrl = URL(string: self.env!["API_URL"]!)!
        self.apiKey = self.env!["API_KEY"]!
        updateInput()
    }
    
    private mutating func updateInput () {
        let pasteboard = NSPasteboard.general
        let clipboardText = pasteboard.pasteboardItems?.first?.string(forType: .string)
        inputText = clipboardText != nil ? clipboardText! : ""
    }
    
    
    private func fetchApi(to value: UUID) async{
        
        

        loading = true
        guard let styleOption = styles.first(where: { $0.id == selectedStyle }) else {
            loading = false
            return
        }
        guard let mediumOption = mediums.first(where: { $0.id == selectedMedium }) else {
            loading = false
            return
        }
        guard let languageOption = languages.first(where: { $0.id == selectedLanguage }) else {
            loading = false
            return
        }
        
        status = StatusMessages.Loading.rawValue

        
        let reqBody = ParaphraseRequestBody(input: inputText!, style: styleOption.prompt, medium: mediumOption.prompt, langCode: languageOption.prompt)
                
        guard let encoded = try? JSONEncoder().encode(reqBody) else {
            print("Failed to encode order")
            loading = false
            return
        }
        
        var request = URLRequest(url: apiUrl!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey!, forHTTPHeaderField: "access_token")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decoded = try JSONDecoder().decode(ParaphraseResponseBody.self, from: data)
            
            versions = decoded.results
            
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(versions![0], forType: .string)
            loading = false
            status = StatusMessages.Copied.rawValue
        } catch {
            print("Request failed")
            loading = false
            return
        }
    }
    
    var body: some View {
        VStack {
            Button("Read Clipboard"){
//                updateInput()
            }
            RadioList(title: "Style", options: styles, selected: $selectedStyle.onChange(fetchApi))
            RadioList(title: "Medium", options: mediums, selected: $selectedMedium.onChange(fetchApi))
            RadioList(title: "Language", options: languages, selected: $selectedLanguage.onChange(fetchApi))
            ProgressView().opacity(loading ? 1 : 0)
            Text(status)
        }
        .padding()
        .frame(width: 500)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
