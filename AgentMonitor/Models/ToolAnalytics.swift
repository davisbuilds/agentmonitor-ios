import Foundation

struct ToolStat: Codable, Identifiable, Sendable {
    var id: String { toolName }
    let toolName: String
    let count: Int
    let errorCount: Int
    let errorRate: Double
    let avgDurationMs: Double?

    var formattedDuration: String? {
        guard let ms = avgDurationMs else { return nil }
        if ms < 1000 { return "\(Int(ms))ms" }
        return String(format: "%.1fs", ms / 1000)
    }

    var formattedErrorRate: String {
        if errorRate == 0 { return "0%" }
        return String(format: "%.1f%%", errorRate * 100)
    }
}
