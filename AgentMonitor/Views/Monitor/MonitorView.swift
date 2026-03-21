import SwiftUI

struct MonitorView: View {
    @State var viewModel: MonitorViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                StatsBarView(stats: viewModel.stats)

                if !viewModel.sessions.isEmpty {
                    sectionHeader("Active Sessions")
                    ForEach(viewModel.sessions) { session in
                        AgentCardView(session: session)
                    }
                }

                if !viewModel.usageMonitor.isEmpty {
                    sectionHeader("Usage")
                    UsageMonitorView(entries: viewModel.usageMonitor)
                }

                if !viewModel.events.isEmpty {
                    sectionHeader("Event Feed")
                    EventFeedView(events: viewModel.events)
                }

                if let costs = viewModel.costBreakdown {
                    sectionHeader("Costs")
                    CostDashboardView(breakdown: costs)
                }

                if !viewModel.toolStats.isEmpty {
                    sectionHeader("Tools")
                    ToolAnalyticsView(tools: viewModel.toolStats)
                }
            }
            .padding()
        }
        .navigationTitle("Monitor")
        .refreshable {
            await viewModel.refresh()
        }
        .overlay {
            if viewModel.isLoading && viewModel.events.isEmpty {
                ProgressView("Connecting...")
            }
        }
        .overlay {
            if let error = viewModel.error, viewModel.events.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.refresh() }
                }
            }
        }
        .task {
            await viewModel.loadInitialData()
            viewModel.startSSE()
        }
        .onDisappear {
            viewModel.stopSSE()
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
