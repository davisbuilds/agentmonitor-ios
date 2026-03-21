import Foundation
import Network

/// Discovers agentmonitor servers on the local network via Bonjour/mDNS.
@Observable
@MainActor
final class ServerDiscovery {
    var discoveredServers: [DiscoveredServer] = []
    var isSearching = false

    private var browser: NWBrowser?

    struct DiscoveredServer: Identifiable, Hashable, Sendable {
        let id: String
        let name: String
        let host: String
        let port: Int

        var url: URL {
            URL(string: "http://\(host):\(port)")!
        }
    }

    func startSearching() {
        guard !isSearching else { return }
        isSearching = true
        discoveredServers.removeAll()

        let params = NWParameters()
        params.includePeerToPeer = true

        browser = NWBrowser(for: .bonjour(type: "_agentmonitor._tcp", domain: nil), using: params)

        browser?.browseResultsChangedHandler = { [weak self] results, _ in
            Task { @MainActor in
                self?.updateServers(from: results)
            }
        }

        browser?.stateUpdateHandler = { [weak self] state in
            if case .failed = state {
                Task { @MainActor in
                    self?.isSearching = false
                }
            }
        }

        browser?.start(queue: .main)
    }

    func stopSearching() {
        browser?.cancel()
        browser = nil
        isSearching = false
    }

    private func updateServers(from results: Set<NWBrowser.Result>) {
        discoveredServers = results.compactMap { result in
            guard case .service(let name, _, _, _) = result.endpoint else { return nil }
            // NWBrowser gives us the service name; full resolution happens on connect
            return DiscoveredServer(
                id: name,
                name: name,
                host: name, // Will be resolved when connecting
                port: 3141  // Default port
            )
        }
    }
}
