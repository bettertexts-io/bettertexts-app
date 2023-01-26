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

struct RadioList: View{
    public var title: String
    public var options: [PromptOption]
    @Binding public var selected: UUID
    
    public var body: some View {
        Picker(selection: $selected, label: Text(title)) {
            ForEach(options) { option in
                Text(option.title).tag(option.id)
            }
        }
        .pickerStyle(.radioGroup)
        .horizontalRadioGroupLayout()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

struct ContentView: View {
    private var env: [String: String]?
    private var apiUrl: URL?
    private var apiKey: String?
    @State private var selectedStyle = UUID()
    @State private var selectedMedium = UUID()
    @State private var inputText = "Doinik bro ihc muss dich leider entlassen, sorry"
    @State private var versions: [String] = ["version a", "version b"]
    
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
    }
    
    private func fetchApi() async -> [String]?{
        let styleOption = styles.first(where: { $0.id == selectedStyle })
        let mediumOption = mediums.first(where: { $0.id == selectedMedium })
        
        let reqBody = ParaphraseRequestBody(input: inputText, style: styleOption!.prompt, medium: mediumOption!.prompt)
                
        guard let encoded = try? JSONEncoder().encode(reqBody) else {
            print("Failed to encode order")
            return nil
        }
        
        var request = URLRequest(url: apiUrl!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey!, forHTTPHeaderField: "access_token")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decoded = try JSONDecoder().decode(ParaphraseResponseBody.self, from: data)
            return decoded.results
        } catch {
            print("Request failed")
            return nil
        }
        
    }
    
    var body: some View {
        VStack {
            Text("text → bettertexts")
                .font(.system(size: 20, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(10)
            
            TextField("Input Text", text: $inputText)
            
            RadioList(title: "Style", options: styles, selected: $selectedStyle)
            RadioList(title: "Medium", options: mediums, selected: $selectedMedium)
            Button("Fetch"){
                print("tapped")
                Task {
                    guard let ret = await fetchApi() else {
                        print("invalid versions[]")
                        return
                    }
                    versions = ret
                    print(versions)
                }
            }
            Text(versions[0])
               .onTapGesture {
                   
               }
               .frame(maxWidth: .infinity, alignment: .leading)
            Text(versions[1])
               .onTapGesture {
                   print("tapped")
               }
               .frame(maxWidth: .infinity, alignment: .leading)
            
            
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
