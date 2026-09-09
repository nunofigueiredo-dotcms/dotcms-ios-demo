import SwiftUI

/// Placeholder until build-order step 5 (page layout + component registry).
struct HomeScreen: View {
    var body: some View {
        EmptyStateView(
            title: "Home",
            message: "Page layout and component registry arrive in step 5.",
            systemImage: "square.grid.2x2"
        )
        .navigationTitle("Home")
    }
}
