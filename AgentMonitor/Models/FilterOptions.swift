import Foundation

struct FilterOptions: Codable, Sendable {
    let agentTypes: [String]
    let eventTypes: [String]
    let toolNames: [String]
    let models: [String]
    let projects: [String]
    let branches: [String]
    let sources: [String]

    static let empty = FilterOptions(
        agentTypes: [], eventTypes: [], toolNames: [],
        models: [], projects: [], branches: [], sources: []
    )
}

struct HealthResponse: Codable, Sendable {
    let status: String
    let uptime: Int?
    let version: String?
}
