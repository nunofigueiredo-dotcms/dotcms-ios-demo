import SwiftUI

@MainActor
@Observable
final class PageModel {
    var state: LoadState<PageLayout> = .idle
    private let repository = PageRepository()
    private let uri: String

    init(uri: String) {
        self.uri = uri
    }

    func load() async {
        if case .loaded = state {} else { state = .loading }
        do {
            let page = try await repository.page(uri: uri)
            state = page.isEmpty ? .empty : .loaded(page)
        } catch let error as DotCMSError {
            state = .failed(error)
        } catch {
            state = .failed(.network(error.localizedDescription))
        }
    }
}

/// Renders any dotCMS page by URI through the layout mapping and the component
/// registry. Home is this screen pointed at "/index"; About Us and any other
/// page asset reuse it unchanged, which is the point — adding a page to the app
/// requires no new rendering code.
struct PageScreen: View {
    let uri: String
    let fallbackTitle: String

    @State private var model: PageModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    init(uri: String, fallbackTitle: String) {
        self.uri = uri
        self.fallbackTitle = fallbackTitle
        _model = State(initialValue: PageModel(uri: uri))
    }

    var body: some View {
        Group {
            switch model.state {
            case .idle, .loading:
                PageSkeleton()
            case .loaded(let page):
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        ForEach(page.rows) { row in
                            PageRowView(row: row, sizeClass: sizeClass)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            case .empty:
                EmptyStateView(
                    title: "Nothing on this page",
                    message: "\(uri) has no published content in its containers.",
                    systemImage: "square.dashed"
                )
            case .failed(let error):
                ErrorStateView(error: error) { Task { await model.load() } }
            }
        }
        .navigationTitle(model.state.value?.title ?? fallbackTitle)
        .refreshable { await model.load() }
        .task { if case .idle = model.state { await model.load() } }
    }
}

/// Loading placeholder shaped like a real page: one hero plus stacked cards,
/// so the layout does not jump when content arrives.
struct PageSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.quaternary)
                    .aspectRatio(4 / 3, contentMode: .fit)
                    .shimmer()

                ForEach(0..<2, id: \.self) { _ in SkeletonCard() }
            }
            .padding()
        }
    }
}

struct PageRowView: View {
    let row: PageLayout.Row
    let sizeClass: UserInterfaceSizeClass?

    private var isHorizontal: Bool {
        sizeClass == .regular && row.columns.count > 1
    }

    var body: some View {
        if isHorizontal {
            HStack(alignment: .top, spacing: 16) {
                ForEach(row.columns) { column in
                    PageColumnView(column: column)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 22) {
                ForEach(row.columns) { column in
                    PageColumnView(column: column)
                }
            }
        }
    }
}

struct PageColumnView: View {
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
