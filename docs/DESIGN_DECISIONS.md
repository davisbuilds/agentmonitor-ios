# AgentMonitor iOS — Design Decisions

Each decision is recorded with context, options considered, choice made, and rationale.

---

## DD-001: Native Swift vs Cross-Platform

**Context**: The existing web app uses Svelte 5. The Tauri desktop app embeds a Rust backend. We need an iOS companion.

**Options**:
1. React Native / Expo — reuse web knowledge
2. Flutter — cross-platform with single codebase
3. Native Swift/SwiftUI — platform-native
4. Kotlin Multiplatform — share logic with potential Android

**Decision**: Native Swift/SwiftUI

**Rationale**: The user base is Mac developers. SwiftUI gives us the best platform integration (widgets, Live Activities, Shortcuts in the future), the most natural iOS feel, and the smallest dependency footprint. The app is a thin API client — there's no complex business logic that benefits from cross-platform code sharing. SwiftUI + Swift concurrency is the most productive path for a single-platform app.

---

## DD-002: iOS 17+ Minimum Target

**Context**: Need to choose a minimum deployment target.

**Options**:
1. iOS 16 — wider compatibility, older SwiftUI APIs
2. iOS 17 — `@Observable`, mature SwiftData, SwiftCharts improvements
3. iOS 18 — newest APIs but excludes recent devices

**Decision**: iOS 17+

**Rationale**: iOS 17 introduced `@Observable` (replacing `ObservableObject`/`@Published` boilerplate), stabilized SwiftData, and improved SwiftCharts. The target audience (Mac developers) overwhelmingly runs current iOS versions. iOS 17+ covers 95%+ of active devices as of early 2026.

---

## DD-003: MVVM Architecture

**Context**: Need a clear separation between UI and data logic.

**Options**:
1. MVVM — ViewModels own state, Views bind to them
2. TCA (The Composable Architecture) — Redux-like, heavy
3. MV (Model-View) — lean, SwiftUI-native, no ViewModel layer
4. VIPER — enterprise-grade, excessive for this scope

**Decision**: MVVM with `@Observable`

**Rationale**: MVVM is the natural fit for SwiftUI apps with non-trivial state. `@Observable` eliminates the boilerplate that made MVVM verbose in earlier SwiftUI. TCA adds unnecessary complexity for a read-only client. Pure MV works for simple apps but monitoring dashboards have enough state management (SSE streams, filter combinations, pagination) that a ViewModel layer pays for itself.

---

## DD-004: No Shared Rust Code

**Context**: The agentmonitor project has a Rust backend. Could compile Rust for iOS and share code via FFI.

**Options**:
1. Share Rust core via UniFFI — type-safe FFI bindings
2. Share Rust core via C FFI — manual bridging
3. Clean Swift — no Rust dependency

**Decision**: Clean Swift, no Rust

**Rationale**: The iOS app is a REST/SSE client. The Rust backend handles server-side concerns (SQLite, file watching, OTEL parsing) that don't apply to a mobile client. Sharing Rust would mean cross-compiling for arm64-apple-ios, maintaining FFI bindings, and complicating the build. The only potentially shareable code is model types and API contracts — but Swift's Codable handles JSON mapping trivially. The complexity cost far exceeds the benefit.

---

## DD-005: URLSession for Networking (No Alamofire)

**Context**: Need HTTP client for REST and SSE.

**Options**:
1. URLSession — built-in, async/await native
2. Alamofire — popular, adds interceptors/retry
3. Moya — abstraction over Alamofire

**Decision**: URLSession directly

**Rationale**: Modern URLSession with async/await is clean and capable. The API surface is simple (GET endpoints + one SSE stream). We don't need Alamofire's interceptor chain, certificate pinning, or multipart uploads. Zero dependencies = faster builds, no version conflicts, no supply chain risk.

---

## DD-006: Custom SSE Client (No EventSource Library)

**Context**: Need to consume the server's SSE stream at `/api/stream`.

**Options**:
1. Use a third-party EventSource library (e.g., LDSwiftEventSource)
2. Build a minimal SSE parser on URLSession.bytes

**Decision**: Custom SSE client built on `URLSession.bytes(for:)`

**Rationale**: The SSE protocol is simple (text lines with `event:`, `data:`, `id:` prefixes). Our server emits three message types (`event`, `stats`, `session_update`). A custom implementation is ~100 lines, gives us full control over reconnection logic, and avoids a dependency for a trivial protocol. URLSession.bytes provides the async byte stream we need.

---

## DD-007: SwiftData for Caching (Not Core Data, Not SQLite)

**Context**: Want to cache previously viewed data for offline browsing.

**Options**:
1. SwiftData — modern, Swift-native ORM
2. Core Data — mature but verbose
3. Raw SQLite (via GRDB or SQLite.swift) — maximum control
4. UserDefaults / JSON files — simplest

**Decision**: SwiftData

**Rationale**: SwiftData integrates naturally with SwiftUI, requires minimal boilerplate, and handles schema migration. The cache is simple (sessions, messages, last stats snapshot) — we don't need GRDB's query builder power or Core Data's managed object contexts. SwiftData's `@Model` macro makes persistence nearly invisible.

---

## DD-008: Swift Charts for Analytics (No Third-Party Charts)

**Context**: Need to render daily activity charts, breakdowns, and gauges.

**Options**:
1. Swift Charts — Apple's built-in charting framework
2. Charts (danielgindi) — popular, feature-rich, UIKit-based
3. Custom drawing — full control

**Decision**: Swift Charts

**Rationale**: Swift Charts integrates with SwiftUI, supports the chart types we need (bar, line, pie/donut for breakdowns), and is maintained by Apple. The analytics views are straightforward — daily activity line charts, project bar charts, tool pie charts. No need for exotic visualizations that would require a third-party library.

---

## DD-009: Bonjour/mDNS for Server Discovery

**Context**: Users run agentmonitor on their Mac and connect from iPhone/iPad on the same network.

**Options**:
1. Manual URL entry only
2. Bonjour (mDNS/DNS-SD) automatic discovery
3. QR code pairing

**Decision**: Bonjour discovery + manual URL entry as fallback

**Rationale**: The agentmonitor server can advertise itself via Bonjour (requires a small server-side addition). The iOS app discovers it automatically on the LAN — zero configuration for the common case. Manual URL entry covers edge cases (remote servers, VPN, non-standard ports). This is the same pattern used by apps like Home Assistant, Plex, and Synology.

---

## DD-010: Read-Only Client

**Context**: The web dashboard is read-only (no write APIs for end users). Should the iOS app add write capabilities?

**Decision**: Read-only, matching the web app

**Rationale**: The agentmonitor server's API is designed for ingestion from hooks and querying from dashboards. There's no user-facing write path (you don't manually create events or sessions). The iOS app mirrors the dashboard — it observes, it doesn't control. This simplifies the app significantly and matches the server's security model (no auth on read endpoints, which is fine for localhost).

---

## DD-011: Tab-Based Navigation

**Context**: The Svelte app has four tabs: Monitor, Sessions, Analytics, Search.

**Options**:
1. TabView — direct mirror of the web app
2. Sidebar navigation (iPad) + TabView (iPhone)
3. Single scrollable dashboard

**Decision**: TabView on iPhone, adaptive sidebar on iPad

**Rationale**: Four distinct sections map naturally to tabs. On iPad, the extra screen space warrants a sidebar for navigation with a detail area. SwiftUI's `TabView` with `.tabViewStyle` and size-class adaptivity handles this cleanly. The Settings screen is accessible from a gear icon in the navigation bar (not a fifth tab) to keep the tab bar focused on core functionality.

---

## DD-012: Dark Mode Default

**Context**: This is a developer tool for monitoring AI agents.

**Decision**: Dark mode by default, with system appearance override in settings

**Rationale**: Developer tools conventionally use dark themes. The agentmonitor web dashboard uses a dark color scheme. Dark mode reduces eye strain during long monitoring sessions and matches the terminal-centric workflow of the target users. Users can override to follow system appearance in settings.

---

## DD-013: No Push Notifications (Phase 1)

**Context**: Could notify users of usage limit warnings, session starts, errors.

**Decision**: Defer notifications to a future phase

**Rationale**: Push notifications require server-side infrastructure (APNs integration) that doesn't exist. Local notifications triggered by SSE events are possible but the app needs to be foregrounded for SSE to work (no background execution for long-lived streams). This is a companion monitoring app — users look at it when they want to check status, not as a primary alert channel.

---

## DD-014: Universal App (iPhone + iPad)

**Context**: Target audience is Mac developers who likely own both devices.

**Decision**: Universal app with adaptive layouts

**Rationale**: SwiftUI's adaptive layout system makes universal apps straightforward. iPad gets a sidebar navigation and wider layouts. iPhone gets compact tab-based navigation. The cost of supporting both is minimal with SwiftUI, and it maximizes the app's utility.
