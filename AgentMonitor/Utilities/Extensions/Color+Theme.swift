import SwiftUI

extension Color {
    // Status colors
    static let statusActive = Color.green
    static let statusIdle = Color.yellow
    static let statusEnded = Color.gray

    // Usage gauge colors
    static let usageNormal = Color.green
    static let usageWarning = Color.orange
    static let usageCritical = Color.red

    // Event type accent colors
    static let eventToolUse = Color.blue
    static let eventSession = Color.purple
    static let eventError = Color.red
    static let eventResponse = Color.cyan
    static let eventUserPrompt = Color.indigo

    // Agent type colors
    static let agentClaudeCode = Color.orange
    static let agentCodex = Color.green

    static func forAgentType(_ type: String) -> Color {
        switch type {
        case "claude_code": return .agentClaudeCode
        case "codex": return .agentCodex
        default: return .blue
        }
    }

    static func forSessionStatus(_ status: SessionStatus) -> Color {
        switch status {
        case .active: return .statusActive
        case .idle: return .statusIdle
        case .ended: return .statusEnded
        case .unknown: return .gray
        }
    }

    static func forUsageSeverity(_ severity: UsageSeverity) -> Color {
        switch severity {
        case .normal: return .usageNormal
        case .warning: return .usageWarning
        case .critical: return .usageCritical
        }
    }
}
