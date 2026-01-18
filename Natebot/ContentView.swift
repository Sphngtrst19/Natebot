//
//  ContentView.swift
//  Natebot
//
//  Created by Nate on 1/15/26.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var vm: ChatViewModel

    init() {
        // ⚠️ DEMO ONLY:
        // Put your API key here temporarily while learning.
        // For real apps, use a backend so the key never ships to users.
        let key = "OPENAI_API_KEY_HERE"
        _vm = StateObject(wrappedValue: ChatViewModel(client: OpenAIClient(apiKey: key)))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List(vm.messages) { msg in
                    HStack {
                        if msg.role == .assistant {
                            bubble(text: msg.content, isUser: false)
                            Spacer()
                        } else {
                            Spacer()
                            bubble(text: msg.content, isUser: true)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    .id(msg.id)
                }
                .listStyle(.plain)
                .onChange(of: vm.messages) { _, _ in
                    if let last = vm.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            if let err = vm.errorText {
                Text(err)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
                    .padding(.top, 6)
            }

            HStack(spacing: 10) {
                TextField("Message Natebot…", text: $vm.draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                Button {
                    Task { await vm.send() }
                } label: {
                    if vm.isSending {
                        ProgressView().scaleEffect(0.9)
                    } else {
                        Text("Send")
                    }
                }
                .disabled(vm.isSending || vm.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }

    private func bubble(text: String, isUser: Bool) -> some View {
        Text(text)
            .padding(10)
            .foregroundStyle(isUser ? .white : .primary)
            .background(isUser ? Color.blue : Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
