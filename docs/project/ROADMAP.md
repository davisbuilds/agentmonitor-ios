# AgentMonitor iOS Roadmap

## Current Direction

AgentMonitor iOS is a native, read-only SwiftUI companion for the local
AgentMonitor server. It brings real-time monitoring, session browsing, analytics,
and search to iPhone, iPad, and Mac while keeping the server as the source of truth.

## Shipped Foundation

- **Native client surface** — SwiftUI views and MVVM view models cover live Monitor,
  Sessions, Analytics, Search, and Settings experiences against the server's REST and
  SSE APIs.
- **Platform-native runtime** — Swift concurrency, URLSession, SwiftData caching, and
  Bonjour discovery keep the client dependency-free and suited to local/LAN use.
- **Universal target** — the project supports iPhone, iPad, and Mac with adaptive
  SwiftUI navigation.
- **Documented contracts** — architecture, API contracts, design decisions, and a
  target-state testing strategy are maintained under `docs/`.

## Next Durable Follow-up

- **Make the testing strategy real** — service and view-model coverage is the first
  durable follow-up; see [BACKLOG.md](BACKLOG.md) for the evidence and recommended
  starting slice. The roadmap deliberately does not duplicate its implementation detail.

## Product Boundaries

- The app observes AgentMonitor data; it does not write to the server database or add a
  user-facing control plane.
- The server remains the canonical source of truth. SwiftData is a read cache, not a
  synchronization engine.
- Push notifications remain deferred until there is an appropriate server-side alerting
  contract.

Completed work is recorded here; future friction and deferred follow-ups belong in
[BACKLOG.md](BACKLOG.md).
