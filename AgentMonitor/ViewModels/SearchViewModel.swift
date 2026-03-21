import Foundation

@Observable
@MainActor
final class SearchViewModel {
    var query = ""
    var results: [SearchResult] = []
    var totalResults = 0
    var isSearching = false
    var error: String?

    // Filters
    var selectedProject: String?
    var selectedAgent: String?

    private var searchTask: Task<Void, Never>?
    private let connection: ServerConnection

    init(connection: ServerConnection) {
        self.connection = connection
    }

    func search() {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            results = []
            totalResults = 0
            return
        }

        searchTask = Task {
            // Debounce
            try? await Task.sleep(nanoseconds: Constants.searchDebounceMs)
            if Task.isCancelled { return }

            await performSearch(query: trimmed)
        }
    }

    func clearSearch() {
        query = ""
        results = []
        totalResults = 0
        error = nil
    }

    private func performSearch(query: String) async {
        guard let api = connection.apiClient else { return }
        isSearching = true
        error = nil

        do {
            let response: SearchResponse = try await api.fetch(
                .v2Search(query: query, project: selectedProject, agent: selectedAgent, limit: 50)
            )
            if !Task.isCancelled {
                results = response.results
                totalResults = response.total
            }
        } catch {
            if !Task.isCancelled {
                self.error = error.localizedDescription
            }
        }

        if !Task.isCancelled {
            isSearching = false
        }
    }
}
