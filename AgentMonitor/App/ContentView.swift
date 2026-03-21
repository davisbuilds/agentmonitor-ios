import SwiftUI

struct ContentView: View {
    let connection: ServerConnection
    let discovery: ServerDiscovery

    @State private var selectedTab: AppTab = .monitor
    @State private var showSettings = false

    var body: some View {
        Group {
            if connection.state == .connected {
                connectedView
            } else {
                SettingsView(
                    viewModel: SettingsViewModel(connection: connection, discovery: discovery)
                )
            }
        }
    }

    @ViewBuilder
    private var connectedView: some View {
        TabView(selection: $selectedTab) {
            Tab("Monitor", systemImage: "gauge.with.dots.needle.33percent", value: .monitor) {
                NavigationStack {
                    MonitorView(viewModel: MonitorViewModel(connection: connection))
                        .toolbar { settingsButton }
                }
            }

            Tab("Sessions", systemImage: "list.bullet.rectangle", value: .sessions) {
                NavigationStack {
                    SessionsView(viewModel: SessionsViewModel(connection: connection), connection: connection)
                        .toolbar { settingsButton }
                }
            }

            Tab("Analytics", systemImage: "chart.bar", value: .analytics) {
                NavigationStack {
                    AnalyticsView(viewModel: AnalyticsViewModel(connection: connection))
                        .toolbar { settingsButton }
                }
            }

            Tab("Search", systemImage: "magnifyingglass", value: .search) {
                NavigationStack {
                    SearchView(viewModel: SearchViewModel(connection: connection), connection: connection)
                        .toolbar { settingsButton }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView(
                    viewModel: SettingsViewModel(connection: connection, discovery: discovery)
                )
            }
        }
    }

    private var settingsButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gear")
            }
        }
    }
}

enum AppTab: Hashable {
    case monitor
    case sessions
    case analytics
    case search
}
