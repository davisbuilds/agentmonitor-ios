import Foundation

struct AnalyticsSummary: Codable, Sendable {
    let totalSessions: Int
    let totalMessages: Int
    let avgDailySessions: Double
    let avgDailyMessages: Double
    let dateRange: DateRange?
}

struct DateRange: Codable, Sendable {
    let from: String
    let to: String
}

struct ActivityDataPoint: Codable, Identifiable, Sendable {
    var id: String { date }
    let date: String
    let sessions: Int
    let messages: Int
}

struct ProjectBreakdown: Codable, Identifiable, Sendable {
    var id: String { project }
    let project: String
    let sessionCount: Int
    let messageCount: Int
}

struct ToolBreakdown: Codable, Identifiable, Sendable {
    var id: String { toolName }
    let toolName: String
    let count: Int
    let category: String?
}
