import SwiftUI

struct UsageMonitorView: View {
    let entries: [UsageMonitorEntry]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.agentType.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.subheadline.bold())

                    ForEach(entry.windows) { window in
                        UsageGaugeRow(window: window)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct UsageGaugeRow: View {
    let window: UsageWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(window.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(window.formattedUsage)
                    .font(.caption.monospacedDigit())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))

                    Capsule()
                        .fill(Color.forUsageSeverity(window.severity))
                        .frame(width: geo.size.width * min(window.percentFull / 100, 1.0))
                }
            }
            .frame(height: 6)
        }
    }
}
