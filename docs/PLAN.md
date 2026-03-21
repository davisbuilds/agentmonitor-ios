# AgentMonitor iOS — Phased Implementation Plan

## Phase 0: Project Scaffolding ✅
**Goal**: Xcode project structure, models, and documentation in place.

- [x] Create planning documents (architecture, design decisions, test strategy)
- [x] Scaffold directory structure matching architecture spec
- [x] Define all Codable model types (matching server JSON contracts)
- [x] Create placeholder files for all layers
- [x] Git init + initial commit

---

## Phase 1: Networking Foundation
**Goal**: Connect to the server and fetch data. No UI beyond a debug console.

### 1a. APIClient
- [ ] `APIClient` with configurable base URL
- [ ] Typed endpoint definitions for all V1 and V2 routes
- [ ] Generic `fetch<T: Decodable>` method with error handling
- [ ] Query parameter encoding for filters
- [ ] Request/response logging in DEBUG builds
- [ ] Unit tests with mock URLProtocol

### 1b. SSE Client
- [ ] `SSEClient` built on `URLSession.bytes(for:)`
- [ ] Line-based SSE parser (event, data, id, retry fields)
- [ ] `AsyncSequence` emission of typed `SSEMessage` values
- [ ] Auto-reconnect with exponential backoff (1s → 30s cap)
- [ ] Connection state tracking (disconnected/connecting/connected/reconnecting)
- [ ] Heartbeat timeout detection (server sends keepalive every 30s)
- [ ] Unit tests for SSE parsing

### 1c. Server Connection Manager
- [ ] `ServerConnection` state machine (disconnected → connecting → connected → reconnecting)
- [ ] Health check via `GET /api/health`
- [ ] Persist last-used server URL in UserDefaults
- [ ] Bonjour/mDNS discovery of `_agentmonitor._tcp` services

**Exit criteria**: Can fetch `/api/stats`, `/api/sessions`, and consume `/api/stream` from Swift playground or test harness.

---

## Phase 2: Monitor Dashboard
**Goal**: Live dashboard matching the Svelte Monitor tab.

### 2a. Stats Bar
- [ ] `MonitorViewModel` consuming SSE stats messages
- [ ] `StatsBarView` — total events, active sessions, active agents, total cost
- [ ] Animated number transitions

### 2b. Agent Cards
- [ ] Fetch active/idle sessions from `/api/sessions`
- [ ] `AgentCardView` — agent type, project, branch, status badge, token count, cost, tool count
- [ ] Live updates via SSE session_update messages
- [ ] Status-based card coloring (active=green, idle=yellow, ended=gray)

### 2c. Event Feed
- [ ] `EventFeedView` — scrollable list of recent events
- [ ] Event type icons and color coding
- [ ] Auto-scroll on new events (with pause when user scrolls up)
- [ ] Timestamp formatting (relative: "2m ago")

### 2d. Filters
- [ ] `FilterBarView` — agent type, event type, tool name filters
- [ ] Fetch filter options from `/api/filter-options`
- [ ] Filter state propagates to event feed and agent cards

### 2e. Cost Dashboard
- [ ] `CostDashboardView` — cost timeline chart (Swift Charts)
- [ ] By-model and by-project breakdowns
- [ ] Fetch from `/api/stats/cost`

### 2f. Tool Analytics
- [ ] `ToolAnalyticsView` — tool usage counts, error rates, avg duration
- [ ] Fetch from `/api/stats/tools`

### 2g. Usage Monitor
- [ ] `UsageMonitorView` — per-agent gauge rings showing window utilization
- [ ] Token limits (Claude Code) and cost limits (Codex)
- [ ] Color thresholds: green (<60%), yellow (60-85%), red (>85%)

**Exit criteria**: Full monitor tab functional with live SSE updates, matching the Svelte dashboard feature-for-feature.

---

## Phase 3: Session Browser
**Goal**: Browse and read Claude Code sessions, matching the Svelte Sessions tab.

### 3a. Session List
- [ ] `SessionsViewModel` with cursor-based pagination
- [ ] `SessionsView` — scrollable list with infinite scroll
- [ ] Project/agent/date filters
- [ ] Session card: project, agent, date range, message count

### 3b. Session Detail
- [ ] `SessionDetailViewModel` fetching messages with offset pagination
- [ ] `SessionDetailView` — message timeline
- [ ] `MessageBlockView` — render user/assistant messages
- [ ] Tool call display (tool name, input preview, result preview)
- [ ] Thinking block indicator (collapsed by default)
- [ ] Sub-session navigation (parent → child links)

### 3c. Session Transcript
- [ ] Fetch from `/api/sessions/:id/transcript` (V1 sessions)
- [ ] Rendered message bubbles with role-based styling

**Exit criteria**: Can browse all sessions, read full message histories, and navigate sub-sessions.

---

## Phase 4: Analytics & Search
**Goal**: Charts and full-text search, matching Svelte Analytics and Search tabs.

### 4a. Analytics Dashboard
- [ ] `AnalyticsViewModel` fetching summary, activity, projects, tools
- [ ] Daily activity line chart (Swift Charts)
- [ ] Project breakdown bar chart
- [ ] Tool usage breakdown
- [ ] Summary stats (total sessions, messages, date range)

### 4b. Search
- [ ] `SearchViewModel` with debounced query input
- [ ] `SearchView` — search bar + results list
- [ ] `SearchResultView` — session context + highlighted snippet
- [ ] Project/agent filter chips on search results
- [ ] Navigate from search result → session detail

**Exit criteria**: All four tabs functional. Feature parity with Svelte dashboard.

---

## Phase 5: Settings & Connection UX
**Goal**: Polished server connection experience.

- [ ] Settings screen with server URL input
- [ ] Bonjour server picker (discovered servers as selectable rows)
- [ ] Connection status indicator in tab bar or nav bar
- [ ] Reconnection feedback (toast/banner)
- [ ] "Last connected" timestamp display
- [ ] App appearance setting (dark/system/light)
- [ ] About screen with version info

**Exit criteria**: Non-technical user can connect to their agentmonitor server without reading docs.

---

## Phase 6: Offline Cache & Polish
**Goal**: Offline browsing of previously viewed data, UI polish.

### 6a. SwiftData Cache
- [ ] Cache last-fetched sessions list
- [ ] Cache viewed session messages
- [ ] Cache last stats snapshot
- [ ] Offline banner when disconnected
- [ ] Stale data indicators ("last updated 5m ago")

### 6b. UI Polish
- [ ] iPad adaptive layout (sidebar navigation)
- [ ] Pull-to-refresh on all list views
- [ ] Haptic feedback on key interactions
- [ ] Smooth transitions between tabs
- [ ] VoiceOver accessibility audit
- [ ] Dynamic Type support audit

**Exit criteria**: App is usable offline with cached data. Feels native and polished.

---

## Future Phases (Not Scoped)

- **Widgets**: Home Screen widget showing active sessions count and cost
- **Live Activities**: Real-time session progress on Lock Screen
- **Shortcuts**: Siri Shortcuts for "How much have I spent today?"
- **Watch Companion**: Glanceable session count on Apple Watch
- **Push Notifications**: Requires server-side APNs integration
- **Bonjour Advertising**: Server-side mDNS advertisement (requires agentmonitor server change)

---

## Dependency Graph

```
Phase 0 (scaffolding)
  └─► Phase 1 (networking)
        ├─► Phase 2 (monitor dashboard)
        │     └─► Phase 5 (settings/connection UX)
        ├─► Phase 3 (session browser)
        └─► Phase 4 (analytics & search)
              └─► Phase 6 (cache & polish)
```

Phases 2, 3, and 4 can be worked in parallel once Phase 1 is complete.
