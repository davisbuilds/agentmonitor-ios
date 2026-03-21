# AgentMonitor iOS — Architecture

## Overview

AgentMonitor iOS is a native Swift companion app for the [AgentMonitor](../README.md) server. It connects to a running agentmonitor instance over HTTP/SSE and provides real-time monitoring, session browsing, analytics, and search — mirroring the Svelte 5 web dashboard.

## System Context

```
┌──────────────────────┐       HTTP/SSE        ┌──────────────────────┐
│   AgentMonitor iOS   │ ◄──────────────────── │  agentmonitor server │
│   (Swift / SwiftUI)  │    LAN or localhost    │  (Node/Rust :3141)   │
└──────────────────────┘                        └──────────────────────┘
         │                                                │
         │ SwiftData                              SQLite + SSE
         │ (local cache)                          (source of truth)
         ▼
   ┌────────────┐
   │  On-Device  │
   │   Cache DB  │
   └────────────┘
```

The iOS app is a **read-only client**. All data originates from the agentmonitor server. The app never writes to the server's database — it only reads via the existing REST API and SSE stream.

## Architecture Pattern: MVVM + Services

```
┌─────────────────────────────────────────────────────┐
│                      Views (SwiftUI)                 │
│  MonitorView · SessionsView · AnalyticsView · ...    │
└────────────────────────┬────────────────────────────┘
                         │ @Observable
┌────────────────────────▼────────────────────────────┐
│                    ViewModels                        │
│  MonitorVM · SessionsVM · AnalyticsVM · SearchVM     │
└────────────────────────┬────────────────────────────┘
                         │ async/await
┌────────────────────────▼────────────────────────────┐
│                     Services                         │
│  APIClient · SSEClient · CacheService · ServerDiscovery │
└────────────────────────┬────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────┐
│                   Foundation                         │
│  Models · Networking · Persistence · Config          │
└─────────────────────────────────────────────────────┘
```

### Layer Responsibilities

**Views** — Pure SwiftUI. No business logic. Bind to ViewModel `@Observable` properties. Trigger ViewModel actions via method calls.

**ViewModels** — `@Observable` classes. Own the screen state. Call services, transform API responses into view-ready data. Handle loading/error/empty states.

**Services** — Stateless (or lightly stateful for connections). `APIClient` wraps URLSession for REST calls. `SSEClient` manages the persistent SSE connection. `CacheService` wraps SwiftData for offline access. `ServerDiscovery` uses Bonjour/mDNS.

**Foundation** — Pure Swift types: `AgentEvent`, `Session`, `Stats`, etc. Codable structs matching the server's JSON contracts. No UIKit/SwiftUI imports.

## Module Map

```
AgentMonitor/
├── App/
│   ├── AgentMonitorApp.swift          # @main, WindowGroup, dependency wiring
│   └── ContentView.swift              # Root TabView
│
├── Models/                            # Pure Swift, Codable
│   ├── AgentEvent.swift
│   ├── Session.swift
│   ├── Stats.swift
│   ├── CostBreakdown.swift
│   ├── ToolAnalytics.swift
│   ├── UsageMonitor.swift
│   ├── BrowsingSession.swift
│   ├── Message.swift
│   ├── ToolCall.swift
│   ├── SearchResult.swift
│   ├── AnalyticsSummary.swift
│   └── FilterOptions.swift
│
├── Services/
│   ├── Networking/
│   │   ├── APIClient.swift            # URLSession wrapper, typed endpoints
│   │   ├── APIEndpoint.swift          # Endpoint definitions (path, method, query)
│   │   ├── SSEClient.swift            # EventSource impl with auto-reconnect
│   │   └── SSEMessage.swift           # Parsed SSE message types
│   ├── Cache/
│   │   ├── CacheService.swift         # SwiftData read/write
│   │   └── CachedModels.swift         # @Model versions for persistence
│   ├── Discovery/
│   │   └── ServerDiscovery.swift      # Bonjour/mDNS server finder
│   └── ServerConnection.swift         # Connection state machine
│
├── ViewModels/
│   ├── MonitorViewModel.swift         # Dashboard: cards, stats, feed, usage
│   ├── SessionsViewModel.swift        # Session browser + message viewer
│   ├── AnalyticsViewModel.swift       # Charts and breakdowns
│   ├── SearchViewModel.swift          # FTS search
│   ├── SessionDetailViewModel.swift   # Single session deep dive
│   └── SettingsViewModel.swift        # Server config, connection management
│
├── Views/
│   ├── Monitor/
│   │   ├── MonitorView.swift          # Main dashboard tab
│   │   ├── StatsBarView.swift         # Top-level counters
│   │   ├── AgentCardView.swift        # Per-session card
│   │   ├── EventFeedView.swift        # Live event list
│   │   ├── CostDashboardView.swift    # Cost breakdowns
│   │   ├── ToolAnalyticsView.swift    # Tool usage charts
│   │   └── UsageMonitorView.swift     # Token/cost limit gauges
│   ├── Sessions/
│   │   ├── SessionsView.swift         # Session list with filters
│   │   ├── SessionDetailView.swift    # Session timeline + messages
│   │   └── MessageBlockView.swift     # Single message renderer
│   ├── Analytics/
│   │   ├── AnalyticsView.swift        # Charts tab
│   │   ├── ActivityChartView.swift    # Daily activity (Swift Charts)
│   │   ├── ProjectBreakdownView.swift
│   │   └── ToolBreakdownView.swift
│   ├── Search/
│   │   ├── SearchView.swift           # Search tab
│   │   └── SearchResultView.swift     # Result with snippet highlight
│   ├── Settings/
│   │   ├── SettingsView.swift         # Server URL, discovery, connection
│   │   └── ServerPickerView.swift     # Bonjour discovered servers
│   └── Shared/
│       ├── ConnectionStatusView.swift # Reusable connection indicator
│       ├── FilterBarView.swift        # Reusable filter chips
│       ├── EmptyStateView.swift
│       ├── ErrorStateView.swift
│       └── LoadingStateView.swift
│
├── Utilities/
│   ├── Formatters.swift               # Date, cost, token formatters
│   ├── Constants.swift                # App-wide constants
│   └── Extensions/
│       ├── Color+Theme.swift          # Color palette
│       ├── Date+Relative.swift
│       └── String+Truncate.swift
│
└── Resources/
    ├── Assets.xcassets
    └── Preview Content/
```

## Data Flow

### Real-Time Updates (SSE)

```
Server SSE (/api/stream)
    │
    ▼
SSEClient (URLSession bytes stream)
    │ AsyncSequence<SSEMessage>
    ▼
MonitorViewModel
    │ updates @Observable properties
    ▼
SwiftUI Views (automatic re-render)
```

The SSE client emits an `AsyncSequence` of parsed messages. The MonitorViewModel consumes this sequence in a long-running `Task`, updating its published properties as events arrive. SwiftUI's observation system handles the rest.

### REST API Calls

```
User action (pull-to-refresh, tab switch, filter change)
    │
    ▼
ViewModel calls Service method
    │ async throws
    ▼
APIClient.fetch(endpoint)
    │ URLSession.data(for:)
    ▼
JSON → Codable model
    │
    ▼
ViewModel updates @Observable state
    │ optionally writes to CacheService
    ▼
SwiftUI re-renders
```

### Offline Cache

```
On fetch success:
    APIClient → ViewModel → CacheService.save(sessions)

On fetch failure (no network):
    ViewModel → CacheService.load() → stale data + "offline" banner
```

SwiftData stores the last-fetched sessions, messages, and stats snapshot. This is a **read cache**, not a sync engine — no conflict resolution needed.

## Concurrency Model

- All networking is `async/await` via URLSession
- SSE uses `URLSession.bytes(for:)` producing an `AsyncBytes` sequence
- ViewModels use `@Observable` (not Combine) — observation is compiler-synthesized
- Long-running SSE consumption runs in a detached `Task` owned by the ViewModel
- Task cancellation on view disappear prevents leaked connections
- `@MainActor` on ViewModels ensures UI-bound state updates are safe

## Server Connection State Machine

```
         ┌──────────┐
         │ disconnected │◄──── user taps disconnect
         └─────┬────┘        or server unreachable
               │ user enters URL / selects from discovery
               ▼
         ┌──────────┐
         │ connecting │──── GET /api/health
         └─────┬────┘
               │ health OK
               ▼
         ┌──────────┐
         │ connected  │──── SSE stream active
         └─────┬────┘
               │ SSE drops / health fails
               ▼
         ┌──────────────┐
         │ reconnecting  │──── exponential backoff (1s, 2s, 4s, 8s, max 30s)
         └──────────────┘
```

## Key Technical Decisions

See [DESIGN_DECISIONS.md](./DESIGN_DECISIONS.md) for rationale on every major choice.
