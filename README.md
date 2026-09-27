# AgentMonitor iOS

A native SwiftUI companion for [AgentMonitor](https://github.com/davisbuilds/agentmonitor).
It reads the server's monitoring, session, analytics, and search data on iPhone,
iPad, and Mac. The server owns the data; SwiftData is a local read cache. The app
does not write to the server database or provide a control plane.

Run the AgentMonitor server first. The client defaults to
`http://127.0.0.1:3141`; configure a reachable server address in Settings when
the client runs on another device. The targets need iOS 18 or macOS 15. Generate
the Xcode project with [XcodeGen](https://github.com/yonaskolb/XcodeGen), then
open `AgentMonitor.xcodeproj` in Xcode 16 or newer:

```bash
xcodegen generate
xcodebuild build -scheme AgentMonitor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme AgentMonitor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

The iOS tests currently cover model decoding; the broader testing approach in
[`docs/TEST_STRATEGY.md`](docs/TEST_STRATEGY.md) is a target, not existing
coverage. See [architecture](docs/ARCHITECTURE.md), the
[client API reference](docs/API_CONTRACT.md),
[current direction](docs/project/ROADMAP.md), and
[future work](docs/project/BACKLOG.md). For changes, read
[CONTRIBUTING.md](CONTRIBUTING.md); [AGENTS.md](AGENTS.md) has agent guidance.
