import Foundation

struct Message: Codable, Identifiable, Sendable {
    let id: Int
    let sessionId: String
    let ordinal: Int
    let role: MessageRole
    let content: String   // JSON-serialized ContentBlock array
    let timestamp: String?
    let hasThinking: Bool
    let hasToolUse: Bool
    let contentLength: Int

    var isUser: Bool { role == .user }
    var isAssistant: Bool { role == .assistant }
}

enum MessageRole: Codable, Hashable, Sendable {
    case user
    case assistant
    case unknown(String)

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw {
        case "user": self = .user
        case "assistant": self = .assistant
        default: self = .unknown(raw)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .user: try container.encode("user")
        case .assistant: try container.encode("assistant")
        case .unknown(let raw): try container.encode(raw)
        }
    }
}

struct MessagesResponse: Codable, Sendable {
    let messages: [Message]
    let total: Int
}

struct ToolCall: Codable, Identifiable, Sendable {
    let id: Int
    let messageId: Int
    let sessionId: String
    let toolName: String
    let category: String?
    let toolUseId: String?
    let inputJson: String?
    let resultContent: String?
    let resultContentLength: Int?
    let subagentSessionId: String?
}
