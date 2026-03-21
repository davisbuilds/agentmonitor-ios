import SwiftUI

struct ErrorStateView: View {
    let message: String
    var retryAction: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            if let retry = retryAction {
                Button("Retry") {
                    retry()
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
