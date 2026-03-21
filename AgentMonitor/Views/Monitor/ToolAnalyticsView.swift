import SwiftUI

struct ToolAnalyticsView: View {
    let tools: [ToolStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(tools.prefix(10)) { tool in
                HStack {
                    Text(tool.toolName)
                        .font(.caption)
                        .lineLimit(1)

                    Spacer()

                    Text("\(tool.count)")
                        .font(.caption.monospacedDigit().bold())

                    if tool.errorCount > 0 {
                        Text(tool.formattedErrorRate)
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }

                    if let duration = tool.formattedDuration {
                        Text(duration)
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
