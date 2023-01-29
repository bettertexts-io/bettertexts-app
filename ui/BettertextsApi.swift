//
//  bettertextsApi.swift
//  ui
//
//  Created by Leo Grützner on 28.01.23.
//

import Foundation

struct ParaphraseRequestBody: Codable {
    var input: String
    var style: String
    var medium: String
    var langCode: String
}

struct ParaphraseResponseBody: Codable {
    var results: [String]
}


class BettertextsApi {
    private var apiUrl: URL
    private var apiKey: String
    public static var shared = BettertextsApi()
    
    init(){
        self.apiUrl = URL(string: Env.shared.getValue(for: "API_URL"))!
        self.apiKey = Env.shared.getValue(for: "API_KEY")
    }
    
    public func getParaphrase(originalText: String, style: String, medium: String, langCode: String) async -> String? {
        let reqBody = ParaphraseRequestBody(input: originalText, style: style, medium: medium, langCode: langCode)

        guard let encoded = try? JSONEncoder().encode(reqBody) else {
            print("Failed to encode order")
            return nil
        }

        var request = URLRequest(url: apiUrl)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "access_token")
        request.httpMethod = "POST"

        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decoded = try JSONDecoder().decode(ParaphraseResponseBody.self, from: data)

            let results = decoded.results as [String]
            
            return results[0]
        } catch {
            print("Request failed")
            return nil
        }
    }
}


