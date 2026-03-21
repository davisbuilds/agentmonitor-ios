import Foundation

@Observable
@MainActor
final class MonitorViewModel {
    // MARK: - State

    var stats: Stats = .empty
    var events: [AgentEvent] = []
    var sessions: [Session] = []
    var costBreakdown: CostBreakdown?
    var toolStats: [ToolStat] = []
    var usageMonitor: [UsageMonitorEntry] = []
    var filterOptions: FilterOptions = .empty

    var isLoading = false
    var error: String?

    // Active filters
    var selectedAgentType: String?
    var selectedEventType: String?
    var selectedToolName: String?

    private var sseTask: Task<Void, Never>?

    // MARK: - Dependencies

    private let connection: ServerConnection

    init(connection: ServerConnection) {
        self.connection = connection
    }

    // MARK: - Actions

    func loadInitialData() async {
        guard let api = connection.apiClient else { return }
        isLoading = true
        error = nil

        do {
            async let statsResult: Stats = api.fetch(.stats)
            async let eventsResult: [AgentEvent] = api.fetch(.events(filters: currentEventFilters))
            async let sessionsResult: [Session] = api.fetch(.sessions(filters: SessionFilters(excludeStatus: "ended")))
            async let filtersResult: FilterOptions = api.fetch(.filterOptions)

            stats = try await statsResult
            events = try await eventsResult
            sessions = try await sessionsResult
            filterOptions = try await filtersResult

            // Non-critical fetches — don't block on failure
            costBreakdown = try? await api.fetch(.costStats)
            toolStats = (try? await api.fetch(.toolStats) as [ToolStat]) ?? []
            usageMonitor = (try? await api.fetch(.usageMonitor) as [UsageMonitorEntry]) ?? []

            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func startSSE() {
        guard let sse = connection.sseClient else { return }
        stopSSE()

        sseTask = Task {
            let stream = await sse.connect(
                agentType: selectedAgentType,
                eventType: selectedEventType
            )

            for await message in stream {
                if Task.isCancelled { break }
                handleSSEMessage(message)
            }
        }
    }

    func stopSSE() {
        sseTask?.cancel()
        sseTask = nil
    }

    func refresh() async {
        await loadInitialData()
    }

    // MARK: - Private

    private func handleSSEMessage(_ message: SSEMessage) {
        switch message {
        case .event(let event):
            events.insert(event, at: 0)
            if events.count > Constants.defaultMaxFeedEvents {
                events.removeLast()
            }

        case .stats(let sseStats):
            stats = sseStats.stats
            if let monitor = sseStats.usageMonitor {
                usageMonitor = monitor
            }

        case .sessionUpdate:
            // Re-fetch sessions on lifecycle changes
            Task {
                guard let api = connection.apiClient else { return }
                sessions = (try? await api.fetch(.sessions(filters: SessionFilters(excludeStatus: "ended")))) ?? sessions
            }

        case .unknown:
            break
        }
    }

    private var currentEventFilters: EventFilters {
        EventFilters(
            agentType: selectedAgentType,
            eventType: selectedEventType,
            toolName: selectedToolName,
            limit: Constants.defaultMaxFeedEvents
        )
    }
}
