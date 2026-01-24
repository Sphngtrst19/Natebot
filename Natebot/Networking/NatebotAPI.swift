//
//  NatebotAPI.swift
//  Natebot
//
//  Created by Nate on 1/18/26.
//

import Foundation

final class NatebotAPI {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    struct ChatHistoryItem: Encodable {
        let role: String   // "user" or "assistant"
        let content: String
    }

    struct ChatRequest: Encodable {
        let message: String
        let history: [ChatHistoryItem]
    }

    struct ChatResponse: Decodable {
        let reply: String
    }

    func send(message: String, history: [ChatHistoryItem]) async throws -> String {
        var req = URLRequest(url: baseURL.appendingPathComponent("chat"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        req.httpBody = try JSONEncoder().encode(ChatRequest(message: message, history: history))

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            let text = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "NatebotAPI", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: text])
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decoded.reply
    }
}
