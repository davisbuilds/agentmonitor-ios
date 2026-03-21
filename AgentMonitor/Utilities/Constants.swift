import Foundation

enum Constants {
    static let defaultServerURL = URL(string: "http://127.0.0.1:3141")!
    static let defaultMaxFeedEvents = 200
    static let searchDebounceMs: UInt64 = 300_000_000 // 300ms in nanoseconds
    static let sessionPageSize = 50
    static let messagePageSize = 50
}
