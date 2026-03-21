# AgentMonitor iOS — Test Strategy

## Philosophy

- Test behavior, not implementation
- Real dependencies over mocks where practical
- Fast feedback loops — unit tests run in <5s
- Integration tests hit a real agentmonitor server (opt-in, not CI-blocking)

---

## Test Pyramid

```
         ┌───────────┐
         │  UI Tests  │  ← Xcode UI Testing (few, critical paths)
         ├───────────┤
         │Integration │  ← Real server, opt-in via env var
         ├───────────┤
         │   Unit     │  ← Models, ViewModels, Services (bulk of tests)
         └───────────┘
```

---

## Layer-by-Layer Strategy

### 1. Models (Unit Tests)

**What**: Codable conformance, computed properties, edge cases.

**How**: Decode from JSON fixtures matching real server responses. Verify round-trip encoding. Test edge cases (null fields, empty arrays, unknown enum values).

**Examples**:
```
- AgentEvent decodes from real POST /api/events response
- Session status enum handles unknown values gracefully
- Stats model parses all fields including nested breakdowns
- Cost formatting handles zero, sub-cent, and large values
```

**Fixtures**: Store real server JSON responses in `Tests/Fixtures/` as `.json` files. Capture once from a running agentmonitor instance, commit to repo.

---

### 2. Services — APIClient (Unit Tests + Integration)

**Unit tests** (always run):
- Use `URLProtocol` subclass to intercept requests
- Verify correct URL construction, query parameters, headers
- Verify response decoding for success and error cases
- Verify error mapping (network error, 4xx, 5xx, decode failure)

**Integration tests** (opt-in, require `AGENTMONITOR_TEST_URL`):
- Hit a real agentmonitor server
- Verify actual response parsing against live data
- Useful for catching contract drift between server and app

```swift
// Run with: AGENTMONITOR_TEST_URL=http://192.168.1.x:3141 xcodebuild test ...
guard let url = ProcessInfo.processInfo.environment["AGENTMONITOR_TEST_URL"] else {
    throw XCTSkip("Set AGENTMONITOR_TEST_URL to run integration tests")
}
```

---

### 3. Services — SSEClient (Unit Tests)

**What**: SSE line parsing, message type routing, reconnection logic.

**How**: Feed raw SSE text lines into the parser and verify emitted messages.

**Test cases**:
```
- Single-line data field → correct SSEMessage
- Multi-line data field (multiple `data:` lines concatenated)
- Event type routing: "event" → .event, "stats" → .stats, "session_update" → .sessionUpdate
- Retry field parsed as reconnection interval
- Empty lines delimit messages
- Malformed lines are skipped without crashing
- Comment lines (starting with :) are ignored (used for heartbeat)
```

**Reconnection logic**:
```
- Backoff doubles: 1s, 2s, 4s, 8s, 16s, 30s (capped)
- Successful reconnect resets backoff to 1s
- Max retry attempts configurable (default unlimited)
```

---

### 4. Services — ServerDiscovery (Unit Tests)

**What**: Bonjour service resolution.

**How**: Difficult to unit test directly (requires mDNS). Test the state machine and URL construction from resolved service info.

```
- Resolved service (host, port) → correct URL construction
- Multiple services discovered → sorted by name
- Service removal updates list
- Discovery timeout handled gracefully
```

---

### 5. ViewModels (Unit Tests)

**What**: State transitions, data transformation, loading/error handling.

**How**: Inject a mock `APIClient` (protocol-based) and verify ViewModel state changes.

**MonitorViewModel**:
```
- Initial state is .loading
- Successful stats fetch → .loaded with formatted data
- Network error → .error with retry action
- SSE event received → events list prepended, stats updated
- SSE connection drop → reconnecting state shown
- Filter change → re-fetches with new parameters
```

**SessionsViewModel**:
```
- Initial fetch loads first page
- Scroll to bottom triggers next page fetch (cursor pagination)
- Filter change resets pagination and re-fetches
- Empty result → empty state
```

**AnalyticsViewModel**:
```
- Fetches summary + activity + projects + tools in parallel
- Partial failure shows available data + error for failed section
```

**SearchViewModel**:
```
- Debounces input (300ms)
- Empty query clears results
- Query < 2 chars shows hint, doesn't search
- Results map to display models with highlighted snippets
```

---

### 6. Views (Snapshot / UI Tests — Minimal)

**Philosophy**: Views are thin bindings. Most logic lives in ViewModels and is tested there. View tests are reserved for:

1. **Snapshot tests** (optional, via swift-snapshot-testing):
   - Verify layout doesn't regress for key screens
   - Dark mode and light mode variants
   - iPhone and iPad size classes
   - Dynamic Type at default and accessibility sizes

2. **UI tests** (Xcode UI Testing, critical paths only):
   - App launches and shows Monitor tab
   - Tab navigation works (all four tabs accessible)
   - Settings: enter server URL → connection attempt
   - Session list: tap session → detail view appears

**Not tested via UI tests**: Every possible state combination. That's what ViewModel unit tests are for.

---

## Test Infrastructure

### JSON Fixtures

Capture real server responses and store in `Tests/Fixtures/`:

```
Tests/
├── Fixtures/
│   ├── stats_response.json
│   ├── sessions_list.json
│   ├── session_detail.json
│   ├── events_list.json
│   ├── cost_breakdown.json
│   ├── tool_analytics.json
│   ├── usage_monitor.json
│   ├── v2_sessions.json
│   ├── v2_messages.json
│   ├── v2_search_results.json
│   ├── v2_analytics_summary.json
│   ├── v2_analytics_activity.json
│   ├── filter_options.json
│   ├── health.json
│   └── sse/
│       ├── event_message.txt
│       ├── stats_message.txt
│       └── session_update_message.txt
```

### Mock APIClient

```swift
protocol APIClientProtocol {
    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

class MockAPIClient: APIClientProtocol {
    var responses: [String: Any] = [:]
    var errors: [String: Error] = [:]

    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if let error = errors[endpoint.path] { throw error }
        guard let response = responses[endpoint.path] as? T else {
            fatalError("No mock response for \(endpoint.path)")
        }
        return response
    }
}
```

### Test Naming Convention

```
test_<unit>_<scenario>_<expected>

Examples:
test_agentEvent_decodesFromServerJSON_allFieldsPopulated()
test_sseParser_multiLineData_concatenatesCorrectly()
test_monitorVM_sseEventReceived_prependsToFeed()
test_sessionsVM_scrollToBottom_fetchesNextPage()
```

---

## CI Considerations (Future)

- Unit tests run on every push (< 10s total)
- Integration tests gated behind `AGENTMONITOR_TEST_URL` env var
- Snapshot tests run only when `SNAPSHOT_UPDATE=1` is set (otherwise compare-only)
- No UI tests in CI initially (slow, flaky on CI runners)

---

## Coverage Goals

| Layer | Target | Notes |
|-------|--------|-------|
| Models | 95%+ | Codable is mechanical, easy to cover |
| Services | 80%+ | Network edge cases, SSE parsing |
| ViewModels | 85%+ | State transitions, error handling |
| Views | n/a | Tested indirectly through ViewModel tests |

These are goals, not gates — don't write pointless tests to hit a number.
