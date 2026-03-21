import Foundation

struct SearchResponse: Codable, Sendable {
    let results: [SearchResult]
    let total: Int
}

struct SearchResult: Codable, Identifiable, Sendable {
    var id: String { "\(sessionId)-\(messageId)" }
    let sessionId: String
    let messageId: Int
    let snippet: String
    let role: String
    let sessionProject: String?
    let sessionAgent: String
}
