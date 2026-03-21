import Foundation

struct AgentEvent: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let eventId: String?
    let sessionId: String
    let agentType: String
    let eventType: EventType
    let toolName: String?
    let status: EventStatus?
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
    let source: EventSource?

    var totalTokens: Int {
        (tokensIn ?? 0) + (tokensOut ?? 0)
    }

    var formattedCost: String {
        guard let cost = costUsd, cost > 0 else { return "$0.00" }
        if cost < 0.01 { return "<$0.01" }
        return String(format: "$%.2f", cost)
    }

    var relativeTime: String {
        Formatters.relativeDate(from: createdAt)
    }
}

// MARK: - Enums with Unknown Handling

enum EventType: Codable, Hashable, Sendable {
    case toolUse
    case sessionStart
    case sessionEnd
    case response
    case error
    case llmRequest
    case llmResponse
    case fileChange
    case gitCommit
    case planStep
    case userPrompt
    case unknown(String)

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw {
        case "tool_use": self = .toolUse
        case "session_start": self = .sessionStart
        case "session_end": self = .sessionEnd
        case "response": self = .response
        case "error": self = .error
        case "llm_request": self = .llmRequest
        case "llm_response": self = .llmResponse
        case "file_change": self = .fileChange
        case "git_commit": self = .gitCommit
        case "plan_step": self = .planStep
        case "user_prompt": self = .userPrompt
        default: self = .unknown(raw)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var rawValue: String {
        switch self {
        case .toolUse: return "tool_use"
        case .sessionStart: return "session_start"
        case .sessionEnd: return "session_end"
        case .response: return "response"
        case .error: return "error"
        case .llmRequest: return "llm_request"
        case .llmResponse: return "llm_response"
        case .fileChange: return "file_change"
        case .gitCommit: return "git_commit"
        case .planStep: return "plan_step"
        case .userPrompt: return "user_prompt"
        case .unknown(let raw): return raw
        }
    }

    var displayName: String {
        switch self {
        case .toolUse: return "Tool Use"
        case .sessionStart: return "Session Start"
        case .sessionEnd: return "Session End"
        case .response: return "Response"
        case .error: return "Error"
        case .llmRequest: return "LLM Request"
        case .llmResponse: return "LLM Response"
        case .fileChange: return "File Change"
        case .gitCommit: return "Git Commit"
        case .planStep: return "Plan Step"
        case .userPrompt: return "User Prompt"
        case .unknown(let raw): return raw
        }
    }

    var iconName: String {
        switch self {
        case .toolUse: return "wrench"
        case .sessionStart: return "play.circle"
        case .sessionEnd: return "stop.circle"
        case .response: return "text.bubble"
        case .error: return "exclamationmark.triangle"
        case .llmRequest: return "arrow.up.circle"
        case .llmResponse: return "arrow.down.circle"
        case .fileChange: return "doc.text"
        case .gitCommit: return "arrow.triangle.branch"
        case .planStep: return "list.bullet"
        case .userPrompt: return "person.bubble"
        case .unknown: return "questionmark.circle"
        }
    }
}

enum EventStatus: Codable, Hashable, Sendable {
    case success
    case error
    case timeout
    case unknown(String)

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw {
        case "success": self = .success
        case "error": self = .error
        case "timeout": self = .timeout
        default: self = .unknown(raw)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .success: try container.encode("success")
        case .error: try container.encode("error")
        case .timeout: try container.encode("timeout")
        case .unknown(let raw): try container.encode(raw)
        }
    }
}

enum EventSource: Codable, Hashable, Sendable {
    case api, hook, otel, `import`
    case unknown(String)

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw {
        case "api": self = .api
        case "hook": self = .hook
        case "otel": self = .otel
        case "import": self = .import
        default: self = .unknown(raw)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .api: try container.encode("api")
        case .hook: try container.encode("hook")
        case .otel: try container.encode("otel")
        case .import: try container.encode("import")
        case .unknown(let raw): try container.encode(raw)
        }
    }
}
