import Foundation

enum Formatters {
    private static let isoParser: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let isoParserNoFrac: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    private static let shortTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    static func parseDate(_ string: String) -> Date? {
        isoParser.date(from: string) ?? isoParserNoFrac.date(from: string)
    }

    static func relativeDate(from string: String) -> String {
        guard let date = parseDate(string) else { return string }
        return relativeDateFormatter.localizedString(for: date, relativeTo: .now)
    }

    static func shortDate(from string: String) -> String {
        guard let date = parseDate(string) else { return string }
        return shortDateFormatter.string(from: date)
    }

    static func shortTime(from string: String) -> String {
        guard let date = parseDate(string) else { return string }
        return shortTimeFormatter.string(from: date)
    }

    static func cost(_ value: Double) -> String {
        if value == 0 { return "$0.00" }
        if value < 0.01 { return "<$0.01" }
        return String(format: "$%.2f", value)
    }

    static func compactNumber(_ value: Int) -> String {
        if value < 1_000 { return "\(value)" }
        if value < 1_000_000 { return String(format: "%.1fK", Double(value) / 1_000) }
        return String(format: "%.1fM", Double(value) / 1_000_000)
    }

    static func tokens(_ value: Int) -> String {
        compactNumber(value)
    }

    static func duration(ms: Int) -> String {
        if ms < 1000 { return "\(ms)ms" }
        if ms < 60_000 { return String(format: "%.1fs", Double(ms) / 1000) }
        let minutes = ms / 60_000
        let seconds = (ms % 60_000) / 1000
        return "\(minutes)m \(seconds)s"
    }
}
