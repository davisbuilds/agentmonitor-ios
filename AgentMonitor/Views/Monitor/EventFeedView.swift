import SwiftUI

struct EventFeedView: View {
    let events: [AgentEvent]

    var body: some View {
        LazyVStack(spacing: 6) {
            ForEach(events.prefix(50)) { event in
                EventRow(event: event)
            }
        }
    }
}

private struct EventRow: View {
    let event: AgentEvent

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: event.eventType.iconName)
                .font(.caption)
                .foregroundStyle(iconColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(event.eventType.displayName)
                        .font(.caption.bold())

                    if let tool = event.toolName {
                        Text(tool)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 8) {
                    if let project = event.project {
                        Text(project)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    if event.totalTokens > 0 {
                        Text("\(Formatters.tokens(event.totalTokens)) tok")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            Text(Formatters.relativeDate(from: event.createdAt))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }

    private var iconColor: Color {
        switch event.eventType {
        case .toolUse: return .eventToolUse
        case .error: return .eventError
        case .sessionStart, .sessionEnd: return .eventSession
        case .response: return .eventResponse
        case .userPrompt: return .eventUserPrompt
        default: return .secondary
        }
    }
}
