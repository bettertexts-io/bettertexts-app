//
//  ContentView.swift
//  ui
//
//  Created by Leo Grützner on 25.01.23.
//

import SwiftUI

struct ParaphraseRequestBody: Codable {
    var input: String
    var style: String
    var medium: String
}

struct ParaphraseResponseBody: Codable {
    var status: Int
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
private let media = [
    PromptOption(title: "Bulletpoints", prompt: "bulletpoints"),
    PromptOption(title: "Tweet", prompt: "tweet no longer than 256 characters"),
    PromptOption(title: "E-Mail", prompt: "E-Mail with greeting and ending"),
    PromptOption(title: "Essay", prompt: "essay with introduction, main part and ending")
]

struct RadioList: View{
    public var title: String
    public var options: [PromptOption]
    @State public var selected: UUID
    
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
    @State private var selectedStyle = UUID()
    @State private var selectedMedium = UUID()
    @State private var versions: [String] = ["version a", "version b"]
    
    private func fetchApi() async -> [String]{
        print("fetchApi()")
        let apiUrl = URL(string: "https://api.bettertexts.io/api/v1/paraphrase")!
        
        print(selectedStyle)
        print(styles[0].id)
        print(styles.first(where: { $0.id == selectedStyle })?.title)
        
        let reqBody = ParaphraseRequestBody(input: "test", style: "Test", medium: "hee")
        
        guard let encoded = try? JSONEncoder().encode(reqBody) else {
            print("Failed to encode order")
            return []
        }
        
        var request = URLRequest(url: apiUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decoded = try JSONDecoder().decode(ParaphraseResponseBody.self, from: data)
            print(decoded.results[0])
            return decoded.results
        } catch {
            print("Request failed")
            return []
        }
        
    }
    
    var body: some View {
        VStack {
            Text("text → bettertexts")
                .font(.system(size: 20, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(10)
            RadioList(title: "Style", options: styles, selected: selectedStyle)
            RadioList(title: "Medium", options: media, selected: selectedMedium)
            Button("Fetch"){
                print("tapped")
                Task {
                    versions = await fetchApi()
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
