import Foundation

/// Manages connection state to an agentmonitor server instance.
@Observable
@MainActor
final class ServerConnection {
    var state: ConnectionState = .disconnected
    var serverURL: URL?
    var lastError: String?

    private(set) var apiClient: APIClient?
    private(set) var sseClient: SSEClient?
    private var healthCheckTask: Task<Void, Never>?

    enum ConnectionState: Sendable {
        case disconnected
        case connecting
        case connected
        case reconnecting
        case error
    }

    /// Persist the server URL across launches.
    static var savedServerURL: URL? {
        get {
            guard let str = UserDefaults.standard.string(forKey: "serverURL") else { return nil }
            return URL(string: str)
        }
        set {
            UserDefaults.standard.set(newValue?.absoluteString, forKey: "serverURL")
        }
    }

    func connect(to url: URL) async {
        state = .connecting
        lastError = nil
        serverURL = url

        let client = APIClient(baseURL: url)
        apiClient = client
        sseClient = SSEClient(baseURL: url)

        do {
            let health: HealthResponse = try await client.fetch(.health)
            if health.status == "ok" {
                state = .connected
                Self.savedServerURL = url
            } else {
                state = .error
                lastError = "Server returned status: \(health.status)"
            }
        } catch {
            state = .error
            lastError = error.localizedDescription
        }
    }

    func disconnect() async {
        await sseClient?.disconnect()
        apiClient = nil
        sseClient = nil
        state = .disconnected
        lastError = nil
    }
}
