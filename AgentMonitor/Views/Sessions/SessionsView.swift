import SwiftUI

struct SessionsView: View {
    @State var viewModel: SessionsViewModel
    let connection: ServerConnection

    var body: some View {
        List {
            ForEach(viewModel.sessions) { session in
                NavigationLink(value: session) {
                    SessionRowView(session: session)
                }
            }

            if viewModel.hasMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .task {
                        await viewModel.loadMore()
                    }
            }
        }
        .navigationTitle("Sessions")
        .navigationDestination(for: BrowsingSession.self) { session in
            SessionDetailView(
                viewModel: SessionDetailViewModel(sessionId: session.id, connection: connection)
            )
        }
        .refreshable {
            await viewModel.loadSessions()
        }
        .overlay {
            if viewModel.isLoading && viewModel.sessions.isEmpty {
                ProgressView()
            }
            if let error = viewModel.error, viewModel.sessions.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadSessions() }
                }
            }
            if !viewModel.isLoading && viewModel.sessions.isEmpty && viewModel.error == nil {
                EmptyStateView(
                    title: "No Sessions",
                    message: "Session data will appear here once agents start running."
                )
            }
        }
        .task {
            await viewModel.loadSessions()
        }
    }
}

private struct SessionRowView: View {
    let session: BrowsingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.displayProject)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Spacer()
                Text("\(session.messageCount) msgs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let first = session.firstMessage {
                Text(first)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Text(session.agent)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(session.formattedDateRange)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}
