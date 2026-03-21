import SwiftUI
import Charts

struct AnalyticsView: View {
    @State var viewModel: AnalyticsViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if let summary = viewModel.summary {
                    summaryCard(summary)
                }

                if !viewModel.activity.isEmpty {
                    activityChart
                }

                if !viewModel.projects.isEmpty {
                    projectBreakdown
                }

                if !viewModel.tools.isEmpty {
                    toolBreakdown
                }
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .refreshable {
            await viewModel.loadAnalytics()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadAnalytics()
        }
    }

    private func summaryCard(_ summary: AnalyticsSummary) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            SummaryCell(label: "Total Sessions", value: "\(summary.totalSessions)")
            SummaryCell(label: "Total Messages", value: "\(summary.totalMessages)")
            SummaryCell(label: "Avg Daily Sessions", value: String(format: "%.1f", summary.avgDailySessions))
            SummaryCell(label: "Avg Daily Messages", value: String(format: "%.0f", summary.avgDailyMessages))
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var activityChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Activity")
                .font(.headline)

            Chart(viewModel.activity) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Messages", point.messages)
                )
                .foregroundStyle(.blue)

                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Messages", point.messages)
                )
                .foregroundStyle(.blue.opacity(0.1))
            }
            .frame(height: 200)
            .chartXAxis(.hidden)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var projectBreakdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Projects")
                .font(.headline)

            ForEach(viewModel.projects.prefix(10)) { project in
                HStack {
                    Text(project.project)
                        .font(.subheadline)
                        .lineLimit(1)
                    Spacer()
                    Text("\(project.sessionCount) sessions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(project.messageCount) msgs")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var toolBreakdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Top Tools")
                .font(.headline)

            ForEach(viewModel.tools.sorted(by: { $0.count > $1.count }).prefix(10)) { tool in
                HStack {
                    Text(tool.toolName)
                        .font(.subheadline)
                        .lineLimit(1)
                    if let cat = tool.category {
                        Text(cat)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Text("\(tool.count)")
                        .font(.subheadline.monospacedDigit().bold())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct SummaryCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.monospacedDigit().bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
