import Foundation

struct BrowsingSession: Codable, Identifiable, Hashable, Sendable {
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

    var displayProject: String {
        project ?? "Unknown Project"
    }

    var isSubSession: Bool {
        parentSessionId != nil
    }

    @MainActor
    var formattedDateRange: String {
        guard let start = startedAt else { return "Unknown" }
        let startStr = Formatters.shortDate(from: start)
        if let end = endedAt {
            let endStr = Formatters.shortTime(from: end)
            return "\(startStr) - \(endStr)"
        }
        return startStr
    }
}

struct BrowsingSessionsResponse: Codable, Sendable {
    let sessions: [BrowsingSession]
    let nextCursor: String?
    let hasMore: Bool
}
