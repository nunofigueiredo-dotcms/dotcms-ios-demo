import SwiftUI

/// The site's home page. All rendering lives in `PageScreen`, so Home and any
/// other page asset stay identical by construction.
struct HomeScreen: View {
    var body: some View {
        PageScreen(uri: "/index", fallbackTitle: "Home")
            .navigationDestination(for: Contentlet.self) { BlogDetailScreen(blog: $0) }
    }
}
