import Foundation

@Observable
@MainActor
final class AnalyticsViewModel {
    var summary: AnalyticsSummary?
    var activity: [ActivityDataPoint] = []
    var projects: [ProjectBreakdown] = []
    var tools: [ToolBreakdown] = []

    var isLoading = false
    var error: String?

    private let connection: ServerConnection

    init(connection: ServerConnection) {
        self.connection = connection
    }

    func loadAnalytics() async {
        guard let api = connection.apiClient else { return }
        isLoading = true
        error = nil

        do {
            async let summaryResult: AnalyticsSummary = api.fetch(.v2AnalyticsSummary)
            async let activityResult: [ActivityDataPoint] = api.fetch(.v2AnalyticsActivity(days: 30))
            async let projectsResult: [ProjectBreakdown] = api.fetch(.v2AnalyticsProjects)
            async let toolsResult: [ToolBreakdown] = api.fetch(.v2AnalyticsTools)

            summary = try await summaryResult
            activity = try await activityResult
            projects = try await projectsResult
            tools = try await toolsResult
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
}
