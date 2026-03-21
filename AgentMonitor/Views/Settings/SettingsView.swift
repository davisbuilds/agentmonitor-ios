import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Server Connection") {
                connectionStatus

                TextField("Server URL", text: $viewModel.serverURLString)
                    #if os(iOS)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()

                if viewModel.connection.state == .connected {
                    Button("Disconnect", role: .destructive) {
                        Task { await viewModel.disconnect() }
                    }
                } else {
                    Button("Connect") {
                        Task { await viewModel.connect() }
                    }
                    .disabled(viewModel.isConnecting)
                }

                if let error = viewModel.connection.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section("Network Discovery") {
                if viewModel.discovery.isSearching {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Searching...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if viewModel.discovery.discoveredServers.isEmpty && viewModel.discovery.isSearching {
                    Text("No servers found on local network")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.discovery.discoveredServers) { server in
                        Button {
                            Task { await viewModel.connectToDiscovered(server) }
                        } label: {
                            HStack {
                                Image(systemName: "network")
                                VStack(alignment: .leading) {
                                    Text(server.name)
                                        .font(.subheadline)
                                    Text(server.url.absoluteString)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Button(viewModel.discovery.isSearching ? "Stop Searching" : "Search Local Network") {
                    if viewModel.discovery.isSearching {
                        viewModel.stopDiscovery()
                    } else {
                        viewModel.startDiscovery()
                    }
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }

    @ViewBuilder
    private var connectionStatus: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(statusText)
                .font(.subheadline)
            Spacer()
        }
    }

    private var statusColor: Color {
        switch viewModel.connection.state {
        case .connected: return .green
        case .connecting, .reconnecting: return .yellow
        case .disconnected: return .gray
        case .error: return .red
        }
    }

    private var statusText: String {
        switch viewModel.connection.state {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .reconnecting: return "Reconnecting..."
        case .disconnected: return "Disconnected"
        case .error: return "Connection Error"
        }
    }
}
