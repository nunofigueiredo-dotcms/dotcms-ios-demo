import SwiftUI

@MainActor
@Observable
final class BlogDetailModel {
    var state: LoadState<Contentlet> = .idle
    private let repository = ContentRepository()

    func load(urlTitle: String?) async {
        guard let urlTitle, !urlTitle.isEmpty else {
            state = .failed(.notFound)
            return
        }
        state = .loading
        do {
            state = .loaded(try await repository.blog(urlTitle: urlTitle))
        } catch let error as DotCMSError {
            state = .failed(error)
        } catch {
            state = .failed(.network(error.localizedDescription))
        }
    }
}

struct BlogDetailScreen: View {
    /// The listing contentlet, shown immediately so the screen is never blank
    /// while the full body loads.
    let blog: Contentlet
    @State private var model = BlogDetailModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DotImage(identifier: blog.identifier, fallbackPath: blog.imagePath)

                VStack(alignment: .leading, spacing: 12) {
                    Text(blog.displayTitle)
                        .font(.largeTitle.bold())

                    HStack(spacing: 8) {
                        if let author = blog.authorName { Text(author) }
                        if let date = blog.publishDate {
                            if blog.authorName != nil { Text("·") }
                            Text(date, format: .dateTime.month(.wide).day().year())
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    if let summary = blog.summary, !summary.isEmpty {
                        Text(summary)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    switch model.state {
                    case .idle, .loading:
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(0..<4, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.quaternary).frame(height: 14)
                            }
                        }
                        .shimmer()
                    case .loaded(let full):
                        if let body = full.body {
                            StoryBlockView(storyBlock: body)
                        } else {
                            Text("This post has no body content.")
                                .foregroundStyle(.tertiary)
                        }
                    case .empty:
                        Text("This post has no body content.")
                            .foregroundStyle(.tertiary)
                    case .failed(let error):
                        ErrorStateView(error: error) {
                            Task { await model.load(urlTitle: blog.urlTitle) }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(blog.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.load(urlTitle: blog.urlTitle) }
    }
}
