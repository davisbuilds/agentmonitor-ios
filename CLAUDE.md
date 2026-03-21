# AgentMonitor iOS

## Overview
Native iOS companion app for [AgentMonitor](../agentmonitor), providing real-time monitoring of AI agent activity (Claude Code, Codex) from iPhone and iPad.

## Tech Stack
- **Language**: Swift 6
- **UI**: SwiftUI (iOS 18+)
- **Architecture**: MVVM with `@Observable`
- **Networking**: URLSession (no third-party dependencies)
- **Persistence**: SwiftData (cache layer)
- **Charts**: Swift Charts
- **Concurrency**: Swift structured concurrency (async/await, actors)
- **Discovery**: Network framework (Bonjour/mDNS)

## Project Structure
```
AgentMonitor/
├── App/           # @main entry point, ContentView, tab routing
├── Models/        # Codable structs matching server JSON contracts
├── Services/      # APIClient, SSEClient, ServerConnection, Discovery
├── ViewModels/    # @Observable classes per screen
├── Views/         # SwiftUI views organized by tab
└── Utilities/     # Formatters, constants, extensions
```

## Key Conventions
- Models are pure Swift (no SwiftUI imports), Codable + Sendable
- ViewModels are `@Observable @MainActor` classes
- Server JSON uses snake_case; decoder uses `.convertFromSnakeCase`
- Enum types handle unknown server values via `.unknown(String)` cases
- No third-party dependencies — everything built on Apple frameworks

## Building
Open `AgentMonitor.xcodeproj` in Xcode 16+ or build from CLI:
```bash
xcodegen generate                    # regenerate project from project.yml
xcodebuild build -scheme AgentMonitor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test  -scheme AgentMonitor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

The Xcode project is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen). Regenerate after adding/removing files.

## Server Connection
The app connects to an agentmonitor server (default `http://127.0.0.1:3141`). The server must be running for the app to function. See the agentmonitor project for server setup.

## Documentation
- `docs/ARCHITECTURE.md` — System design and module map
- `docs/PLAN.md` — Phased implementation plan
- `docs/DESIGN_DECISIONS.md` — Rationale for every major technical choice
- `docs/TEST_STRATEGY.md` — Testing approach by layer
- `docs/API_CONTRACT.md` — Server API reference
