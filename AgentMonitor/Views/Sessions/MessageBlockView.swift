import SwiftUI

struct MessageBlockView: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: message.isUser ? "person.circle.fill" : "cpu")
                .font(.title3)
                .foregroundStyle(message.isUser ? .blue : .orange)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.isUser ? "User" : "Assistant")
                        .font(.caption.bold())

                    if message.hasToolUse {
                        Image(systemName: "wrench")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }

                    if message.hasThinking {
                        Image(systemName: "brain")
                            .font(.caption2)
                            .foregroundStyle(.purple)
                    }

                    Spacer()

                    if let ts = message.timestamp {
                        Text(Formatters.relativeDate(from: ts))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                // Content is JSON-serialized ContentBlock array.
                // For now, show a truncated plain text preview.
                // Phase 3 will add rich rendering.
                Text(contentPreview)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .lineLimit(10)
            }
        }
        .padding()
        .background(
            message.isUser
                ? Color.blue.opacity(0.05)
                : Color.orange.opacity(0.05),
            in: RoundedRectangle(cornerRadius: 10)
        )
    }

    private var contentPreview: String {
        // The content field is a JSON array of content blocks.
        // Extract text blocks for preview.
        guard let data = message.content.data(using: .utf8),
              let blocks = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return message.content.prefix(500).description
        }

        return blocks.compactMap { block -> String? in
            if let text = block["text"] as? String {
                return text
            }
            if block["type"] as? String == "tool_use" {
                let name = block["name"] as? String ?? "tool"
                return "[\(name)]"
            }
            return nil
        }.joined(separator: "\n").prefix(500).description
    }
}
