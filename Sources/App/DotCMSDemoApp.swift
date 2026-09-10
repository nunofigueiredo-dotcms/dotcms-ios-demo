import SwiftUI

@main
struct DotCMSDemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    /// Restores the last tab, so a demo resumes where it left off.
    @AppStorage("selectedTab") private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeScreen() }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            NavigationStack { BlogListScreen() }
                .tabItem { Label("Blog", systemImage: "text.alignleft") }
                .tag(1)

            NavigationStack {
                PageScreen(uri: "/about-us/index", fallbackTitle: "About")
                    .navigationDestination(for: Contentlet.self) { BlogDetailScreen(blog: $0) }
            }
            .tabItem { Label("About", systemImage: "info.circle") }
            .tag(2)

            NavigationStack { SettingsScreen() }
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)
        }
    }
}
