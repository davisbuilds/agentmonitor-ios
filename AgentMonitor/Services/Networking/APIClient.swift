import Foundation

/// HTTP client for the agentmonitor REST API.
protocol APIClientProtocol: Sendable {
    func fetch<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T
}

final class APIClient: APIClientProtocol, Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func fetch<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = try buildURL(for: endpoint)
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        #if DEBUG
        print("[API] GET \(url.absoluteString)")
        #endif

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("[API] Decode error for \(endpoint.path): \(error)")
            if let json = String(data: data, encoding: .utf8) {
                print("[API] Response body: \(json.prefix(500))")
            }
            #endif
            throw APIError.decodingFailed(error)
        }
    }

    private func buildURL(for endpoint: APIEndpoint) throws -> URL {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL(endpoint.path)
        }

        let items = endpoint.queryItems
        if !items.isEmpty {
            components.queryItems = items
        }

        guard let url = components.url else {
            throw APIError.invalidURL(endpoint.path)
        }

        return url
    }
}

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let path):
            return "Invalid URL: \(path)"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code, _):
            return "Server error (\(code))"
        case .decodingFailed(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}
