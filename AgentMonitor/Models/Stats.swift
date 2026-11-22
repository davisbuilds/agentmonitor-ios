import Foundation

struct Stats: Codable, Sendable {
    let totalEvents: Int
    let activeSessions: Int
    let liveSessions: Int
    let totalSessions: Int
    let activeAgents: Int
    let totalTokensIn: Int
    let totalTokensOut: Int
    let totalCostUsd: Double
    let toolBreakdown: [String: Int]
    let agentBreakdown: [String: Int]
    let modelBreakdown: [String: Int]
    let branches: [String]

    var formattedCost: String {
        Formatters.cost(totalCostUsd)
    }

    var totalTokens: Int {
        totalTokensIn + totalTokensOut
    }

    static let empty = Stats(
        totalEvents: 0, activeSessions: 0, liveSessions: 0,
        totalSessions: 0, activeAgents: 0, totalTokensIn: 0,
        totalTokensOut: 0, totalCostUsd: 0,
        toolBreakdown: [:], agentBreakdown: [:],
        modelBreakdown: [:], branches: []
    )
}

/// Extended stats message from SSE, which includes usage_monitor data.
struct StatsSSEMessage: Codable, Sendable {
    let totalEvents: Int
    let activeSessions: Int
    let liveSessions: Int
    let totalSessions: Int
    let activeAgents: Int
    let totalTokensIn: Int
    let totalTokensOut: Int
    let totalCostUsd: Double
    let toolBreakdown: [String: Int]
    let agentBreakdown: [String: Int]
    let modelBreakdown: [String: Int]
    let branches: [String]
    let usageMonitor: [UsageMonitorEntry]?

    var stats: Stats {
        Stats(
            totalEvents: totalEvents, activeSessions: activeSessions,
            liveSessions: liveSessions, totalSessions: totalSessions,
            activeAgents: activeAgents, totalTokensIn: totalTokensIn,
            totalTokensOut: totalTokensOut, totalCostUsd: totalCostUsd,
            toolBreakdown: toolBreakdown, agentBreakdown: agentBreakdown,
            modelBreakdown: modelBreakdown, branches: branches
        )
    }
}
