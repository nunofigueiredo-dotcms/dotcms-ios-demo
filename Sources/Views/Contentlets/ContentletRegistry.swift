import SwiftUI

/// Maps a dotCMS content type variable name to the SwiftUI view that renders
/// it — the direct analogue of the `pageComponents` map in the Next.js example.
///
/// Adding a content type to the app means adding one entry here plus a view.
/// Anything not registered renders `UnknownContentletView`, which is a visible,
/// styled placeholder rather than a silent omission: it is how you show a
/// partner what extending the app looks like.
enum ContentletRegistry {
    static let views: [String: (Contentlet) -> AnyView] = [
        "Banner": { AnyView(BannerCard($0)) },
        "Blog": { AnyView(BlogCard($0)) },
        "webPageContent": { AnyView(RichTextBlock($0)) },
        "CallToAction": { AnyView(CallToActionCard($0)) },
    ]

    /// Content types this build knows how to draw, for the Settings screen.
    static var registeredTypes: [String] { views.keys.sorted() }

    @ViewBuilder
    static func view(for contentlet: Contentlet) -> some View {
        if let builder = views[contentlet.contentType] {
            builder(contentlet)
        } else {
            UnknownContentletView(contentlet: contentlet)
        }
    }
}

/// Deliberately visible. A missing component is a demo talking point, not a
/// failure to hide.
struct UnknownContentletView: View {
    let contentlet: Contentlet

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("No component for type", systemImage: "cube.transparent")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(contentlet.contentType)
                .font(.headline.monospaced())

            if let title = contentlet.title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Add it to ContentletRegistry to render it here.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.tertiary, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        }
    }
}
