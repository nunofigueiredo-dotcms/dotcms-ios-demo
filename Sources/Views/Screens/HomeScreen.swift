import SwiftUI

@MainActor
@Observable
final class HomeModel {
    var state: LoadState<PageLayout> = .idle
    private let repository = PageRepository()

    func load() async {
        if case .loaded = state {} else { state = .loading }
        do {
            let page = try await repository.page(uri: "/index")
            state = page.isEmpty ? .empty : .loaded(page)
        } catch let error as DotCMSError {
            state = .failed(error)
        } catch {
            state = .failed(.network(error.localizedDescription))
        }
    }
}

/// Renders the dotCMS page layout, mapping the web structure to SwiftUI:
/// row -> VStack, column -> HStack on regular width (stacked on compact),
/// container -> ForEach, contentlet -> component registry lookup.
struct HomeScreen: View {
    @State private var model = HomeModel()
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        Group {
            switch model.state {
            case .idle, .loading:
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(0..<3, id: \.self) { _ in SkeletonCard() }
                    }
                    .padding()
                }
            case .loaded(let page):
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        ForEach(page.rows) { row in
                            RowView(row: row, sizeClass: sizeClass)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            case .empty:
                EmptyStateView(
                    title: "Nothing on this page",
                    message: "The page has no published content in its containers.",
                    systemImage: "square.dashed"
                )
            case .failed(let error):
                ErrorStateView(error: error) { Task { await model.load() } }
            }
        }
        .navigationTitle(model.state.value?.title ?? "Home")
        .navigationDestination(for: Contentlet.self) { BlogDetailScreen(blog: $0) }
        .refreshable { await model.load() }
        .task { if case .idle = model.state { await model.load() } }
    }
}

private struct RowView: View {
    let row: PageLayout.Row
    let sizeClass: UserInterfaceSizeClass?

    /// Columns sit side by side only when there is room and they are narrow
    /// enough to be worth it; otherwise they stack.
    private var isHorizontal: Bool {
        sizeClass == .regular && row.columns.count > 1
    }

    var body: some View {
        if isHorizontal {
            HStack(alignment: .top, spacing: 16) {
                ForEach(row.columns) { column in
                    ColumnView(column: column)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 22) {
                ForEach(row.columns) { column in
                    ColumnView(column: column)
                }
            }
        }
    }
}

private struct ColumnView: View {
    let column: PageLayout.Column

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(column.contentlets) { contentlet in
                ContentletRegistry.view(for: contentlet)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
