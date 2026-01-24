# Natebot
chat bot prototype

A SwiftUI chat application backed by a local LLM proxy (Ollama)

Natebot is a SwiftUI-based iOS chat application designed to interact with a locally hosted large language model (LLM) via a lightweight Node.js proxy server. The architecture cleanly separates the mobile client from the model runtime, ensuring no API keys or secrets are embedded in the iOS app.

This project is intended as a learning and experimentation platform for:

SwiftUI + MVVM architecture

Local LLM integration

Secure client–server separation

AI-assisted coding workflows (Java / Oracle focus)

Architecture Overview
┌──────────────────┐        HTTP        ┌────────────────────────┐
│  iOS App (Swift) │ ───────────────▶ │ Node.js Proxy Server     │
│  SwiftUI + MVVM  │                  │ Express + Ollama API     │
└──────────────────┘                  └───────────┬────────────┘
                                                   │
                                                   ▼
                                         ┌──────────────────────┐
                                         │ Ollama Local LLM      │
                                         │ (qwen2.5-coder:7b)   │
                                         └──────────────────────┘


The iOS app communicates only over HTTP.

The Node proxy handles all LLM interaction.

Ollama runs the local model and performs inference.

No secrets or model logic ship inside the mobile app.

Directory Layout
Natebot/
├── Natebot/                    ← SwiftUI app source code
│   ├── ContentView.swift
│   ├── ViewModels/
│   ├── Networking/
│   └── Assets.xcassets
│
├── Natebot.xcodeproj           ← Xcode project
│
└── (outside this repo)
    └── Natebot-server/
        └── natebot-proxy/      ← Node.js proxy (runs locally)
            ├── server.js
            ├── package.json
            ├── node_modules/
            └── .env


⚠️ Important:
The server/ / natebot-proxy/ directory must NOT be added to the Xcode project.
The iOS app communicates with it only via HTTP.

Requirements
iOS App

macOS with Xcode

iOS Simulator (recommended for local development)

Swift 5.9+

Backend / LLM

Node.js (Node 18+ recommended)

npm

Ollama installed and running
https://ollama.com

Setting Up the Local Proxy Server
1️⃣ Install and start Ollama
ollama run qwen2.5-coder:7b


Leave Ollama running in the background.

2️⃣ Set up the proxy server
cd Natebot-server/natebot-proxy
npm install


Create a .env file:

PORT=3000
OLLAMA_URL=http://localhost:11434/api/chat
OLLAMA_MODEL=qwen2.5-coder:7b
NATEBOT_SYSTEM_PROMPT=You are Natebot, a Java and Oracle coding assistant.


Start the server:

node server.js


Verify it’s running:

curl http://localhost:3000/health


Expected response:

{
  "ok": true,
  "name": "natebot-proxy",
  "provider": "ollama",
  "model": "qwen2.5-coder:7b"
}

Running the iOS App
Simulator

Open Natebot.xcodeproj in Xcode

Ensure the proxy server is running

Run the app in the iOS Simulator


The app connects to:

http://127.0.0.1:3000



Physical iPhone

If running on a real device, update the base URL in ContentView.swift to your Mac’s LAN IP:

let baseURL = URL(string: "http://192.168.X.Y:3000")!


Your iPhone and Mac must be on the same network.

Git & Security Notes

node_modules/ and .env are not committed

Xcode user state (xcuserdata, .DS_Store) is ignored

No API keys or secrets are embedded in the app

Backend code lives outside the iOS project to avoid accidental bundling




Current Capabilities:

SwiftUI chat interface with auto-scroll

Conversation history support

Local LLM inference (offline-capable)

Coding-focused assistant behavior (Java / Oracle)





Future Improvements (Planned):

Replace List with ScrollView + LazyVStack for improved chat stability

Model switching / routing

Streaming responses

Deployment-ready proxy (Docker)

Fine-tuned custom model



License:

This project is for educational and experimental purposes.
