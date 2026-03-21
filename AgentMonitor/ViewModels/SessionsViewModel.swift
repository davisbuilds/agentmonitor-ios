import Foundation

@Observable
@MainActor
final class SessionsViewModel {
    var sessions: [BrowsingSession] = []
    var isLoading = false
    var error: String?
    var hasMore = false

    // Filters
    var selectedProject: String?
    var selectedAgent: String?
    var availableProjects: [String] = []
    var availableAgents: [String] = []

    private var nextCursor: String?
    private let connection: ServerConnection

    init(connection: ServerConnection) {
        self.connection = connection
    }

    func loadSessions() async {
        guard let api = connection.apiClient else { return }
        isLoading = true
        error = nil
        nextCursor = nil

        do {
            let filters = V2SessionFilters(
                project: selectedProject,
                agent: selectedAgent,
                limit: Constants.sessionPageSize
            )
            let response: BrowsingSessionsResponse = try await api.fetch(.v2Sessions(filters: filters))
            sessions = response.sessions
            nextCursor = response.nextCursor
            hasMore = response.hasMore
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func loadMore() async {
        guard let api = connection.apiClient, hasMore, let cursor = nextCursor else { return }

        do {
            let filters = V2SessionFilters(
                project: selectedProject,
                agent: selectedAgent,
                cursor: cursor,
                limit: Constants.sessionPageSize
            )
            let response: BrowsingSessionsResponse = try await api.fetch(.v2Sessions(filters: filters))
            sessions.append(contentsOf: response.sessions)
            nextCursor = response.nextCursor
            hasMore = response.hasMore
        } catch {
            // Don't overwrite existing data on pagination failure
            #if DEBUG
            print("[Sessions] Pagination error: \(error)")
            #endif
        }
    }

    func loadFilterOptions() async {
        guard let api = connection.apiClient else { return }
        availableProjects = (try? await api.fetch(.v2Projects) as [String]) ?? []
        availableAgents = (try? await api.fetch(.v2Agents) as [String]) ?? []
    }
}
