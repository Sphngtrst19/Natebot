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
        // Simulator: 127.0.0.1 works.
        // Physical iPhone: use your Mac's LAN IP (e.g., http://192.168.1.20:3000).
        let baseURL = URL(string: "http://127.0.0.1:3000")!
        let api = NatebotAPI(baseURL: baseURL)
        _vm = StateObject(wrappedValue: ChatViewModel(api: api))
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollViewReader { proxy in
                List(vm.messages) { msg in
                    HStack {
                        if msg.role == .assistant {
                            bubble(text: msg.content, isUser: false)
                            Spacer(minLength: 0)
                        } else {
                            Spacer(minLength: 0)
                            bubble(text: msg.content, isUser: true)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    .id(msg.id)
                }
                .listStyle(.plain)
                .onChange(of: vm.messages) { _, _ in
                    guard let last = vm.messages.last else { return }
                    // Avoid layout-timing issues that can trigger CoreGraphics NaN warnings
                    DispatchQueue.main.async {
                        proxy.scrollTo(last.id, anchor: .bottom)
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

            composer
        }
    }

    // MARK: - UI Pieces

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.headline)

            VStack(alignment: .leading, spacing: 2) {
                Text("Natebot")
                    .font(.headline)
                Text("Java + Oracle assistant (via local proxy)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if vm.isSending {
                ProgressView()
                    .scaleEffect(0.9)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Message Natebot…", text: $vm.draft, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)

            Button {
                Task { await vm.send() }
            } label: {
                Text("Send")
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isSending || vm.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private func bubble(text: String, isUser: Bool) -> some View {
        Text(text)
            .padding(10)
            .foregroundStyle(isUser ? .white : .primary)
            .background(isUser ? Color.blue : Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
