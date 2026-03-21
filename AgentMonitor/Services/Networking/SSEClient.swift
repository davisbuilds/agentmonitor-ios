import Foundation

/// Lightweight SSE client built on URLSession.bytes.
/// Emits parsed SSEMessage values as an AsyncStream.
actor SSEClient {
    private let baseURL: URL
    private let session: URLSession
    private var task: Task<Void, Never>?
    private var retryInterval: TimeInterval = 1.0
    private let maxRetryInterval: TimeInterval = 30.0

    private(set) var state: ConnectionState = .disconnected

    enum ConnectionState: Sendable {
        case disconnected
        case connecting
        case connected
        case reconnecting
    }

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Connect to the SSE stream and return an AsyncStream of parsed messages.
    func connect(
        agentType: String? = nil,
        eventType: String? = nil
    ) -> AsyncStream<SSEMessage> {
        // Cancel any existing connection
        task?.cancel()

        return AsyncStream { continuation in
            task = Task { [weak self] in
                guard let self else {
                    continuation.finish()
                    return
                }

                while !Task.isCancelled {
                    await self.setState(.connecting)

                    do {
                        let endpoint = APIEndpoint.stream(agentType: agentType, eventType: eventType)
                        let url = self.buildStreamURL(endpoint: endpoint)

                        var request = URLRequest(url: url)
                        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                        request.timeoutInterval = .infinity

                        let (bytes, response) = try await self.session.bytes(for: request)

                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                            throw SSEError.badStatus
                        }

                        await self.setState(.connected)
                        await self.resetRetry()

                        var eventType: String?
                        var dataLines: [String] = []

                        for try await line in bytes.lines {
                            if Task.isCancelled { break }

                            if line.isEmpty {
                                // Empty line = end of message
                                if !dataLines.isEmpty {
                                    let data = dataLines.joined(separator: "\n")
                                    if let message = Self.parse(eventType: eventType, data: data) {
                                        continuation.yield(message)
                                    }
                                    eventType = nil
                                    dataLines.removeAll()
                                }
                            } else if line.hasPrefix("event:") {
                                eventType = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                            } else if line.hasPrefix("data:") {
                                dataLines.append(String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces))
                            } else if line.hasPrefix(":") {
                                // Comment / heartbeat — ignore
                            } else if line.hasPrefix("retry:") {
                                if let ms = Int(line.dropFirst(6).trimmingCharacters(in: .whitespaces)) {
                                    await self.setRetryInterval(TimeInterval(ms) / 1000.0)
                                }
                            }
                        }
                    } catch {
                        if Task.isCancelled { break }
                        #if DEBUG
                        print("[SSE] Connection error: \(error)")
                        #endif
                    }

                    if Task.isCancelled { break }

                    // Reconnect with backoff
                    await self.setState(.reconnecting)
                    let delay = await self.retryInterval
                    try? await Task.sleep(for: .seconds(delay))
                    await self.backoff()
                }

                await self.setState(.disconnected)
                continuation.finish()
            }
        }
    }

    func disconnect() {
        task?.cancel()
        task = nil
        state = .disconnected
    }

    // MARK: - Private

    private func setState(_ newState: ConnectionState) {
        state = newState
    }

    private func resetRetry() {
        retryInterval = 1.0
    }

    private func setRetryInterval(_ interval: TimeInterval) {
        retryInterval = min(interval, maxRetryInterval)
    }

    private func backoff() {
        retryInterval = min(retryInterval * 2, maxRetryInterval)
    }

    private nonisolated func buildStreamURL(endpoint: APIEndpoint) -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
        let items = endpoint.queryItems
        if !items.isEmpty {
            components.queryItems = items
        }
        return components.url!
    }

    private static func parse(eventType: String?, data: String) -> SSEMessage? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let jsonData = data.data(using: .utf8) else { return nil }

        switch eventType {
        case "event":
            guard let event = try? decoder.decode(AgentEvent.self, from: jsonData) else { return nil }
            return .event(event)
        case "stats":
            guard let stats = try? decoder.decode(StatsSSEMessage.self, from: jsonData) else { return nil }
            return .stats(stats)
        case "session_update":
            guard let update = try? decoder.decode(SessionUpdatePayload.self, from: jsonData) else { return nil }
            return .sessionUpdate(update)
        default:
            return .unknown(eventType: eventType ?? "none", data: data)
        }
    }
}

enum SSEError: Error {
    case badStatus
}
