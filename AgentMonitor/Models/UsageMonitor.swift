import Foundation

struct UsageMonitorEntry: Codable, Identifiable, Sendable {
    var id: String { agentType }
    let agentType: String
    let windows: [UsageWindow]
}

struct UsageWindow: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
    let hours: Int
    let tokensUsed: Int?
    let tokenLimit: Int?
    let costUsedCents: Int?
    let costLimitCents: Int?
    let percentFull: Double

    var isTokenBased: Bool {
        tokenLimit != nil && tokenLimit! > 0
    }

    var isCostBased: Bool {
        costLimitCents != nil && costLimitCents! > 0
    }

    var severity: UsageSeverity {
        switch percentFull {
        case ..<60: return .normal
        case 60..<85: return .warning
        default: return .critical
        }
    }

    var formattedUsage: String {
        if isTokenBased, let used = tokensUsed, let limit = tokenLimit {
            return "\(Formatters.compactNumber(used)) / \(Formatters.compactNumber(limit))"
        }
        if isCostBased, let used = costUsedCents, let limit = costLimitCents {
            return "\(Formatters.cost(Double(used) / 100)) / \(Formatters.cost(Double(limit) / 100))"
        }
        return "\(Int(percentFull))%"
    }
}

enum UsageSeverity: Sendable {
    case normal   // < 60%
    case warning  // 60-85%
    case critical // > 85%
}
