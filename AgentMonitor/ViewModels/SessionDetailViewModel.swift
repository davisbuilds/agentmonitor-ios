import Foundation

@Observable
@MainActor
final class SessionDetailViewModel {
    var session: BrowsingSession?
    var messages: [Message] = []
    var children: [BrowsingSession] = []
    var totalMessages = 0
    var isLoading = false
    var error: String?

    private let sessionId: String
    private let connection: ServerConnection
    private var loadedOffset = 0

    init(sessionId: String, connection: ServerConnection) {
        self.sessionId = sessionId
        self.connection = connection
    }

    var hasMoreMessages: Bool {
        messages.count < totalMessages
    }

    func loadSession() async {
        guard let api = connection.apiClient else { return }
        isLoading = true
        error = nil

        do {
            async let sessionResult: BrowsingSession = api.fetch(.v2SessionDetail(id: sessionId))
            async let messagesResult: MessagesResponse = api.fetch(
                .v2SessionMessages(id: sessionId, offset: 0, limit: Constants.messagePageSize)
            )
            async let childrenResult: [BrowsingSession] = api.fetch(.v2SessionChildren(id: sessionId))

            session = try await sessionResult
            let msgResponse = try await messagesResult
            messages = msgResponse.messages
            totalMessages = msgResponse.total
            loadedOffset = messages.count
            children = try await childrenResult
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func loadMoreMessages() async {
        guard let api = connection.apiClient, hasMoreMessages else { return }

        do {
            let response: MessagesResponse = try await api.fetch(
                .v2SessionMessages(id: sessionId, offset: loadedOffset, limit: Constants.messagePageSize)
            )
            messages.append(contentsOf: response.messages)
            loadedOffset = messages.count
        } catch {
            #if DEBUG
            print("[SessionDetail] Load more error: \(error)")
            #endif
        }
    }
}
