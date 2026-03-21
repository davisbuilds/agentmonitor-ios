import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    var icon: String = "tray"

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        }
    }
}
