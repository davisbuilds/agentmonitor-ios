import SwiftUI

struct StatsBarView: View {
    let stats: Stats

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 12) {
            StatCell(label: "Events", value: "\(stats.totalEvents)", icon: "bolt.fill")
            StatCell(label: "Sessions", value: "\(stats.activeSessions)", icon: "play.circle.fill")
            StatCell(label: "Agents", value: "\(stats.activeAgents)", icon: "cpu")
            StatCell(label: "Cost", value: stats.formattedCost, icon: "dollarsign.circle.fill")
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct StatCell: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.monospacedDigit().bold())
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
