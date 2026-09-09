import SwiftUI

@MainActor
@Observable
final class BlogListModel {
    var state: LoadState<[Contentlet]> = .idle
    private let repository = ContentRepository()

    func load() async {
        if case .loaded = state {} else { state = .loading }
        do {
            let blogs = try await repository.blogs()
            state = blogs.isEmpty ? .empty : .loaded(blogs)
        } catch let error as DotCMSError {
            state = .failed(error)
        } catch {
            state = .failed(.network(error.localizedDescription))
        }
    }
}

struct BlogListScreen: View {
    @State private var model = BlogListModel()

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
            case .loaded(let blogs):
                List(blogs) { blog in
                    NavigationLink(value: blog) {
                        BlogRow(blog: blog)
                    }
                    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(.plain)
            case .empty:
                EmptyStateView(
                    title: "No posts yet",
                    message: "This site has no published blog posts.",
                    systemImage: "text.alignleft"
                )
            case .failed(let error):
                ErrorStateView(error: error) { Task { await model.load() } }
            }
        }
        .navigationTitle("Blog")
        .navigationDestination(for: Contentlet.self) { BlogDetailScreen(blog: $0) }
        .refreshable { await model.load() }
        .task { if case .idle = model.state { await model.load() } }
    }
}

private struct BlogRow: View {
    let blog: Contentlet

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DotImage(identifier: blog.identifier, fallbackPath: blog.imagePath)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(blog.displayTitle)
                .font(.headline)

            // Optional fields are omitted rather than rendered blank.
            if let summary = blog.summary, !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            HStack(spacing: 8) {
                if let author = blog.authorName {
                    Text(author)
                }
                if let date = blog.publishDate {
                    if blog.authorName != nil { Text("·") }
                    Text(date, format: .dateTime.month(.abbreviated).day().year())
                }
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
