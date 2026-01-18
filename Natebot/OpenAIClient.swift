//
//  OpenAIClient.swift
//  Natebot
//
//  Created by Nate on 1/15/26.
//


import Foundation

final class OpenAIClient {
    // ⚠️ DEMO ONLY. Do NOT ship API keys in an iOS app.
    // Recommended approach: call your own backend that holds the key.
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    struct ResponsesRequest: Encodable {
        let model: String
        let instructions: String?
        let input: String
    }

    struct ResponsesResponse: Decodable {
        struct OutputItem: Decodable {
            struct ContentItem: Decodable {
                let type: String
                let text: String?
            }
            let content: [ContentItem]?
        }
        let output: [OutputItem]?
    }

    func send(userText: String,
              systemInstructions: String? = "You are Natebot, a friendly and helpful AI assistant.") async throws -> String {
        var req = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body = ResponsesRequest(
            model: "gpt-5",
            instructions: systemInstructions,
            input: userText
        )
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            let text = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "OpenAIClient", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: text])
        }

        let decoded = try JSONDecoder().decode(ResponsesResponse.self, from: data)

        // Pull out text from the response
        let texts = decoded.output?
            .compactMap { $0.content }
            .flatMap { $0 }
            .compactMap { $0.text } ?? []

        return texts.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
