import Foundation

@Observable
@MainActor
final class SettingsViewModel {
    var serverURLString: String = ""
    var isConnecting = false

    let connection: ServerConnection
    let discovery: ServerDiscovery

    init(connection: ServerConnection, discovery: ServerDiscovery) {
        self.connection = connection
        self.discovery = discovery

        // Load saved URL
        if let saved = ServerConnection.savedServerURL {
            serverURLString = saved.absoluteString
        } else {
            serverURLString = Constants.defaultServerURL.absoluteString
        }
    }

    func connect() async {
        guard let url = URL(string: serverURLString), url.scheme != nil else { return }
        isConnecting = true
        await connection.connect(to: url)
        isConnecting = false
    }

    func disconnect() async {
        await connection.disconnect()
    }

    func connectToDiscovered(_ server: ServerDiscovery.DiscoveredServer) async {
        serverURLString = server.url.absoluteString
        await connect()
    }

    func startDiscovery() {
        discovery.startSearching()
    }

    func stopDiscovery() {
        discovery.stopSearching()
    }
}
