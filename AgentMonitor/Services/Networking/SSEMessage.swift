import Foundation

/// A parsed Server-Sent Event message.
enum SSEMessage: Sendable {
    case event(AgentEvent)
    case stats(StatsSSEMessage)
    case sessionUpdate(SessionUpdatePayload)
    case unknown(eventType: String, data: String)
}

struct SessionUpdatePayload: Codable, Sendable {
    /// Server event type. Known values are `idle_check`, `session_parsed`, `auto_import` and `resync`.
    let type: String
}
