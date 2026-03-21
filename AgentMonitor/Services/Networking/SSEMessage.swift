import Foundation

/// A parsed Server-Sent Event message.
enum SSEMessage: Sendable {
    case event(AgentEvent)
    case stats(StatsSSEMessage)
    case sessionUpdate(SessionUpdatePayload)
    case unknown(eventType: String, data: String)
}

struct SessionUpdatePayload: Codable, Sendable {
    let type: String  // idle_check, session_parsed, auto_import, resync
}
