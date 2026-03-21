import SwiftUI
import Charts

struct CostDashboardView: View {
    let breakdown: CostBreakdown

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !breakdown.timeline.isEmpty {
                Text("Cost Timeline")
                    .font(.subheadline.bold())

                Chart(breakdown.timeline) { entry in
                    BarMark(
                        x: .value("Date", entry.date),
                        y: .value("Cost", entry.costUsd)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .frame(height: 150)
                .chartXAxis(.hidden)
            }

            if !breakdown.byModel.isEmpty {
                Text("By Model")
                    .font(.subheadline.bold())

                ForEach(breakdown.byModel) { entry in
                    HStack {
                        Text(entry.key)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text(entry.formattedCost)
                            .font(.caption.monospacedDigit().bold())
                    }
                }
            }

            if !breakdown.byProject.isEmpty {
                Text("By Project")
                    .font(.subheadline.bold())

                ForEach(breakdown.byProject) { entry in
                    HStack {
                        Text(entry.key)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Text(entry.formattedCost)
                            .font(.caption.monospacedDigit().bold())
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
