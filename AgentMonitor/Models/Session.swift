import Foundation

struct Session: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let agentId: String
    let agentType: String
    let project: String?
    let branch: String?
    let status: SessionStatus
    let startedAt: String
    let endedAt: String?
    let lastEventAt: String?

    var displayProject: String {
        project ?? "Unknown Project"
    }

    var isActive: Bool {
        status == .active
    }
}

enum SessionStatus: Codable, Hashable, Sendable {
    case active
    case idle
    case ended
    case unknown(String)

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw {
        case "active": self = .active
        case "idle": self = .idle
        case "ended": self = .ended
        default: self = .unknown(raw)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .active: try container.encode("active")
        case .idle: try container.encode("idle")
        case .ended: try container.encode("ended")
        case .unknown(let raw): try container.encode(raw)
        }
    }

    var displayName: String {
        switch self {
        case .active: return "Active"
        case .idle: return "Idle"
        case .ended: return "Ended"
        case .unknown(let raw): return raw.capitalized
        }
    }
}

struct SessionDetail: Codable, Sendable {
    let id: String
    let agentId: String
    let agentType: String
    let project: String?
    let branch: String?
    let status: SessionStatus
    let startedAt: String
    let endedAt: String?
    let lastEventAt: String?
    let events: [AgentEvent]
}

struct SessionTranscript: Codable, Sendable {
    let messages: [TranscriptMessage]
}

struct TranscriptMessage: Codable, Identifiable, Sendable {
    var id: String { "\(role)-\(timestamp)" }
    let role: String
    let content: String
    let timestamp: String
}
