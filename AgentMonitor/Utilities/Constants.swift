import Foundation

enum Constants {
    static let defaultServerURL = URL(string: "http://127.0.0.1:3141")!
    static let defaultMaxFeedEvents = 200
    /// Search debounce interval in nanoseconds.
    static let searchDebounceMs: UInt64 = 300_000_000
    static let sessionPageSize = 50
    static let messagePageSize = 50
}
