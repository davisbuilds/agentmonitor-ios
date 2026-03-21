# AgentMonitor iOS — API Contract Reference

Quick reference of every server endpoint the iOS app consumes. Derived from the agentmonitor server source code.

---

## Base URL

Default: `http://127.0.0.1:3141`
Configurable in Settings.

---

## V1 Endpoints (Real-Time Monitoring)

### Health
```
GET /api/health
→ 200 { "status": "ok", "uptime": 12345, "version": "..." }
```

### Stats
```
GET /api/stats
→ 200 {
    "total_events": Int,
    "active_sessions": Int,
    "live_sessions": Int,
    "total_sessions": Int,
    "active_agents": Int,
    "total_tokens_in": Int,
    "total_tokens_out": Int,
    "total_cost_usd": Double,
    "tool_breakdown": { "tool_name": count },
    "agent_breakdown": { "agent_type": count },
    "model_breakdown": { "model": count },
    "branches": [String]
  }
```

### Cost Stats
```
GET /api/stats/cost
→ 200 {
    "timeline": [{ "date": String, "cost_usd": Double }],
    "by_project": [{ "project": String, "cost_usd": Double }],
    "by_model": [{ "model": String, "cost_usd": Double }]
  }
```

### Tool Stats
```
GET /api/stats/tools
→ 200 [{ "tool_name": String, "count": Int, "error_count": Int,
          "error_rate": Double, "avg_duration_ms": Double? }]
```

### Usage Monitor
```
GET /api/stats/usage-monitor
→ 200 [{ "agent_type": String, "windows": [{
           "name": String, "hours": Int,
           "tokens_used": Int, "token_limit": Int,
           "cost_used_cents": Int, "cost_limit_cents": Int,
           "percent_full": Double
        }] }]
```

### Events
```
GET /api/events?agent_type=&event_type=&tool_name=&session_id=&branch=&model=&source=&since=&until=&limit=
→ 200 [AgentEvent]
```

### Sessions
```
GET /api/sessions?status=&exclude_status=&agent_type=&since=&limit=
→ 200 [Session]

GET /api/sessions/:id
→ 200 { ...Session, events: [AgentEvent] (last N) }

GET /api/sessions/:id/transcript
→ 200 { "messages": [{ "role": String, "content": String, "timestamp": String }] }
```

### Filter Options
```
GET /api/filter-options
→ 200 {
    "agent_types": [String],
    "event_types": [String],
    "tool_names": [String],
    "models": [String],
    "projects": [String],
    "branches": [String],
    "sources": [String]
  }
```

### SSE Stream
```
GET /api/stream?agent_type=&event_type=
→ 200 text/event-stream

Message types:
  event: "event"
  data: { AgentEvent JSON }

  event: "stats"
  data: { Stats JSON + usage_monitor: [...] }

  event: "session_update"
  data: { "type": "idle_check"|"session_parsed"|"auto_import"|"resync", ... }

Heartbeat: comment line (":") every 30s
```

---

## V2 Endpoints (Session Browser)

### Sessions
```
GET /api/v2/sessions?project=&agent=&date_from=&date_to=&min_messages=&max_messages=&cursor=&limit=
→ 200 {
    "sessions": [BrowsingSession],
    "next_cursor": String?,
    "has_more": Bool
  }

GET /api/v2/sessions/:id
→ 200 BrowsingSession

GET /api/v2/sessions/:id/messages?offset=&limit=
→ 200 {
    "messages": [Message],
    "total": Int
  }

GET /api/v2/sessions/:id/children
→ 200 [BrowsingSession]
```

### Search
```
GET /api/v2/search?q=&project=&agent=&limit=
→ 200 {
    "results": [{ "session_id": String, "message_id": Int, "snippet": String,
                   "role": String, "session_project": String?, "session_agent": String }],
    "total": Int
  }
```

### Analytics
```
GET /api/v2/analytics/summary
→ 200 { "total_sessions": Int, "total_messages": Int,
         "avg_daily_sessions": Double, "avg_daily_messages": Double,
         "date_range": { "from": String, "to": String } }

GET /api/v2/analytics/activity?days=
→ 200 [{ "date": String, "sessions": Int, "messages": Int }]

GET /api/v2/analytics/projects
→ 200 [{ "project": String, "session_count": Int, "message_count": Int }]

GET /api/v2/analytics/tools
→ 200 [{ "tool_name": String, "count": Int, "category": String? }]
```

### Filter Options
```
GET /api/v2/projects → 200 [String]
GET /api/v2/agents   → 200 [String]
```

---

## Model Types (iOS Codable Structs)

### AgentEvent
```swift
struct AgentEvent: Codable, Identifiable {
    let id: Int
    let eventId: String?
    let sessionId: String
    let agentType: String
    let eventType: String     // tool_use, session_start, session_end, response, error, etc.
    let toolName: String?
    let status: String?       // success, error, timeout
    let tokensIn: Int?
    let tokensOut: Int?
    let cacheReadTokens: Int?
    let cacheWriteTokens: Int?
    let branch: String?
    let project: String?
    let durationMs: Int?
    let createdAt: String
    let clientTimestamp: String?
    let model: String?
    let costUsd: Double?
    let source: String?       // api, hook, otel, import
}
```

### Session
```swift
struct Session: Codable, Identifiable {
    let id: String
    let agentId: String
    let agentType: String
    let project: String?
    let branch: String?
    let status: SessionStatus  // active, idle, ended
    let startedAt: String
    let endedAt: String?
    let lastEventAt: String?
    let metadata: JSONValue?   // flexible JSON
}
```

### BrowsingSession
```swift
struct BrowsingSession: Codable, Identifiable {
    let id: String
    let project: String?
    let agent: String
    let firstMessage: String?
    let startedAt: String?
    let endedAt: String?
    let messageCount: Int
    let userMessageCount: Int
    let parentSessionId: String?
    let relationshipType: String?
}
```

### Message
```swift
struct Message: Codable, Identifiable {
    let id: Int
    let sessionId: String
    let ordinal: Int
    let role: String          // user, assistant
    let content: String       // JSON-serialized ContentBlock[]
    let timestamp: String?
    let hasThinking: Bool
    let hasToolUse: Bool
    let contentLength: Int
}
```

---

## JSON Key Strategy

The server uses `snake_case` for JSON keys. The iOS app uses `convertFromSnakeCase` decoding strategy globally:

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
```

This avoids manual `CodingKeys` on every model.
