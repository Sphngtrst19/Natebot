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

    private let api: NatebotAPI

    // How many prior messages to send (keeps prompts small and fast)
    private let historyLimit = 12

    init(api: NatebotAPI) {
        self.api = api
    }

    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        errorText = nil
        isSending = true
        draft = ""

        // Append user message locally first (so it appears instantly)
        messages.append(Message(role: .user, content: text))

        do {
            let history = makeHistory(limit: historyLimit)
            let reply = try await api.send(message: text, history: history)

            messages.append(Message(role: .assistant, content: reply.isEmpty ? "(No response returned)" : reply))
        } catch {
            errorText = error.localizedDescription
            messages.append(Message(role: .assistant, content: "Sorry — I hit an error talking to the server."))
        }

        isSending = false
    }

    /// Builds history items from the most recent messages, excluding the brand-new user message if you prefer.
    /// Here we include recent context (including the last assistant replies), but you can tune this.
    private func makeHistory(limit: Int) -> [NatebotAPI.ChatHistoryItem] {
        // Take the last N messages BEFORE the newest one if you want; but since we already appended
        // the user message, we can send the history excluding the last item to avoid duplication.
        // We'll exclude the last message because `message:` already contains it.
        let recent = messages.dropLast().suffix(limit)

        return recent.map { msg in
            NatebotAPI.ChatHistoryItem(
                role: msg.role == .assistant ? "assistant" : "user",
                content: msg.content
            )
        }
    }
}
