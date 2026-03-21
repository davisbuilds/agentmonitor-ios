import SwiftUI

struct SessionDetailView: View {
    @State var viewModel: SessionDetailViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if let session = viewModel.session {
                    sessionHeader(session)
                }

                if !viewModel.children.isEmpty {
                    subSessionsSection
                }

                ForEach(viewModel.messages) { message in
                    MessageBlockView(message: message)
                }

                if viewModel.hasMoreMessages {
                    ProgressView()
                        .task {
                            await viewModel.loadMoreMessages()
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Session")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .overlay {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                ProgressView()
            }
            if let error = viewModel.error, viewModel.messages.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadSession() }
                }
            }
        }
        .task {
            await viewModel.loadSession()
        }
    }

    private func sessionHeader(_ session: BrowsingSession) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(session.displayProject)
                .font(.headline)

            HStack {
                Label(session.agent, systemImage: "cpu")
                Spacer()
                Text("\(session.messageCount) messages")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(session.formattedDateRange)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var subSessionsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sub-sessions")
                .font(.subheadline.bold())

            ForEach(viewModel.children) { child in
                HStack {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(child.firstMessage ?? "Sub-session")
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                    Text("\(child.messageCount) msgs")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
