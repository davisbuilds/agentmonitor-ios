import SwiftUI

struct SearchView: View {
    @State var viewModel: SearchViewModel
    let connection: ServerConnection

    var body: some View {
        List {
            ForEach(viewModel.results) { result in
                NavigationLink(value: result.sessionId) {
                    SearchResultRow(result: result)
                }
            }

            if viewModel.results.isEmpty && !viewModel.query.isEmpty && !viewModel.isSearching {
                ContentUnavailableView.search(text: viewModel.query)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $viewModel.query, prompt: "Search messages...")
        .onChange(of: viewModel.query) {
            viewModel.search()
        }
        .navigationDestination(for: String.self) { sessionId in
            SessionDetailView(
                viewModel: SessionDetailViewModel(sessionId: sessionId, connection: connection)
            )
        }
        .overlay {
            if viewModel.isSearching {
                ProgressView()
            }
            if viewModel.query.isEmpty && viewModel.results.isEmpty {
                EmptyStateView(
                    title: "Search Sessions",
                    message: "Search across all session messages using full-text search."
                )
            }
        }
    }
}

private struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(result.sessionProject ?? "Unknown Project")
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Spacer()
                Text(result.role)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(result.snippet)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Text(result.sessionAgent)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}
