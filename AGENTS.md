# AGENTS.md

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
```

The Xcode project is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen). Regenerate after adding/removing files.

## Testing

- **Run tests**: `xcodebuild test -scheme AgentMonitor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` (or Cmd+U). The `AgentMonitorTests` target is declared in `project.yml`; regenerate with `xcodegen generate` after adding test files.
- **Framework is Swift Testing** (`@Test`, `#expect`), not XCTest — match the existing style in `AgentMonitorTests/` rather than importing XCTest.
- **TDD**: red/green for new features, major refactors, and large changes. The red step must fail for the behavior you're about to fix — a test that fails only because the symbol doesn't exist yet is a stub, not a red test; write the signature first, then a test that fails on the behavior. Skip the red step for code with no behavior to assert, and cover it after — but note a `Codable` model doesn't qualify: decoding is the contract against the server, and that's what every existing test here asserts. For smaller edits, still run the relevant existing tests before wrapping up.
- **Coverage is thin**: `ModelDecodingTests.swift` is the only test file (6 tests over decoding and unknown-enum handling). `docs/TEST_STRATEGY.md` describes the intended pyramid — treat it as the target, not what exists. Services and ViewModels are untested; that's where TDD earns the most. See `docs/project/BACKLOG.md`.

## Server Connection
The app connects to an agentmonitor server (default `http://127.0.0.1:3141`). The server must be running for the app to function. See the agentmonitor project for server setup.

## Documentation
- `docs/ARCHITECTURE.md` — System design and module map
- `docs/DESIGN_DECISIONS.md` — Rationale for every major technical choice
- `docs/TEST_STRATEGY.md` — Intended testing approach by layer (target state; current coverage is model-decoding only)
- `docs/API_CONTRACT.md` — Server API reference
- `docs/project/GIT_HISTORY_POLICY.md` — Merge strategy and branch hygiene

The completed build plan is archived at `docs/archive/plans/PLAN.md` (local-only; `**/archive/` is gitignored).

## Working Agreement

- **Push back before building.** If a request is incoherent or self-contradictory, or a spec/plan is vague or skips key decisions, stop and interview me — ask clarifying questions and confirm intent before writing code or changing files. Don't guess at scope or comply silently. (Clear, well-scoped requests don't need this.)
- **Keep docs current.** After a significant change, PR, or completed spec/plan, update any now-stale reference docs under `docs/` so they match shipped behavior. Skip this for trivial changes.
- **Commit logically.** Commit completed work in coherent chunks as you proceed. Push only when explicitly asked.
- **Log findings in `BACKLOG.md`.** Note design gaps, tech debt, or better approaches you spot mid-task in `docs/project/BACKLOG.md`; fix simple/quick ones inline and call them out.
- **Re-ground after compaction.** A compaction summary loses precise paths, context, and verification state — before continuing, re-read this project's `AGENTS.md`, its reference docs, and recent commits.
