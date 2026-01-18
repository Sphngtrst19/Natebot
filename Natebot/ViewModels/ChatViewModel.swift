//
//  ChatViewModel.swift
//  Natebot
//
//  Created by Nate on 1/15/26.
//


import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(role: .assistant, content: "Hi! I’m Natebot 🤖 — how can I help you today?")
    ]
    @Published var draft: String = ""
    @Published var isSending = false
    @Published var errorText: String?

    private let client: OpenAIClient

    init(client: OpenAIClient) {
        self.client = client
    }

    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        errorText = nil
        isSending = true
        draft = ""

        messages.append(Message(role: .user, content: text))

        do {
            let reply = try await client.send(userText: text)
            messages.append(Message(role: .assistant, content: reply.isEmpty ? "(No response text returned)" : reply))
        } catch {
            errorText = error.localizedDescription
            messages.append(Message(role: .assistant, content: "Sorry—there was an error."))
        }

        isSending = false
    }
}
