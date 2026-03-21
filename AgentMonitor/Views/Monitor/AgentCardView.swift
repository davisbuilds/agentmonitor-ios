import SwiftUI

struct AgentCardView: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.forSessionStatus(session.status))
                    .frame(width: 8, height: 8)

                Text(session.agentType.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.subheadline.bold())

                Spacer()

                Text(session.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.forSessionStatus(session.status).opacity(0.2))
                    .clipShape(Capsule())
            }

            if let project = session.project {
                Label(project, systemImage: "folder")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let branch = session.branch {
                Label(branch, systemImage: "arrow.triangle.branch")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(Formatters.relativeDate(from: session.startedAt))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}
