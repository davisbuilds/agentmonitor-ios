import SwiftUI

@main
struct AgentMonitorApp: App {
    @State private var connection = ServerConnection()
    @State private var discovery = ServerDiscovery()

    var body: some Scene {
        WindowGroup {
            ContentView(connection: connection, discovery: discovery)
                .preferredColorScheme(.dark)
                .task {
                    // Auto-connect to last known server on launch
                    if let savedURL = ServerConnection.savedServerURL {
                        await connection.connect(to: savedURL)
                    }
                }
        }
    }
}
